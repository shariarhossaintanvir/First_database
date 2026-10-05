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

  /// Sign in with email and password
  Future<String?> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message ?? 'Login failed. Please check credentials.';
    } catch (e) {
      _setLoading(false);
      return 'Unexpected error: $e';
    }
  }

  /// Register customer with Name, Email, Password, and optional phone
  Future<String?> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _setLoading(true);
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = credential.user!.uid;

      // Update user display name in FirebaseAuth
      await credential.user!.updateDisplayName(name.trim());

      // Save customer profile in Firestore
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone?.trim() ?? '',
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message ?? 'Registration failed.';
    } catch (e) {
      _setLoading(false);
      return 'Unexpected error: $e';
    }
  }

  /// Update customer permitted profile fields (Name, Phone, Address)
  Future<String?> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 'No user signed in.';

    _setLoading(true);
    try {
      final Map<String, dynamic> updates = {};
      if (name != null && name.trim().isNotEmpty) {
        updates['name'] = name.trim();
        await _auth.currentUser?.updateDisplayName(name.trim());
      }
      if (phone != null) {
        updates['phone'] = phone.trim();
      }
      if (address != null) {
        updates['address'] = address.trim();
      }

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(uid).update(updates);
      }

      _setLoading(false);
      return null;
    } on FirebaseException catch (e) {
      _setLoading(false);
      return e.message ?? 'Failed to update profile.';
    } catch (e) {
      _setLoading(false);
      return 'Unexpected error: $e';
    }
  }

  /// Get customer profile stream from Firestore
  Stream<DocumentSnapshot> getUserProfileStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _firestore.collection('users').doc(uid).snapshots();
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}
