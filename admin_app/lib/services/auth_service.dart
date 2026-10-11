import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Map Firebase Authentication exception codes to user-friendly messages
  static String mapFirebaseAuthError(dynamic exception) {
    if (exception is FirebaseAuthException) {
      switch (exception.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-login-credentials':
          return 'Invalid admin email or password. Please verify your credentials.';
        case 'invalid-email':
          return 'Please enter a valid administrator email address.';
        case 'user-disabled':
          return 'This administrator account has been disabled. Please contact system engineering.';
        case 'too-many-requests':
          return 'Too many failed login attempts. Access is temporarily locked. Please try again later.';
        case 'operation-not-allowed':
          return 'Email/password sign-in is not enabled in Firebase Console. Please enable it in Authentication > Sign-in method.';
        case 'configuration-not-found':
          return 'Firebase Authentication is not activated in the Firebase project. Please enable Authentication in the Firebase Console.';
        case 'network-request-failed':
          return 'Network connection error. Please check your internet connection and try again.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'weak-password':
          return 'Password is too weak. Please choose a password with at least 6 characters.';
        default:
          return exception.message ?? 'Authentication failed (${exception.code}). Please try again.';
      }
    }
    return exception?.toString() ?? 'An unexpected authentication error occurred.';
  }

  /// Sign in admin with email & password and verify admin role
  Future<String?> signInAdmin(String email, String password) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      return 'Please enter both admin email and password.';
    }

    _setLoading(true);
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: trimmedPassword,
      );

      // Verify admin role in Firestore
      final uid = credential.user?.uid;
      if (uid == null) {
        await _auth.signOut();
        _setLoading(false);
        return 'Authentication failed: No user found.';
      }

      // Check users collection for admin role
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      bool isAdmin = false;
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        if (data?['role'] == 'admin') {
          isAdmin = true;
        }
      }

      if (!isAdmin) {
        await _auth.signOut();
        _setLoading(false);
        return 'Access Denied: The account "${credential.user?.email}" does not have administrator permissions.';
      }

      _setLoading(false);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return mapFirebaseAuthError(e);
    } catch (e) {
      _setLoading(false);
      return 'Unexpected error: $e';
    }
  }

  /// Quick helper to provision or register the default admin account: admin@ecommerce.com / password123
  Future<String?> setupDefaultAdmin({
    String email = 'admin@ecommerce.com',
    String password = 'password123',
  }) async {
    _setLoading(true);
    try {
      UserCredential cred;
      try {
        cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // If already created, sign in to ensure Firestore has admin role
          cred = await _auth.signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
        } else {
          rethrow;
        }
      }

      final uid = cred.user!.uid;
      final docRef = _firestore.collection('users').doc(uid);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        await docRef.set({
          'uid': uid,
          'email': email.trim(),
          'name': 'System Administrator',
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Document exists: update role only, preserving immutable createdAt
        final data = docSnap.data();
        if (data?['role'] != 'admin') {
          await docRef.update({'role': 'admin'});
        }
      }

      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return mapFirebaseAuthError(e);
    } catch (e) {
      _setLoading(false);
      return e.toString();
    }
  }

  /// Send password reset email for admin
  Future<String?> sendPasswordResetEmail(String email) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      return 'Please enter your email address.';
    }

    _setLoading(true);
    try {
      await _auth.sendPasswordResetEmail(email: trimmedEmail);
      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return mapFirebaseAuthError(e);
    } catch (e) {
      _setLoading(false);
      return 'Unexpected error: $e';
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}
