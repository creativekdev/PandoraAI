// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyAcUdLaHARvG_iEL6kDpwCrpToTYwaZjB8',
    appId: '1:480445344807:web:d428872cf1d311c1db7202',
    messagingSenderId: '480445344807',
    projectId: 'socialbook-v2',
    authDomain: 'socialbook-v2.firebaseapp.com',
    storageBucket: 'socialbook-v2.appspot.com',
    measurementId: 'G-Y4K8P3S5W5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB40Pkh8-4g74wtX3PJi9OHeGic1XskB6w',
    appId: '1:480445344807:android:ba78d3d26112c7dedb7202',
    messagingSenderId: '480445344807',
    projectId: 'socialbook-v2',
    storageBucket: 'socialbook-v2.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCH5G9ObNcqAI9pHOO5HHlP5_8vDJg8l8I',
    appId: '1:480445344807:ios:1aa76525f92df934db7202',
    messagingSenderId: '480445344807',
    projectId: 'socialbook-v2',
    storageBucket: 'socialbook-v2.appspot.com',
    androidClientId: '480445344807-ujpe6ae0psmalrg037ba24mt0hb877hc.apps.googleusercontent.com',
    iosClientId: '480445344807-rf0eqjks97qatv7m090rsu6hmc34uuav.apps.googleusercontent.com',
    iosBundleId: 'io.socialbook.cartoonizer',
  );
}
