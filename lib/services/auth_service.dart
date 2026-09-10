import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_user.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ================= LOGIN =================

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_firebaseError(e));
    }
  }

  // ================= REGISTER =================

  Future<UserCredential> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      final credential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;

      await user.updateDisplayName(
        "$firstName $lastName",
      );

      await user.sendEmailVerification();

      final appUser = AppUser(
        uid: user.uid,
        firstName: firstName,
        lastName: lastName,
        email: email.trim(),
        phone: phone,
        role: role,
        emailVerified: false,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection("users")
          .doc(user.uid)
          .set(appUser.toMap());

      if (role.trim().toLowerCase() == 'coach') {
        await _firestore.collection('coaches').doc(user.uid).set({
          'id': user.uid,
          'firstName': firstName,
          'lastName': lastName,
          'email': email.trim(),
          'phone': phone,
          'specialty': 'Youth Development',
          'licenseNumber': '',
          'experience': '',
          'photoUrl': null,
          'bio': '',
          'active': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_firebaseError(e));
    }
  }

  // ================= GOOGLE SIGN IN =================

  Future<UserCredential> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception("Google sign-in cancelled.");
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _auth.signInWithCredential(credential);

      final user = userCredential.user!;

      final userDoc =
          _firestore.collection("users").doc(user.uid);

      if (!(await userDoc.get()).exists) {
        final names = (user.displayName ?? "").split(" ");

        final firstName =
            names.isNotEmpty ? names.first : "";

        final lastName = names.length > 1
            ? names.sublist(1).join(" ")
            : "";

        final appUser = AppUser(
          uid: user.uid,
          firstName: firstName,
          lastName: lastName,
          email: user.email ?? "",
          phone: user.phoneNumber ?? "",
          role: "Player",
          emailVerified: user.emailVerified,
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
        );

        await userDoc.set(appUser.toMap());
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_firebaseError(e));
    }
  }

  // ================= PASSWORD RESET =================

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_firebaseError(e));
    }
  }

  // ================= LOGOUT =================

  Future<void> logout() async {
    // Firebase is the source of truth for the app session, so clear it
    // first. Google sign-out is only a best-effort cleanup step.
    await _auth.signOut();

    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // A Google cleanup failure must never keep the user logged in.
    }
  }

  Future<bool> hasAdminClaim({bool forceRefresh = false}) async {
    final user = currentUser;
    if (user == null) return false;

    final token = await user.getIdTokenResult(forceRefresh);
    return token.claims?['admin'] == true ||
        token.claims?['role']?.toString().toLowerCase() == 'admin';
  }

  // ================= RELOAD =================

  Future<void> reloadUser() async {
    final user = currentUser;
    if (user == null) return;

    await user.reload();
    final refreshedUser = _auth.currentUser;

    if (refreshedUser != null) {
      await _firestore.collection('users').doc(refreshedUser.uid).set(
        {'emailVerified': refreshedUser.emailVerified},
        SetOptions(merge: true),
      );
    }
  }

  // ================= PROFILE =================

  Future<AppUser?> getUserProfile(String uid) async {
    final doc = await _firestore
        .collection("users")
        .doc(uid)
        .get();

    if (!doc.exists) {
      return null;
    }

    return AppUser.fromMap(doc.data()!);
  }


  /// Updates the editable profile fields without allowing the account role
  /// or UID to be changed by the client.
  Future<void> updateProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.uid != uid) {
      throw Exception('Your session has expired. Please sign in again.');
    }

    final displayName = '$firstName $lastName'.trim();

    await user.updateDisplayName(displayName);

    await _firestore.collection('users').doc(uid).set(
      {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
      },
      SetOptions(merge: true),
    );
  }

  // ================= ERROR HANDLER =================

  String _firebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'user-not-found':
        return 'No account found with this email.';

      case 'wrong-password':
        return 'Incorrect password.';

      case 'email-already-in-use':
        return 'Email address already exists.';

      case 'weak-password':
        return 'Password is too weak.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      case 'invalid-credential':
        return 'Invalid login credentials.';

      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}