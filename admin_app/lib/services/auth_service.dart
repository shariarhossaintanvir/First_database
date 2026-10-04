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

  /// Sign in admin with email & password and verify admin role
  Future<String?> signInAdmin(String email, String password) async {
    _setLoading(true);
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Verify admin role in Firestore
      final uid = credential.user?.uid;
      if (uid == null) {
        await _auth.signOut();
        _setLoading(false);
        return 'Authentication failed: No user found.';
      }

      // Check users collection
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

      // Fallback check for master admin email
      if (credential.user?.email?.toLowerCase() == 'admin@ecommerce.com') {
        isAdmin = true;
        // Ensure firestore doc reflects admin
        if (!userDoc.exists) {
          await _firestore.collection('users').doc(uid).set({
            'uid': uid,
            'email': credential.user?.email,
            'name': 'System Administrator',
            'role': 'admin',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      if (!isAdmin) {
        await _auth.signOut();
        _setLoading(false);
        return 'Access Denied: You do not have administrator permissions.';
      }

      _setLoading(false);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message ?? 'Login failed. Please check credentials.';
    } catch (e) {
      _setLoading(false);
      return 'Unexpected error: $e';
    }
  }

  /// Quick helper to provision or register the default admin account: admin@ecommerce.com / admin123
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
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email.trim(),
        'name': 'System Administrator',
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message;
    } catch (e) {
      _setLoading(false);
      return e.toString();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}
