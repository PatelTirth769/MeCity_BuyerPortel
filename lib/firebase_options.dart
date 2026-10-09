import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDemoApiKeyForTheMeEcosystemApp123456",
    appId: "1:115191360224885139904:web:fbsvc6bf24020f9",
    messagingSenderId: "115191360224885139904",
    projectId: "the-me-a05f7",
    authDomain: "the-me-a05f7.firebaseapp.com",
    storageBucket: "the-me-a05f7.appspot.com",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDemoApiKeyForTheMeEcosystemApp123456",
    appId: "1:115191360224885139904:android:fbsvc6bf24020f9",
    messagingSenderId: "115191360224885139904",
    projectId: "the-me-a05f7",
    storageBucket: "the-me-a05f7.appspot.com",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyDemoApiKeyForTheMeEcosystemApp123456",
    appId: "1:115191360224885139904:ios:fbsvc6bf24020f9",
    messagingSenderId: "115191360224885139904",
    projectId: "the-me-a05f7",
    storageBucket: "the-me-a05f7.appspot.com",
    iosBundleId: "com.mecity.app",
  );
}
