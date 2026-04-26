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
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBe6AyIF25zRiteJjpCljulOvN4yf8khjU',
    appId: '1:46640280742:web:2714cc9cb428939e873067',
    messagingSenderId: '46640280742',
    projectId: 'space-explorer-c6b1e',
    authDomain: 'space-explorer-c6b1e.firebaseapp.com',
    storageBucket: 'space-explorer-c6b1e.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBe6AyIF25zRiteJjpCljulOvN4yf8khjU',
    appId: '1:46640280742:web:2714cc9cb428939e873067',
    messagingSenderId: '46640280742',
    projectId: 'space-explorer-c6b1e',
    storageBucket: 'space-explorer-c6b1e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBe6AyIF25zRiteJjpCljulOvN4yf8khjU',
    appId: '1:46640280742:web:2714cc9cb428939e873067',
    messagingSenderId: '46640280742',
    projectId: 'space-explorer-c6b1e',
    storageBucket: 'space-explorer-c6b1e.firebasestorage.app',
    iosBundleId: 'com.example.spaceExplorer',
  );
}
