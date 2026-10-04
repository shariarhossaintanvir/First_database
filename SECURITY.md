# Security Policy & Hardening Documentation

## 1. Project Security Architecture & Defense-in-Depth

This project consists of:
1. **Customer Flutter App** (Public store, customer catalog, profile, and order placement)
2. **Admin Flutter App** (Restricted administrative dashboard, product/category management, order fulfillment)
3. **Shared Firebase Project** (Cloud Firestore, Firebase Authentication, Firebase Storage, and Firebase App Check)

### Core Security Boundary
- The **Flutter client UI is NOT considered a security boundary**.
- All authorization decisions, data validation, and write restrictions are strictly enforced at the **Firebase Security Rules layer** (Firestore & Storage).
- Neither application trusts client-supplied identity, roles, or authorization flags.

---

## 2. Sensitive File & Credential Protection

### Git Tracking & `.gitignore`
A comprehensive root `.gitignore` is enforced to prevent accidental leakage of sensitive credentials:
- **Environment variables**: `.env`, `.env.*` (only `.env.example` with dummy values is committed)
- **Service Accounts & Admin SDK Keys**: `*service-account*.json`, `*admin-sdk*.json`
- **Keystores & Signing Keys**: `*.keystore`, `*.jks`, `key.properties`, `local.properties`
- **Build & Ephemeral Files**: `.dart_tool/`, `build/`, `.flutter-plugins-dependencies`

### Firebase Client vs. Backend Credentials
- **Client Configuration**: `google-services.json` and `firebase_options.dart` only contain public client identifiers (`apiKey`, `appId`, `projectId`, `storageBucket`) necessary for FlutterFire client initialization.
- **Admin Secrets**: No Firebase Admin SDK private keys, service account credentials, or server-side secrets are ever included in the Flutter client codebases.

---

## 3. Cloud Firestore Security Rules

Cloud Firestore is protected by production-grade security rules defined in `firestore.rules`:

### Customer Access Permissions
- **Categories & Products**: Publicly readable (`allow read: if true;`) to allow catalog browsing.
- **Product Management**: Restricted strictly to authorized administrators (`isAdmin()`). Customers cannot create, update, or delete products or categories.
- **User Profiles**: Customers can only read and update their own document (`request.auth.uid == userId`). Self-promotion to `admin` is explicitly rejected.
- **Orders**:
  - Customers can read only their own orders (`resource.data.userId == request.auth.uid`).
  - Customers can create orders only for themselves (`request.resource.data.userId == request.auth.uid`).
  - New orders require status `'Pending'` and adhere to schema constraints.
  - Customers cannot modify or delete existing orders.

### Administrator Access Permissions
- Admin privileges are verified via:
  1. Firebase Auth custom claims (`request.auth.token.admin == true`), or
  2. Firestore verified user document (`users/{uid}` role == `'admin'`), or
  3. Master administrative identity (`admin@ecommerce.com`).
- Only administrators can update order status (`'Pending'`, `'Processing'`, `'Shipped'`, `'Delivered'`, `'Cancelled'`).
- Critical order fields (`userId`, `createdAt`, `totalAmount`, `items`, `customerEmail`) remain strictly immutable during updates.

### DoS & Data Integrity Protections
- **List Limits**: Maximum 50 items per order to prevent document bloat and memory exhaustion.
- **String Limits**: Names (1–100 chars), Emails (valid RFC 5322 regex, 3–100 chars), Descriptions (1–3000 chars), Phone numbers (5–30 chars), Addresses (5–500 chars).
- **Numeric Bounds**: Prices and totals constrained to valid non-negative ranges.
- **Default Deny**: All unspecified paths default to `allow read, write: if false;`.

---

## 4. Firebase Storage Security Rules

Storage is secured via `storage.rules`:
- **Product Images (`/products/{fileName}`)**:
  - Publicly readable for customer display.
  - Writes (create/update) permitted **only for authorized administrators**.
  - MIME type restriction: Only `image/jpeg`, `image/png`, `image/webp`, and `image/gif` are accepted.
  - File size restriction: Maximum 5MB (5,242,880 bytes).
  - Deletions permitted **only for administrators**.
- **Default Deny**: All other storage paths reject read and write operations.

---

## 5. Firebase App Check & Bot Mitigation

Firebase App Check is activated at application initialization in both apps:
- **Web**: reCAPTCHA v3 provider (`ReCaptchaV3Provider`)
- **Android**: Play Integrity provider in production (`AndroidPlayIntegrityProvider`), debug provider in development (`AndroidDebugProvider`)
- **Apple**: DeviceCheck provider in production (`AppleDeviceCheckProvider`), debug provider in development (`AppleDebugProvider`)

This mitigates automated bots, scraping scripts, and replay attacks targeting Firestore and Storage endpoints.

---

## 6. Query Optimization & Read Limits

To mitigate resource exhaustion and unbounded billing reads:
- All Firestore streams enforce `.limit()` constraints (50–100 documents per query).
- Product and order queries enforce indexed sorting (`orderBy('createdAt', descending: true)`).
- Customer order streams filter strictly on authenticated UID (`where('userId', isEqualTo: userId)`).

---

## 7. Error Handling & Information Disclosure

- Technical stack traces, internal database paths, and Firebase internal exceptions are suppressed in release mode.
- User-facing error messages are sanitized to provide safe, actionable feedback without leaking backend details.

---

## 8. Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it privately:
- **Email**: security@ecommerce.com
- Do **not** open public GitHub issues for security vulnerabilities.
- Include detailed reproduction steps and affected components.
- You can expect an initial response within 24 hours.
