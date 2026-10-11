import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admin_app/services/auth_service.dart';

void main() {
  group('Admin AuthService Error Mapping Tests', () {
    test('maps invalid-credential and wrong-password to friendly admin guidance', () {
      final exc1 = FirebaseAuthException(code: 'invalid-credential');
      final exc2 = FirebaseAuthException(code: 'wrong-password');
      final exc3 = FirebaseAuthException(code: 'user-not-found');

      expect(
        AuthService.mapFirebaseAuthError(exc1),
        contains('Invalid admin email or password'),
      );
      expect(
        AuthService.mapFirebaseAuthError(exc2),
        contains('Invalid admin email or password'),
      );
      expect(
        AuthService.mapFirebaseAuthError(exc3),
        contains('Invalid admin email or password'),
      );
    });

    test('maps configuration-not-found to Firebase Console instruction', () {
      final exc = FirebaseAuthException(code: 'configuration-not-found');
      expect(
        AuthService.mapFirebaseAuthError(exc),
        contains('Firebase Authentication is not activated in the Firebase project'),
      );
    });

    test('maps operation-not-allowed to console sign-in provider instruction', () {
      final exc = FirebaseAuthException(code: 'operation-not-allowed');
      expect(
        AuthService.mapFirebaseAuthError(exc),
        contains('Email/password sign-in is not enabled in Firebase Console'),
      );
    });

    test('maps network-request-failed to network connection error', () {
      final exc = FirebaseAuthException(code: 'network-request-failed');
      expect(
        AuthService.mapFirebaseAuthError(exc),
        contains('Network connection error'),
      );
    });

    test('maps user-disabled to system engineering guidance', () {
      final exc = FirebaseAuthException(code: 'user-disabled');
      expect(
        AuthService.mapFirebaseAuthError(exc),
        contains('administrator account has been disabled'),
      );
    });

    test('maps too-many-requests to lock message', () {
      final exc = FirebaseAuthException(code: 'too-many-requests');
      expect(
        AuthService.mapFirebaseAuthError(exc),
        contains('Too many failed login attempts'),
      );
    });
  });

  group('Admin Email & Input Validation Regex Tests', () {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    test('validates master admin and standard admin emails correctly', () {
      expect(emailRegex.hasMatch('admin@ecommerce.com'), isTrue);
      expect(emailRegex.hasMatch('superadmin@ecommerce.com'), isTrue);
    });

    test('rejects malformed admin emails', () {
      expect(emailRegex.hasMatch('admin'), isFalse);
      expect(emailRegex.hasMatch('admin@'), isFalse);
      expect(emailRegex.hasMatch('admin@ecommerce'), isFalse);
    });
  });
}
