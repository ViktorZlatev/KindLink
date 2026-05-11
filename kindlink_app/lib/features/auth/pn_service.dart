import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static bool _listenerRegistered = false;

  static Future<void> initAndSaveToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _messaging.getToken();
    if (token != null) {
      await _saveToken(user.uid, token);
    }

    // Register the refresh listener only once for the app's lifetime
    if (!_listenerRegistered) {
      _listenerRegistered = true;
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await _saveToken(currentUser.uid, newToken);
        }
      });
    }
  }

  static Future<void> _saveToken(String uid, String token) async {
    await FirebaseFirestore.instance.collection("users").doc(uid).set(
      {
        "fcmToken": token,
        "fcmUpdatedAt": FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
