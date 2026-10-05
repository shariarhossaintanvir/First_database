import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'providers/cart_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';

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
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB),
            primary: const Color(0xFF2563EB),
            secondary: const Color(0xFF3B82F6),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF0F172A),
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
    final auth = Provider.of<AuthService>(context);

    return StreamBuilder(
      stream: auth.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const MainNavigationScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
