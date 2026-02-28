import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: 'AIzaSyC_example_key',
    appId: '1:123456789:android:abcdef1234567',
    messagingSenderId: '123456789',
    projectId: 'flutter-app-1',
    databaseURL: 'https://flutter-app-1.firebaseio.com',
    storageBucket: 'flutter-app-1.appspot.com',
    iosBundleId: 'com.example.flutterApplication1',
  );
}
