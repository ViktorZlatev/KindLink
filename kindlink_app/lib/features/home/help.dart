import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class HelpRequestService {
  /// Sends a global "immediate help" request.
  /// The doc is created in the top-level `help_requests` collection.
  static Future<void> sendImmediateHelpRequest({
    required Function(String) onError,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      onError("You must be logged in to request help.");
      return;
    }

    try {
      // Load some user info (optional but nice)
      final userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userSnap.data() ?? {};

      await FirebaseFirestore.instance
          .collection('help_requests')
          .add({
        'userId': user.uid,
        'username': userData['username'] ?? user.email,
        'location': userData['location'], // may be null
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'open',
      });
    } catch (e) {
      debugPrint("Error sending help request: $e");
      onError("Failed to send help request.");
    }
  }
}
