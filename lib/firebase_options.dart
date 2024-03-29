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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC0sWgtQF_faGA_rpCCnPpq4J4P8VW7n0s',
    appId: '1:261182348696:android:33d21ee5122d4355355fed',
    messagingSenderId: '261182348696',
    projectId: 'block-squad-clash',
    databaseURL: 'https://block-squad-clash-default-rtdb.firebaseio.com',
    storageBucket: 'block-squad-clash.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCRjR1kokDHnVzlGrwv_jPyHL0LUaK5Tps',
    appId: '1:261182348696:ios:5548b42ddc717664355fed',
    messagingSenderId: '261182348696',
    projectId: 'block-squad-clash',
    databaseURL: 'https://block-squad-clash-default-rtdb.firebaseio.com',
    storageBucket: 'block-squad-clash.appspot.com',
    iosClientId: '261182348696-82uh5q980gumu0l1k6gnnfc7cncglmes.apps.googleusercontent.com',
    iosBundleId: 'com.example.bnrclash2022Blocksquad',
  );
}
