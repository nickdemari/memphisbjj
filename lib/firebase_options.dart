// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAG_hG-2MmpW3QoaR6Iv9_wXjZM6VS9xCg',
    appId: '1:928741701529:web:910ba7b058a7ab16028508',
    messagingSenderId: '928741701529',
    projectId: 'memphis-bjj',
    authDomain: 'memphis-bjj.firebaseapp.com',
    databaseURL: 'https://memphis-bjj.firebaseio.com',
    storageBucket: 'memphis-bjj.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD-iVQ5L9C8-di3G8dCN20dskWQ6ku--W4',
    appId: '1:928741701529:android:18e23e3a36f4eb5c',
    messagingSenderId: '928741701529',
    projectId: 'memphis-bjj',
    databaseURL: 'https://memphis-bjj.firebaseio.com',
    storageBucket: 'memphis-bjj.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBOTo-XkQYgMRPcr-AjWc-op7vQ1hYWpA4',
    appId: '1:928741701529:ios:18e23e3a36f4eb5c',
    messagingSenderId: '928741701529',
    projectId: 'memphis-bjj',
    databaseURL: 'https://memphis-bjj.firebaseio.com',
    storageBucket: 'memphis-bjj.appspot.com',
    androidClientId:
        '928741701529-qetg15v2u16829oleslpkcta220o8og1.apps.googleusercontent.com',
    iosClientId:
        '928741701529-dtvq21uprbjf797m4sefv384akvff979.apps.googleusercontent.com',
    iosBundleId: 'com.demarily.memphisbjj',
  );
}
