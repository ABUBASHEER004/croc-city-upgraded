const crypto = require('crypto');
const {onCall, onRequest, HttpsError} = require('firebase-functions/https');
const {defineSecret} = require('firebase-functions/params');
const {setGlobalOptions} = require('firebase-functions');
const {initializeApp} = require('firebase-admin/app');
const {getAuth} = require('firebase-admin/auth');
const {getMessaging} = require('firebase-admin/messaging');
const {getFirestore, FieldValue} = require('firebase-admin/firestore');
const {onDocumentCreated, onDocumentUpdated} = require('firebase-functions/v2/firestore');

initializeApp();
setGlobalOptions({region: 'us-central1', maxInstances: 10});

const PAYSTACK_SECRET_KEY = defineSecret('PAYSTACK_SECRET_KEY');
const PAYSTACK_BASE_URL = 'https://api.paystack.co';

function requireAuth(request) {
  if (!request.auth || !request.auth.uid) {
    throw new HttpsError('unauthenticated', 'You must be signed in to make a payment.');
  }
  return request.auth.uid;
}

function cleanReference(value) {
  return String(value || '').replace(/[^a-zA-Z0-9.=-]/g, '').slice(0, 80);
}

async function paystackRequest(path, options = {}) {
  const response = await fetch(`${PAYSTACK_BASE_URL}${path}`, {
    ...options,
    headers: {
      Authorization: `Bearer ${PAYSTACK_SECRET_KEY.value()}`,
      'Content-Type': 'application/json',
      ...(options.headers || {}),
    },
  });

  const payload = await response.json().catch(() => ({}));
  if (!response.ok || payload.status !== true) {
    const message = payload.message || `Paystack request failed (${response.status}).`;
    throw new Error(message);
  }
  return payload;
}

function amountInKobo(naira) {
  const amount = Number(naira);
  if (!Number.isFinite(amount) || amount <= 0) {
    throw new HttpsError('invalid-argument', 'Payment amount must be greater than zero.');
  }
  return Math.round(amount * 100);
}

async function createOrGetPaymentRecord({transaction, invoice, uid}) {
  const db = getFirestore();
  const reference = transaction.reference;
  const paymentRef = db.collection('payments').doc(`paystack_${reference}`);
  const invoiceRef = db.collection('invoices').doc(invoice.id);

  await db.runTransaction(async (tx) => {
    const [paymentSnap, invoiceSnap] = await Promise.all([
      tx.get(paymentRef),
      tx.get(invoiceRef),
    ]);

    if (paymentSnap.exists) return;
    if (!invoiceSnap.exists) throw new Error('Invoice no longer exists.');

    const current = invoiceSnap.data() || {};
    if (current.parentId !== uid) {
      throw new Error('You are not allowed to pay this invoice.');
    }

    const invoiceAmount = Number(current.amount || 0);
    const alreadyPaid = Number(current.paidAmount || 0);
    const balance = Math.max(0, invoiceAmount - alreadyPaid);
    const paidAmount = Number(transaction.amount || 0) / 100;

    // Never let a Paystack response credit more than the invoice balance.
    if (paidAmount <= 0 || paidAmount > balance + 0.01) {
      throw new Error('Verified payment amount does not match the invoice balance.');
    }

    const newPaidAmount = Math.min(invoiceAmount, alreadyPaid + paidAmount);
    const paidAt = transaction.paid_at ? new Date(transaction.paid_at) : new Date();

    tx.set(paymentRef, {
      invoiceId: invoice.id,
      invoiceNumber: current.invoiceNumber || invoice.invoiceNumber || invoice.id,
      playerId: current.playerId || '',
      playerName: current.playerName || '',
      parentId: current.parentId || uid,
      amount: paidAmount,
      method: 'Paystack',
      reference,
      note: `Paystack ${transaction.channel || 'payment'} · ${transaction.gateway_response || 'Successful'}`,
      paidAt,
      createdAt: FieldValue.serverTimestamp(),
    });

    tx.update(invoiceRef, {
      paidAmount: newPaidAmount,
      status: newPaidAmount >= invoiceAmount ? 'Paid' : 'Partially paid',
      updatedAt: FieldValue.serverTimestamp(),
      lastPaymentReference: reference,
    });
  });

  return paymentRef.id;
}

exports.initializePaystackPayment = onCall(
  {secrets: [PAYSTACK_SECRET_KEY]},
  async (request) => {
    const uid = requireAuth(request);
    const data = request.data || {};
    const invoiceId = String(data.invoiceId || '').trim();

    if (!invoiceId) {
      throw new HttpsError('invalid-argument', 'invoiceId is required.');
    }

    const db = getFirestore();
    const invoiceSnap = await db.collection('invoices').doc(invoiceId).get();
    if (!invoiceSnap.exists) {
      throw new HttpsError('not-found', 'Invoice not found.');
    }

    const invoice = {id: invoiceSnap.id, ...invoiceSnap.data()};
    if (invoice.parentId !== uid) {
      throw new HttpsError('permission-denied', 'You cannot pay this invoice.');
    }

    const balance = Math.max(0, Number(invoice.amount || 0) - Number(invoice.paidAmount || 0));
    if (balance <= 0.009) {
      throw new HttpsError('failed-precondition', 'This invoice is already paid.');
    }

    const userEmail = request.auth.token.email;
    if (!userEmail) {
      throw new HttpsError('failed-precondition', 'Your account needs a verified email before payment.');
    }

    const reference = cleanReference(`CCA-${invoiceId}-${Date.now()}-${uid.slice(0, 8)}`);
    const response = await paystackRequest('/transaction/initialize', {
      method: 'POST',
      body: JSON.stringify({
        email: userEmail,
        amount: String(amountInKobo(balance)),
        currency: 'NGN',
        reference,
        metadata: JSON.stringify({
          invoiceId,
          parentId: uid,
          playerId: invoice.playerId || '',
          source: 'croc_city_app',
        }),
      }),
    });

    return {
      accessCode: response.data.access_code,
      reference: response.data.reference,
      authorizationUrl: response.data.authorization_url,
      amount: balance,
      currency: 'NGN',
    };
  },
);

exports.verifyPaystackPayment = onCall(
  {secrets: [PAYSTACK_SECRET_KEY]},
  async (request) => {
    const uid = requireAuth(request);
    const reference = cleanReference(request.data?.reference);
    if (!reference) {
      throw new HttpsError('invalid-argument', 'Payment reference is required.');
    }

    const response = await paystackRequest(`/transaction/verify/${encodeURIComponent(reference)}`, {
      method: 'GET',
    });
    const transaction = response.data;

    if (transaction.status !== 'success') {
      return {
        status: transaction.status || 'pending',
        message: transaction.gateway_response || 'Payment has not been completed.',
        reference,
      };
    }

    const metadata = typeof transaction.metadata === 'string'
      ? JSON.parse(transaction.metadata || '{}')
      : (transaction.metadata || {});
    const invoiceId = String(metadata.invoiceId || '').trim();
    if (!invoiceId || metadata.parentId !== uid) {
      throw new HttpsError('permission-denied', 'Payment ownership could not be verified.');
    }

    const invoiceSnap = await getFirestore().collection('invoices').doc(invoiceId).get();
    if (!invoiceSnap.exists || invoiceSnap.data().parentId !== uid) {
      throw new HttpsError('permission-denied', 'Invoice ownership could not be verified.');
    }

    const paymentId = await createOrGetPaymentRecord({
      transaction,
      invoice: {id: invoiceId, invoiceNumber: invoiceSnap.data().invoiceNumber},
      uid,
    });

    return {
      status: 'success',
      reference,
      paymentId,
      message: 'Payment verified and recorded successfully.',
    };
  },
);

exports.paystackWebhook = onRequest(
  {secrets: [PAYSTACK_SECRET_KEY]},
  async (request, response) => {
    if (request.method !== 'POST') {
      response.status(405).send('Method Not Allowed');
      return;
    }

    const signature = request.get('x-paystack-signature') || '';
    const rawBody = request.rawBody || Buffer.from(JSON.stringify(request.body || {}));
    const expected = crypto
      .createHmac('sha512', PAYSTACK_SECRET_KEY.value())
      .update(rawBody)
      .digest('hex');

    if (!signature || signature.length !== expected.length || !crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expected))) {
      response.status(401).send('Invalid signature');
      return;
    }

    const event = request.body || {};
    if (event.event !== 'charge.success') {
      response.status(200).send('Ignored');
      return;
    }

    try {
      const transaction = event.data || {};
      const metadata = typeof transaction.metadata === 'string'
        ? JSON.parse(transaction.metadata || '{}')
        : (transaction.metadata || {});
      const invoiceId = String(metadata.invoiceId || '').trim();
      const parentId = String(metadata.parentId || '').trim();

      if (!invoiceId || !parentId || transaction.status !== 'success') {
        response.status(200).send('Missing payment metadata');
        return;
      }

      const invoiceSnap = await getFirestore().collection('invoices').doc(invoiceId).get();
      if (!invoiceSnap.exists || invoiceSnap.data().parentId !== parentId) {
        response.status(200).send('Invoice not found');
        return;
      }

      await createOrGetPaymentRecord({
        transaction,
        invoice: {id: invoiceId, invoiceNumber: invoiceSnap.data().invoiceNumber},
        uid: parentId,
      });

      response.status(200).send('OK');
    } catch (error) {
      console.error('Paystack webhook error:', error);
      response.status(500).send('Webhook processing failed');
    }
  },
);


function requireAdmin(request) {
  requireAuth(request);
  if (request.auth.token.admin !== true) {
    throw new HttpsError('permission-denied', 'Administrator access is required.');
  }
  return request.auth.uid;
}

function normalizeUsername(value) {
  return String(value || '').trim().toLowerCase().replace(/[^a-z0-9._-]/g, '').slice(0, 40);
}

const MANAGED_ROLES = new Set(['Player', 'Coach', 'Player Parent', 'Student', 'Student Parent', 'Teacher', 'Staff', 'Administrator', 'Admin']);

exports.resolveUsername = onCall(async (request) => {
  const username = normalizeUsername(request.data?.username);
  if (!username) throw new HttpsError('invalid-argument', 'Username is required.');

  const snap = await getFirestore().collection('users').where('username', '==', username).limit(1).get();
  if (snap.empty) throw new HttpsError('not-found', 'Username or password is incorrect.');
  const email = snap.docs[0].data().email;
  if (!email) throw new HttpsError('failed-precondition', 'This account has no login email.');
  return {email};
});

exports.adminCreateManagedUser = onCall(async (request) => {
  requireAdmin(request);
  const data = request.data || {};
  const firstName = String(data.firstName || '').trim();
  const lastName = String(data.lastName || '').trim();
  const username = normalizeUsername(data.username);
  const email = String(data.email || '').trim().toLowerCase();
  const phone = String(data.phone || '').trim();
  const password = String(data.password || '');
  const requestedRole = String(data.role || '').trim();
  const role = requestedRole.toLowerCase() === 'admin' ? 'Administrator' : requestedRole;

  const missing = [];
  if (!firstName) missing.push('firstName');
  if (!lastName) missing.push('lastName');
  if (!username) missing.push('username');
  if (!email) missing.push('email');
  if (!password) missing.push('password');

  if (missing.length > 0) {
    throw new HttpsError(
      'invalid-argument',
      `Missing required field(s): ${missing.join(', ')}.`,
    );
  }

  if (!MANAGED_ROLES.has(role)) {
    throw new HttpsError(
      'invalid-argument',
      `Invalid role "${requestedRole}". Valid roles are: ${[...MANAGED_ROLES].join(', ')}.`,
    );
  }
  if (password.length < 6) throw new HttpsError('invalid-argument', 'Password must be at least 6 characters.');
  if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) throw new HttpsError('invalid-argument', 'A valid email is required.');

  const db = getFirestore();
  const usernameSnap = await db.collection('users').where('username', '==', username).limit(1).get();
  if (!usernameSnap.empty) throw new HttpsError('already-exists', 'That username is already in use.');

  let user;
  try {
    user = await getAuth().createUser({
      email,
      password,
      displayName: `${firstName} ${lastName}`.trim(),
      emailVerified: true,
      disabled: false,
    });
  } catch (error) {
    if (error.code === 'auth/email-already-exists') throw new HttpsError('already-exists', 'That email address is already registered.');
    throw new HttpsError('internal', error.message || 'Could not create the user.');
  }

  try {
    await db.collection('users').doc(user.uid).set({
      uid: user.uid,
      firstName,
      lastName,
      username,
      email,
      phone,
      role,
      emailVerified: true,
      photoUrl: null,
      createdAt: FieldValue.serverTimestamp(),
      createdBy: request.auth.uid,
    });

    if (role === 'Administrator') {
      await getAuth().setCustomUserClaims(user.uid, {admin: true});
    }

    if (role === 'Coach') {
      await db.collection('coaches').doc(user.uid).set({
        id: user.uid, firstName, lastName, email, phone,
        specialty: 'Youth Development', licenseNumber: '', experience: '',
        photoUrl: null, bio: '', active: true, createdAt: FieldValue.serverTimestamp(),
      });
    }
  } catch (error) {
    await getAuth().deleteUser(user.uid).catch(() => {});
    throw new HttpsError('internal', error.message || 'Could not create the user profile.');
  }

  return {uid: user.uid, username, email, role, temporaryPassword: password};
});

exports.adminResetManagedUserPassword = onCall(async (request) => {
  requireAdmin(request);
  const uid = String(request.data?.uid || '').trim();
  const requested = String(request.data?.newPassword || '').trim();
  if (!uid) throw new HttpsError('invalid-argument', 'User id is required.');
  const password = requested || `Croc@${new Date().getFullYear()}${Math.floor(1000 + Math.random() * 9000)}`;
  if (password.length < 6) throw new HttpsError('invalid-argument', 'Password must be at least 6 characters.');

  try {
    await getAuth().updateUser(uid, {password});
  } catch (error) {
    throw new HttpsError('not-found', error.message || 'User could not be updated.');
  }
  await getFirestore().collection('users').doc(uid).set({passwordResetAt: FieldValue.serverTimestamp()}, {merge: true});
  return {uid, temporaryPassword: password};
});


// ============================================================
// ACADEMY PUSH NOTIFICATIONS
// ============================================================

const ROLE_TO_AUDIENCE = {
  Players: ['Player'],
  Coaches: ['Coach'],
  Teachers: ['Teacher'],
  Staff: ['Staff'],
  Students: ['Student'],
  'Player Parents': ['Player Parent', 'Parent'],
  'Student Parents': ['Student Parent'],
  Admins: ['Administrator', 'Admin'],
};

function stringArray(value) {
  return Array.isArray(value)
    ? value.map((item) => String(item || '').trim()).filter(Boolean)
    : [];
}

async function getAnnouncementRecipientIds(data) {
  const db = getFirestore();
  const audienceKeys = stringArray(data.audienceKeys);
  const audiences = stringArray(data.audiences);
  const keys = new Set([...audienceKeys, ...audiences]);

  const recipientIds = new Set();
  const recipientEmails = new Set(
    stringArray(data.recipientEmails).map((email) => email.toLowerCase()),
  );

  // Explicit user IDs always win as direct recipients.
  for (const uid of stringArray(data.recipientUserIds)) {
    recipientIds.add(uid);
  }

  if (keys.has('Everyone')) {
    const snapshot = await db.collection('users').get();
    for (const doc of snapshot.docs) {
      recipientIds.add(doc.id);
    }
    return [...recipientIds];
  }

  // If a role audience has an explicit recipient list, keep the
  // notification restricted to that list. This is important for
  // coach -> assigned players and teacher -> linked students.
  const roleNames = new Set();
  for (const key of keys) {
    for (const role of ROLE_TO_AUDIENCE[key] || []) {
      roleNames.add(role);
    }
  }

  if (roleNames.size > 0) {
    const explicitRestriction =
      recipientEmails.size > 0 || recipientIds.size > 0;

    const roles = [...roleNames];
    const snapshot = roles.length === 1
      ? await db.collection('users')
          .where('role', '==', roles[0])
          .get()
      : await db.collection('users')
          .where('role', 'in', roles)
          .get();

    for (const doc of snapshot.docs) {
      const email = String(doc.data().email || '').trim().toLowerCase();

      if (!explicitRestriction ||
          recipientIds.has(doc.id) ||
          (email && recipientEmails.has(email))) {
        recipientIds.add(doc.id);
      }
    }
  }

  // Direct email recipients are also supported for older announcements
  // that were created before recipientUserIds was introduced.
  if (recipientEmails.size > 0) {
    const emails = [...recipientEmails];

    for (let start = 0; start < emails.length; start += 30) {
      const chunk = emails.slice(start, start + 30);
      const snapshot = await db.collection('users')
        .where('email', 'in', chunk)
        .get();

      for (const doc of snapshot.docs) {
        recipientIds.add(doc.id);
      }
    }
  }

  return [...recipientIds];
}

async function publishAcademyNotification(
  announcementId,
  data,
) {
  if (data.active === false) return;

  const db = getFirestore();
  const recipientIds =
    await getAnnouncementRecipientIds(data);

  if (recipientIds.length === 0) {
    console.log(
      `No notification recipients for announcement ${announcementId}.`,
    );
    return;
  }

  const title =
    String(data.title || 'Croc-City Football Academy').trim();
  const message =
    String(data.message || data.description || '').trim();
  const priority =
    String(data.priority || 'Normal').trim();

  const tokens = [];
  const tokenOwners = new Map();

  for (let start = 0; start < recipientIds.length; start += 30) {
    const chunk = recipientIds.slice(start, start + 30);

    const snapshot = await db.collection('users')
      .where('__name__', 'in', chunk)
      .get();

    for (const doc of snapshot.docs) {
      const userTokens = stringArray(doc.data().fcmTokens);

      for (const token of userTokens) {
        tokens.push(token);
        tokenOwners.set(token, doc.id);
      }

      await doc.ref
        .collection('notifications')
        .doc(announcementId)
        .set({
          title,
          message,
          type: 'announcement',
          announcementId,
          priority,
          read: false,
          createdAt: FieldValue.serverTimestamp(),
        }, {merge: true});
    }
  }

  if (tokens.length === 0) {
    console.log(
      `Notification inbox records created, but no FCM tokens exist for ${announcementId}.`,
    );
    return;
  }

  const uniqueTokens = [...new Set(tokens)];
  const invalidTokens = [];

  for (let start = 0; start < uniqueTokens.length; start += 500) {
    const chunk = uniqueTokens.slice(start, start + 500);

    const result = await getMessaging().sendEachForMulticast({
      tokens: chunk,
      notification: {
        title,
        body: message,
      },
      data: {
        notificationId: announcementId,
        announcementId,
        type: 'announcement',
      },
      android: {
        notification: {
          channelId: 'academy_updates',
          priority: 'high',
          sound: 'default',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    });

    result.responses.forEach((response, index) => {
      if (!response.success) {
        const code = response.error?.code || '';
        if (
          code === 'messaging/registration-token-not-registered' ||
          code === 'messaging/invalid-registration-token'
        ) {
          invalidTokens.push(chunk[index]);
        }
      }
    });
  }

  // Remove expired tokens so future sends stay clean.
  for (const token of invalidTokens) {
    const owner = tokenOwners.get(token);
    if (!owner) continue;

    await db.collection('users').doc(owner).set({
      fcmTokens: FieldValue.arrayRemove(token),
    }, {merge: true});
  }

  console.log(
    `Academy notification ${announcementId} sent to ${recipientIds.length} users.`,
  );
}


async function getUsersByIds(ids) {
  const db = getFirestore();
  const unique = [...new Set(stringArray(ids))];
  if (unique.length === 0) return [];
  const users = [];
  for (let start = 0; start < unique.length; start += 30) {
    const chunk = unique.slice(start, start + 30);
    const snapshot = await db.collection('users').where('__name__', 'in', chunk).get();
    users.push(...snapshot.docs.map((doc) => ({id: doc.id, ...doc.data()})));
  }
  return users;
}

async function getUsersByEmails(emails) {
  const db = getFirestore();
  const unique = [...new Set(stringArray(emails).map((email) => email.toLowerCase()))];
  if (unique.length === 0) return [];
  const users = [];
  for (let start = 0; start < unique.length; start += 30) {
    const chunk = unique.slice(start, start + 30);
    const snapshot = await db.collection('users').where('email', 'in', chunk).get();
    users.push(...snapshot.docs.map((doc) => ({id: doc.id, ...doc.data()})));
  }
  return users;
}

async function addPlayerAndParentRecipients(recipientIds, playerDoc) {
  const player = playerDoc.data() || {};
  if (player.parentId) recipientIds.add(String(player.parentId));
  if (player.coachId) recipientIds.add(String(player.coachId));
  const users = await getUsersByEmails([player.email]);
  for (const user of users) recipientIds.add(user.id);
}

async function addTeamRecipients(recipientIds, teamId, coachId) {
  const db = getFirestore();
  if (coachId) recipientIds.add(String(coachId));
  if (!teamId) return;

  const snapshot = await db.collection('players').where('teamId', '==', String(teamId)).get();
  for (const doc of snapshot.docs) {
    await addPlayerAndParentRecipients(recipientIds, doc);
  }
}

async function addStudentRecipients(recipientIds, studentId) {
  if (!studentId) return;
  const db = getFirestore();
  const snap = await db.collection('students').doc(String(studentId)).get();
  if (!snap.exists) return;

  const student = snap.data() || {};
  for (const key of ['userId', 'parentId', 'coachId', 'teacherId']) {
    if (student[key]) recipientIds.add(String(student[key]));
  }
}

async function sendTargetedAcademyNotification({
  notificationId,
  type,
  title,
  message,
  recipientIds,
  priority = 'Normal',
  entityId = '',
}) {
  const db = getFirestore();
  const ids = [...new Set(stringArray([...recipientIds]))];
  if (ids.length === 0) return;

  const tokens = [];
  const tokenOwners = new Map();

  const users = await getUsersByIds(ids);
  for (const user of users) {
    const userTokens = stringArray(user.fcmTokens);
    for (const token of userTokens) {
      tokens.push(token);
      tokenOwners.set(token, user.id);
    }

    await db.collection('users').doc(user.id)
      .collection('notifications').doc(notificationId).set({
        title: String(title || 'Croc-City Football Academy').trim(),
        message: String(message || '').trim(),
        type,
        entityId: String(entityId || ''),
        priority,
        read: false,
        createdAt: FieldValue.serverTimestamp(),
      }, {merge: true});
  }

  const uniqueTokens = [...new Set(tokens)];
  if (uniqueTokens.length === 0) return;

  const invalidTokens = [];
  for (let start = 0; start < uniqueTokens.length; start += 500) {
    const chunk = uniqueTokens.slice(start, start + 500);
    const result = await getMessaging().sendEachForMulticast({
      tokens: chunk,
      notification: {
        title: String(title || 'Croc-City Football Academy').trim(),
        body: String(message || '').trim(),
      },
      data: {
        notificationId,
        type,
        entityId: String(entityId || ''),
      },
      android: {
        notification: {
          channelId: 'academy_updates',
          priority: 'high',
          sound: 'default',
        },
      },
      apns: {
        payload: {
          aps: {sound: 'default', badge: 1},
        },
      },
    });

    result.responses.forEach((response, index) => {
      if (!response.success) {
        const code = response.error?.code || '';
        if (code === 'messaging/registration-token-not-registered' ||
            code === 'messaging/invalid-registration-token') {
          invalidTokens.push(chunk[index]);
        }
      }
    });
  }

  for (const token of invalidTokens) {
    const owner = tokenOwners.get(token);
    if (!owner) continue;
    await db.collection('users').doc(owner).set({
      fcmTokens: FieldValue.arrayRemove(token),
    }, {merge: true});
  }
}

function eventTimeId(data) {
  const value = data?.updatedAt || data?.createdAt || data?.publishedAt;
  if (value?.toMillis) return String(value.toMillis());
  return String(Date.now());
}

exports.sendTrainingNotificationOnCreate = onDocumentCreated(
  'training_sessions/{trainingId}',
  async (event) => {
    const data = event.data?.data();
    if (!data) return;
    const recipients = new Set();
    await addTeamRecipients(recipients, data.teamId, data.coachId);
    if (recipients.size === 0) return;

    const when = data.scheduledAt?.toDate ? data.scheduledAt.toDate() : null;
    const timeText = when ? ` on ${when.toLocaleString('en-NG')}` : '';
    const location = data.location ? ` at ${data.location}` : '';
    await sendTargetedAcademyNotification({
      notificationId: `training_${event.params.trainingId}`,
      type: 'training',
      entityId: event.params.trainingId,
      title: 'New Training Session',
      message: `${data.title || 'Training session'}${timeText}${location}.`,
      recipientIds: recipients,
    });
  },
);

exports.sendTrainingNotificationOnUpdate = onDocumentUpdated(
  'training_sessions/{trainingId}',
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    const changed = before.scheduledAt?.toMillis?.() !== after.scheduledAt?.toMillis?.() ||
      before.location !== after.location ||
      before.status !== after.status ||
      before.teamId !== after.teamId;
    if (!changed) return;

    const recipients = new Set();
    await addTeamRecipients(recipients, after.teamId, after.coachId);
    await sendTargetedAcademyNotification({
      notificationId: `training_${event.params.trainingId}_${eventTimeId(after)}`,
      type: 'training',
      entityId: event.params.trainingId,
      title: 'Training Session Updated',
      message: `${after.title || 'Training session'} has been updated. Check the academy training schedule for the latest details.`,
      recipientIds: recipients,
    });
  },
);

exports.sendFixtureNotificationOnCreate = onDocumentCreated(
  'fixtures/{fixtureId}',
  async (event) => {
    const data = event.data?.data();
    if (!data) return;
    const recipients = new Set();
    await addTeamRecipients(recipients, data.teamId, data.coachId);
    if (recipients.size === 0) return;

    const date = data.date?.toDate ? data.date.toDate() : null;
    const when = date ? ` on ${date.toLocaleString('en-NG')}` : '';
    await sendTargetedAcademyNotification({
      notificationId: `fixture_${event.params.fixtureId}`,
      type: 'fixture',
      entityId: event.params.fixtureId,
      title: 'New Match Fixture',
      message: `${data.homeTeam || 'Home'} vs ${data.awayTeam || 'Away'}${when}${data.venue ? ` at ${data.venue}` : ''}.`,
      recipientIds: recipients,
    });
  },
);

exports.sendFixtureNotificationOnUpdate = onDocumentUpdated(
  'fixtures/{fixtureId}',
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    const changed = before.date?.toMillis?.() !== after.date?.toMillis?.() ||
      before.venue !== after.venue ||
      before.status !== after.status ||
      before.teamId !== after.teamId ||
      before.homeScore !== after.homeScore ||
      before.awayScore !== after.awayScore;
    if (!changed) return;

    const recipients = new Set();
    await addTeamRecipients(recipients, after.teamId, after.coachId);
    await sendTargetedAcademyNotification({
      notificationId: `fixture_${event.params.fixtureId}_${eventTimeId(after)}`,
      type: 'fixture',
      entityId: event.params.fixtureId,
      title: 'Match Fixture Updated',
      message: `${after.homeTeam || 'Home'} vs ${after.awayTeam || 'Away'} has an important update. Check Fixtures for the latest details.`,
      recipientIds: recipients,
    });
  },
);

exports.sendAssignmentNotificationOnCreate = onDocumentCreated(
  'assignments/{assignmentId}',
  async (event) => {
    const data = event.data?.data();
    if (!data || data.published !== true) return;
    const recipients = new Set(stringArray(data.studentUserIds));
    for (const studentId of stringArray(data.studentIds)) {
      await addStudentRecipients(recipients, studentId);
    }

    await sendTargetedAcademyNotification({
      notificationId: `assignment_${event.params.assignmentId}`,
      type: 'assignment',
      entityId: event.params.assignmentId,
      title: 'New Assignment',
      message: `${data.title || 'A new assignment'} has been published.`,
      recipientIds: recipients,
    });
  },
);

exports.sendAssignmentNotificationOnPublish = onDocumentUpdated(
  'assignments/{assignmentId}',
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after || before.published === true || after.published !== true) return;

    const recipients = new Set(stringArray(after.studentUserIds));
    for (const studentId of stringArray(after.studentIds)) {
      await addStudentRecipients(recipients, studentId);
    }

    await sendTargetedAcademyNotification({
      notificationId: `assignment_${event.params.assignmentId}`,
      type: 'assignment',
      entityId: event.params.assignmentId,
      title: 'New Assignment',
      message: `${after.title || 'A new assignment'} has been published.`,
      recipientIds: recipients,
    });
  },
);

exports.sendAttendanceNotificationOnCreate = onDocumentCreated(
  'student_attendance/{attendanceId}',
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const recipients = new Set();
    await addStudentRecipients(recipients, data.studentId);
    if (data.teacherId) recipients.delete(String(data.teacherId));

    const date = data.date?.toDate ? data.date.toDate() : null;
    const dateText = date ? ` for ${date.toLocaleDateString('en-NG')}` : '';
    await sendTargetedAcademyNotification({
      notificationId: `attendance_${event.params.attendanceId}`,
      type: 'attendance',
      entityId: event.params.attendanceId,
      title: 'Attendance Recorded',
      message: `${data.studentName || 'Student'} was marked ${data.status || 'updated'}${dateText}.`,
      recipientIds: recipients,
    });
  },
);

exports.sendAttendanceNotificationOnWrite = onDocumentUpdated(
  'student_attendance/{attendanceId}',
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after || before.status === after.status) return;

    const recipients = new Set();
    await addStudentRecipients(recipients, after.studentId);
    if (after.teacherId) recipients.delete(String(after.teacherId));

    const date = after.date?.toDate ? after.date.toDate() : null;
    const dateText = date ? ` for ${date.toLocaleDateString('en-NG')}` : '';
    await sendTargetedAcademyNotification({
      notificationId: `attendance_${event.params.attendanceId}_${eventTimeId(after)}`,
      type: 'attendance',
      entityId: event.params.attendanceId,
      title: 'Attendance Updated',
      message: `${after.studentName || 'Student'} was marked ${after.status || 'updated'}${dateText}.`,
      recipientIds: recipients,
    });
  },
);

exports.sendStudentResultNotificationOnPublish = onDocumentUpdated(
  'student_results/{resultId}',
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after || before.published === true || after.published !== true) return;

    const recipients = new Set();
    await addStudentRecipients(recipients, after.studentId);
    if (after.parentId) recipients.add(String(after.parentId));

    await sendTargetedAcademyNotification({
      notificationId: `student_result_${event.params.resultId}`,
      type: 'result',
      entityId: event.params.resultId,
      title: 'Academic Result Published',
      message: `${after.studentName || 'A student'}'s academic result is now available.`,
      recipientIds: recipients,
    });
  },
);

exports.sendPlayerResultNotificationOnPublish = onDocumentUpdated(
  'player_results/{resultId}',
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after || before.published === true || after.published !== true) return;

    const recipients = new Set();
    if (after.parentId) recipients.add(String(after.parentId));

    const db = getFirestore();
    const playerId = String(after.playerId || '');
    if (playerId) {
      const playerSnap = await db.collection('players').doc(playerId).get();
      if (playerSnap.exists) {
        await addPlayerAndParentRecipients(recipients, playerSnap);
      }
    }

    await sendTargetedAcademyNotification({
      notificationId: `player_result_${event.params.resultId}`,
      type: 'result',
      entityId: event.params.resultId,
      title: 'Player Result Published',
      message: `${after.playerName || 'A player'}'s performance result is now available.`,
      recipientIds: recipients,
    });
  },
);

exports.sendAcademyNotificationOnCreate = onDocumentCreated(
  'announcements/{announcementId}',
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    await publishAcademyNotification(
      event.params.announcementId,
      data,
    );
  },
);

exports.sendAcademyNotificationOnPublish = onDocumentUpdated(
  'announcements/{announcementId}',
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    if (!before || !after) return;

    // Only send a new push when an existing draft is published.
    if (before.active === true || after.active !== true) {
      return;
    }

    await publishAcademyNotification(
      event.params.announcementId,
      after,
    );
  },
);
