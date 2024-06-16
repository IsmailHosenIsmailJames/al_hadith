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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyCMa_ctyGiOVNjFQNsSRn3DzEZJ_My8w-0',
    appId: '1:564254338567:web:923d106629a80d6e4604a2',
    messagingSenderId: '564254338567',
    projectId: 'alhadithmultilanguage',
    authDomain: 'alhadithmultilanguage.firebaseapp.com',
    databaseURL: 'https://alhadithmultilanguage-default-rtdb.firebaseio.com',
    storageBucket: 'alhadithmultilanguage.appspot.com',
    measurementId: 'G-R5DMVYRWS0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAsfOJe8Tzr3f55afJ6OUU4Frr3Tac50LI',
    appId: '1:564254338567:android:b158bef5a43893774604a2',
    messagingSenderId: '564254338567',
    projectId: 'alhadithmultilanguage',
    databaseURL: 'https://alhadithmultilanguage-default-rtdb.firebaseio.com',
    storageBucket: 'alhadithmultilanguage.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDLRpJOzrYaRpnWb0HrVDQMaxZyWYEKqs0',
    appId: '1:564254338567:ios:9efc06de2ea27e554604a2',
    messagingSenderId: '564254338567',
    projectId: 'alhadithmultilanguage',
    databaseURL: 'https://alhadithmultilanguage-default-rtdb.firebaseio.com',
    storageBucket: 'alhadithmultilanguage.appspot.com',
    iosBundleId: 'com.example.alHadith',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDLRpJOzrYaRpnWb0HrVDQMaxZyWYEKqs0',
    appId: '1:564254338567:ios:9efc06de2ea27e554604a2',
    messagingSenderId: '564254338567',
    projectId: 'alhadithmultilanguage',
    databaseURL: 'https://alhadithmultilanguage-default-rtdb.firebaseio.com',
    storageBucket: 'alhadithmultilanguage.appspot.com',
    iosBundleId: 'com.example.alHadith',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCMa_ctyGiOVNjFQNsSRn3DzEZJ_My8w-0',
    appId: '1:564254338567:web:49c3392e1767bd404604a2',
    messagingSenderId: '564254338567',
    projectId: 'alhadithmultilanguage',
    authDomain: 'alhadithmultilanguage.firebaseapp.com',
    databaseURL: 'https://alhadithmultilanguage-default-rtdb.firebaseio.com',
    storageBucket: 'alhadithmultilanguage.appspot.com',
    measurementId: 'G-ZBEMHT3K1V',
  );
}
