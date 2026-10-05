import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase App Check for admin portal protection against bots and automated abuse
  try {
    if (kIsWeb) {
      // On Web/localhost, activate only when a real reCAPTCHA v3 site key is provided via --dart-define=RECAPTCHA_V3_KEY=...
      // Avoid placeholder keys which cause network fetch failures and block localhost development.
      const String webRecaptchaKey = String.fromEnvironment('RECAPTCHA_V3_KEY');
      if (webRecaptchaKey.isNotEmpty) {
        await FirebaseAppCheck.instance.activate(
          providerWeb: ReCaptchaV3Provider(webRecaptchaKey),
        );
      }
    } else {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: kDebugMode
            ? const AndroidDebugProvider()
            : const AndroidPlayIntegrityProvider(),
        providerApple: kDebugMode
            ? const AppleDebugProvider()
            : const AppleDeviceCheckProvider(),
      );
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('App Check initialization warning: $e');
    }
  }

  runApp(const AdminEcommerceApp());
}

class AdminEcommerceApp extends StatelessWidget {
  const AdminEcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthService())],
      child: MaterialApp(
        title: 'Admin E-Commerce Portal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E293B),
            primary: const Color(0xFF0F172A),
            secondary: const Color(0xFF2563EB),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Color(0xFF0F172A),
            foregroundColor: Colors.white,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        // Server-side & Firestore role-based gate verification
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, userDocSnap) {
            if (userDocSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Verifying administrator authorization...',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              );
            }

            bool isAdmin = false;
            if (userDocSnap.hasData && userDocSnap.data?.exists == true) {
              final data = userDocSnap.data!.data() as Map<String, dynamic>?;
              if (data?['role'] == 'admin') {
                isAdmin = true;
              }
            }

            // Fallback for master administrator email
            if (user.email?.toLowerCase() == 'admin@ecommerce.com') {
              isAdmin = true;
            }

            // If non-admin user (e.g. customer) attempts to access admin portal
            if (!isAdmin) {
              return Scaffold(
                backgroundColor: const Color(0xFFF1F5F9),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.gpp_bad,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Access Denied',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'The account "${user.email}" does not have administrator privileges to access this system.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => authService.signOut(),
                                icon: const Icon(Icons.logout),
                                label: const Text('Sign Out & Return to Login'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F172A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            return const DashboardScreen();
          },
        );
      },
    );
  }
}
