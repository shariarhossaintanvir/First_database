import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:customer_app/services/auth_service.dart';

void main() {
  group('Customer AuthService Error Mapping Tests', () {
    test('maps invalid-credential and wrong-password to friendly guidance', () {
      final exc1 = FirebaseAuthException(code: 'invalid-credential');
      final exc2 = FirebaseAuthException(code: 'wrong-password');
      final exc3 = FirebaseAuthException(code: 'user-not-found');

      expect(
        AuthService.mapFirebaseAuthError(exc1),
        contains('Invalid email or password'),
      );
      expect(
        AuthService.mapFirebaseAuthError(exc2),
        contains('Invalid email or password'),
      );
      expect(
        AuthService.mapFirebaseAuthError(exc3),
        contains('Invalid email or password'),
      );
    });

    test('maps configuration-not-found to clear Firebase console guidance', () {
      final exc = FirebaseAuthException(code: 'configuration-not-found');
      expect(
        AuthService.mapFirebaseAuthError(exc),
        contains('Firebase Authentication is not activated in the Firebase project'),
      );
    });

    test('maps operation-not-allowed to sign-in provider guidance', () {
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

    test('maps user-disabled to support guidance', () {
      final exc = FirebaseAuthException(code: 'user-disabled');
      expect(
        AuthService.mapFirebaseAuthError(exc),
        contains('user account has been disabled'),
      );
    });

    test('maps too-many-requests to rate limit message', () {
      final exc = FirebaseAuthException(code: 'too-many-requests');
      expect(
        AuthService.mapFirebaseAuthError(exc),
        contains('Too many failed login attempts'),
      );
    });

    test('maps email-already-in-use and weak-password correctly', () {
      final exc1 = FirebaseAuthException(code: 'email-already-in-use');
      final exc2 = FirebaseAuthException(code: 'weak-password');

      expect(
        AuthService.mapFirebaseAuthError(exc1),
        contains('already exists with this email'),
      );
      expect(
        AuthService.mapFirebaseAuthError(exc2),
        contains('Password is too weak'),
      );
    });
  });

  group('Customer Email & Input Validation Regex Tests', () {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    test('validates standard email addresses correctly', () {
      expect(emailRegex.hasMatch('customer@example.com'), isTrue);
      expect(emailRegex.hasMatch('john.doe@sub.domain.co'), isTrue);
      expect(emailRegex.hasMatch('user+tag@domain.com'), isTrue);
    });

    test('rejects invalid email formats', () {
      expect(emailRegex.hasMatch('notanemail'), isFalse);
      expect(emailRegex.hasMatch('user@'), isFalse);
      expect(emailRegex.hasMatch('@domain.com'), isFalse);
      expect(emailRegex.hasMatch('user@domain'), isFalse);
      expect(emailRegex.hasMatch('user space@domain.com'), isFalse);
    });
  });
}
