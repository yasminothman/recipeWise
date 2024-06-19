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
        return macos;
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
    apiKey: 'AIzaSyAlv-V8zB1SQ3lf4PIn2z2bZo_QkFBjfL0',
    appId: '1:123396758600:web:9b7af75f0bfe8d86804c7d',
    messagingSenderId: '123396758600',
    projectId: 'recipewise-3ef87',
    authDomain: 'recipewise-3ef87.firebaseapp.com',
    storageBucket: 'recipewise-3ef87.appspot.com',
    measurementId: 'G-J8H86P3JD2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB_fiB5fmBtDhONJ7Aoutcoay_yxfk-r_M',
    appId: '1:123396758600:android:f2fe1cf2ea1d49c4804c7d',
    messagingSenderId: '123396758600',
    projectId: 'recipewise-3ef87',
    storageBucket: 'recipewise-3ef87.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyASeqAkmU7Ujqj91QU1927YOFebEvou5Vg',
    appId: '1:123396758600:ios:50b4b5e80e9903a3804c7d',
    messagingSenderId: '123396758600',
    projectId: 'recipewise-3ef87',
    storageBucket: 'recipewise-3ef87.appspot.com',
    iosBundleId: 'com.example.recipewise',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyASeqAkmU7Ujqj91QU1927YOFebEvou5Vg',
    appId: '1:123396758600:ios:af89295a6cd4e795804c7d',
    messagingSenderId: '123396758600',
    projectId: 'recipewise-3ef87',
    storageBucket: 'recipewise-3ef87.appspot.com',
    iosBundleId: 'com.example.recipewise.RunnerTests',
  );
}
