import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'theme/admin_theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/products_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/customers_screen.dart';
import 'screens/add_edit_product_screen.dart';
import 'screens/not_found_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase App Check for admin portal protection against bots and automated abuse
  try {
    if (kIsWeb) {
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
        title: 'ShopEase Admin Operations',
        debugShowCheckedModeBanner: false,
        theme: AdminTheme.darkTheme,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case '/products':
              page = const AuthGate(destination: ProductsScreen());
              break;
            case '/categories':
              page = const AuthGate(destination: CategoriesScreen());
              break;
            case '/orders':
              page = const AuthGate(destination: OrdersScreen());
              break;
            case '/customers':
              page = const AuthGate(destination: CustomersScreen());
              break;
            case '/add-product':
              page = const AuthGate(destination: AddEditProductScreen());
              break;
            case '/login':
              page = const LoginScreen();
              break;
            case '/':
            case '/dashboard':
              page = const AuthGate(destination: DashboardScreen());
              break;
            default:
              page = AdminNotFoundScreen(route: settings.name);
              break;
          }
          return MaterialPageRoute(
            builder: (_) => page,
            settings: settings,
          );
        },
        onUnknownRoute: (settings) => MaterialPageRoute(
          settings: settings,
          builder: (_) => AdminNotFoundScreen(route: settings.name),
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  final Widget? destination;
  const AuthGate({super.key, this.destination});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AdminTheme.bgWorkspace,
            body: Center(
              child: CircularProgressIndicator(color: AdminTheme.accent),
            ),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        // Real-time server-side & Firestore role-based gate verification
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userDocSnap) {
            if (userDocSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: AdminTheme.bgWorkspace,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AdminTheme.accent),
                      SizedBox(height: 16),
                      Text(
                        'Verifying administrator credentials...',
                        style: TextStyle(color: AdminTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (userDocSnap.hasError) {
              return Scaffold(
                backgroundColor: AdminTheme.bgWorkspace,
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Card(
                        color: AdminTheme.surfaceCard,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: AdminTheme.borderSubtle),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.cloud_off,
                                size: 56,
                                color: AdminTheme.statusWarning,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Verification Error',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AdminTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Unable to verify administrative authorization: ${userDocSnap.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AdminTheme.textMuted,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => authService.signOut(),
                                icon: const Icon(Icons.logout, size: 16),
                                label: const Text('Return to Login'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AdminTheme.accent,
                                  foregroundColor: AdminTheme.bgSidebar,
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

            bool isAdmin = false;
            if (userDocSnap.hasData && userDocSnap.data?.exists == true) {
              final data = userDocSnap.data!.data() as Map<String, dynamic>?;
              if (data?['role'] == 'admin') {
                isAdmin = true;
              }
            }

            // If non-admin user (e.g. customer) attempts to access admin portal
            if (!isAdmin) {
              return Scaffold(
                backgroundColor: AdminTheme.bgWorkspace,
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Card(
                        color: AdminTheme.surfaceCard,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: AdminTheme.borderSubtle),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.gpp_bad_outlined,
                                size: 56,
                                color: AdminTheme.statusError,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Access Restricted',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AdminTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'The account "${user.email}" does not have administrator privileges to access this console.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AdminTheme.textMuted,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => authService.signOut(),
                                icon: const Icon(Icons.logout, size: 16),
                                label: const Text('Sign Out & Return to Login'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AdminTheme.accent,
                                  foregroundColor: AdminTheme.bgSidebar,
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

            return destination ?? const DashboardScreen();
          },
        );
      },
    );
  }
}
