import fs from 'node:fs';
import process from 'node:process';
import { cert, getApps, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';

const email = process.env.ADMIN_EMAIL?.trim();
const password = process.env.ADMIN_PASSWORD;
const displayName = process.env.ADMIN_NAME?.trim() || 'Croc City Administrator';
const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT;

if (!email || !password) {
  console.error('Missing ADMIN_EMAIL or ADMIN_PASSWORD.');
  process.exit(1);
}

if (password.length < 6) {
  console.error('ADMIN_PASSWORD must be at least 6 characters.');
  process.exit(1);
}

if (!serviceAccountPath) {
  console.error('Set FIREBASE_SERVICE_ACCOUNT to the path of your Firebase service-account JSON.');
  console.error('Example (PowerShell): $env:FIREBASE_SERVICE_ACCOUNT="C:\\secure\\service-account.json"');
  process.exit(1);
}

if (!fs.existsSync(serviceAccountPath)) {
  console.error(`Service-account file not found: ${serviceAccountPath}`);
  process.exit(1);
}

const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));

if (getApps().length === 0) {
  initializeApp({ credential: cert(serviceAccount) });
}

const auth = getAuth();
const db = getFirestore();

let user;
try {
  user = await auth.getUserByEmail(email);
  user = await auth.updateUser(user.uid, {
    displayName,
    emailVerified: true,
    password,
    disabled: false,
  });
  console.log(`Existing Firebase user updated: ${user.uid}`);
} catch (error) {
  if (error?.code !== 'auth/user-not-found') throw error;
  user = await auth.createUser({
    email,
    password,
    displayName,
    emailVerified: true,
    disabled: false,
  });
  console.log(`Created Firebase user: ${user.uid}`);
}

await auth.setCustomUserClaims(user.uid, {
  ...(user.customClaims ?? {}),
  admin: true,
  role: 'admin',
});

await db.collection('users').doc(user.uid).set({
  uid: user.uid,
  firstName: displayName.split(/\s+/)[0] || 'Croc City',
  lastName: displayName.split(/\s+/).slice(1).join(' ') || 'Administrator',
  email,
  username: email.split('@')[0].toLowerCase(),
  phone: '',
  role: 'Administrator',
  admin: true,
  emailVerified: true,
  photoUrl: null,
  createdAt: FieldValue.serverTimestamp(),
}, { merge: true });

console.log('');
console.log('FIRST ADMIN READY');
console.log(`Email: ${email}`);
console.log(`UID:   ${user.uid}`);
console.log('Role:  Administrator');
console.log('Claim: admin=true');
console.log('');
console.log('Sign in through the Flutter app with this email/password.');
console.log('The app will load the admin claim and show the Admin Dashboard.');
