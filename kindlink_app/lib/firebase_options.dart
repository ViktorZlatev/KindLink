import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';  // Import this for kIsWeb and defaultTargetPlatform

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // Web-specific configuration
      return const FirebaseOptions(

           apiKey: "AIzaSyCdG_AXq6cBT0iJXL1HgqbRf0864IOZ-ro",
           authDomain: "kindlink-d85cc.firebaseapp.com",
           databaseURL: "https://kindlink-d85cc-default-rtdb.europe-west1.firebasedatabase.app",
           projectId: "kindlink-d85cc",
           storageBucket: "kindlink-d85cc.firebasestorage.app",
           messagingSenderId: "490659735787",
           appId: "1:490659735787:web:771d82603ba4226836b6ae",
           measurementId: "G-63QCQ3ZZTH",

      );

    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Android-specific configuration
      return const FirebaseOptions(
        apiKey: "AIzaSyDumwqogdcStIYmgwsrdDH6jjWP18NlLnk",            
        appId: '1:490659735787:android:9147382afb1e333836b6ae',
        messagingSenderId: '490659735787',
        projectId: 'kindlink-d85cc',
        storageBucket: 'kindlink-d85cc.firebasestorage.app',

      );
    }
    throw UnsupportedError('Platform not supported');
  }
}
