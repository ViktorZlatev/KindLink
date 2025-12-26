import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class HelpListenerService {
  StreamSubscription<QuerySnapshot>? _sub;

  void startListening({
    required bool isVolunteer,
    required bool isUser,
    required void Function(String id, Map<String, dynamic> data) onNewRequest,
    required void Function(String id, Map<String, dynamic> data)
        onVolunteerAccepted,
  }) {
    // stop previous listener if any
    _sub?.cancel();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    _sub = FirebaseFirestore.instance
        .collection("help_requests")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        for (final change in snapshot.docChanges) {
          final doc = change.doc;
          final data = doc.data() ?? <String, dynamic>{};
          final id = doc.id;

          // --------------------------------------------------
          // 1) VOLUNTEER → sees NEW "open" requests
          //    (only on added)
          // --------------------------------------------------
          if (isVolunteer &&
              change.type == DocumentChangeType.added &&
              data["status"] == "open") {
            onNewRequest(id, data);
          }

          // --------------------------------------------------
          // 2) REQUESTER → sees "pending" for THEIR own request
          //    (added OR modified → we don't care)
          // --------------------------------------------------
          if (isUser &&
              data["status"] == "pending" &&
              data["userId"] == currentUser.uid) {
            onVolunteerAccepted(id, data);
          }
        }
      },
      onError: (e) {
        debugPrint("HelpListener error: $e");
      },
    );
  }

  void dispose() => _sub?.cancel();
}
