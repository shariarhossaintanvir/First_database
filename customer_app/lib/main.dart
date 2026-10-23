import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'providers/cart_provider.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/terms_conditions_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase App Check to reduce automated abuse and unauthorized clients
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

  runApp(const CustomerEcommerceApp());
}

class CustomerEcommerceApp extends StatelessWidget {
  const CustomerEcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'ShopEase Customer Store',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case '/':
              page = const AuthGate();
              break;
            case '/home':
              page = const AuthGate(
                destination: MainNavigationScreen(initialIndex: 0),
              );
              break;
            case '/categories':
              page = const AuthGate(
                destination: MainNavigationScreen(initialIndex: 1),
              );
              break;
            case '/cart':
              page = const AuthGate(
                destination: MainNavigationScreen(initialIndex: 2),
              );
              break;
            case '/orders':
              page = const AuthGate(
                destination: MainNavigationScreen(initialIndex: 3),
              );
              break;
            case '/profile':
              page = const AuthGate(
                destination: MainNavigationScreen(initialIndex: 4),
              );
              break;
            case '/login':
              page = const LoginScreen();
              break;
            case '/register':
              page = const RegisterScreen();
              break;
            case '/privacy':
            case '/privacy-policy':
              page = const PrivacyPolicyScreen();
              break;
            case '/terms':
            case '/terms-and-conditions':
              page = const TermsConditionsScreen();
              break;
            default:
              page = NotFoundScreen(route: settings.name);
              break;
          }
          return MaterialPageRoute(
            builder: (_) => page,
            settings: settings,
          );
        },
        onUnknownRoute: (settings) => MaterialPageRoute(
          settings: settings,
          builder: (_) => NotFoundScreen(route: settings.name),
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
    final auth = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: auth.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return destination ?? const MainNavigationScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
