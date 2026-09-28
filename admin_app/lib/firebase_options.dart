// File generated for Admin App connecting to e-commerce-3552a
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDQUoWcLx01OVEynIaQdcJh69YpJoBhj6U',
    appId: '1:445633938306:web:82e2bdd6736f81b2ea459b',
    messagingSenderId: '445633938306',
    projectId: 'e-commerce-3552a',
    authDomain: 'e-commerce-3552a.firebaseapp.com',
    storageBucket: 'e-commerce-3552a.firebasestorage.app',
    measurementId: 'G-QQV54M8PY8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCo8gcu3iJnuUcLOLt4cmp2uhhVRoCtEY4',
    appId: '1:445633938306:android:349d4dcd2a8233adea459b',
    messagingSenderId: '445633938306',
    projectId: 'e-commerce-3552a',
    storageBucket: 'e-commerce-3552a.firebasestorage.app',
  );
}
