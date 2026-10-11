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
          return 'Invalid email or password. Please verify your credentials and try again.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-disabled':
          return 'This user account has been disabled. Please contact customer support.';
        case 'too-many-requests':
          return 'Too many failed login attempts. Access is temporarily paused for security. Please try again later.';
        case 'operation-not-allowed':
          return 'Email/password sign-in is not enabled in Firebase Console. Please enable it in Authentication > Sign-in method.';
        case 'configuration-not-found':
          return 'Firebase Authentication is not activated in the Firebase project. Please enable Authentication in the Firebase Console.';
        case 'network-request-failed':
          return 'Network connection error. Please check your internet connection and try again.';
        case 'email-already-in-use':
          return 'An account already exists with this email address. Please sign in or use a different email.';
        case 'weak-password':
          return 'Password is too weak. Please choose a password with at least 6 characters.';
        default:
          return exception.message ?? 'Authentication failed (${exception.code}). Please try again.';
      }
    }
    return exception?.toString() ?? 'An unexpected authentication error occurred.';
  }

  /// Sign in with email and password
  Future<String?> signIn(String email, String password) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      return 'Please enter both email and password.';
    }

    _setLoading(true);
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: trimmedPassword,
      );

      // Self-heal: ensure user document exists in Firestore
      final uid = credential.user?.uid;
      if (uid != null) {
        try {
          final userDoc = await _firestore.collection('users').doc(uid).get();
          if (!userDoc.exists) {
            await _firestore.collection('users').doc(uid).set({
              'uid': uid,
              'name': credential.user?.displayName ?? 'Valued Customer',
              'email': credential.user?.email ?? trimmedEmail,
              'phone': '',
              'role': 'customer',
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        } catch (firestoreError) {
          if (kDebugMode) {
            debugPrint('Firestore profile verification warning: $firestoreError');
          }
        }
      }

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

  /// Register customer with Name, Email, Password, and optional phone
  Future<String?> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _setLoading(true);
    UserCredential? credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
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
      return mapFirebaseAuthError(e);
    } catch (e) {
      // Rollback newly created auth account if profile setup fails
      if (credential?.user != null) {
        try {
          await credential!.user!.delete();
        } catch (_) {
          await _auth.signOut();
        }
      }
      _setLoading(false);
      return 'Registration profile creation failed: $e';
    }
  }

  /// Send password reset email
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

  /// Update customer permitted profile fields (Name, Phone, Address)
  Future<String?> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return 'No user signed in.';
    final uid = user.uid;

    _setLoading(true);
    try {
      final docRef = _firestore.collection('users').doc(uid);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        // Document does not exist yet: create complete customer document
        await docRef.set({
          'uid': uid,
          'name': name != null && name.trim().isNotEmpty
              ? name.trim()
              : (user.displayName ?? 'Valued Customer'),
          'email': user.email ?? '',
          'phone': phone?.trim() ?? '',
          'address': address?.trim() ?? '',
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
        });
        if (name != null && name.trim().isNotEmpty) {
          await user.updateDisplayName(name.trim());
        }
      } else {
        final Map<String, dynamic> updates = {};
        if (name != null && name.trim().isNotEmpty) {
          updates['name'] = name.trim();
          await user.updateDisplayName(name.trim());
        }
        if (phone != null) {
          updates['phone'] = phone.trim();
        }
        if (address != null) {
          updates['address'] = address.trim();
        }

        if (updates.isNotEmpty) {
          await docRef.update(updates);
        }
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
