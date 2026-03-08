import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initAndSaveToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _messaging.getToken();
    if (token == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .set(
      {
        "fcmToken": token,
        "fcmUpdatedAt": FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set(
        {
          "fcmToken": newToken,
          "fcmUpdatedAt": FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }
}
