import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Call this AFTER login (important)
  static Future<void> initAndSaveToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 1️⃣ Request permission (iOS / Android 13+)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2️⃣ Get FCM token
    final token = await _messaging.getToken();
    if (token == null) return;

    // 3️⃣ Save token to Firestore (per user)
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

    // 4️⃣ Handle token refresh
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
