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
    required void Function(String id, Map<String, dynamic> data) onVolunteerAccepted,
  }) {
    _sub?.cancel();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // ---------------------------------------------
    // VOLUNTEER: listen only to requests assigned to them
    // ---------------------------------------------
    if (isVolunteer) {
      _sub = FirebaseFirestore.instance
          .collection("help_requests")
          .where("status", isEqualTo: "awaiting_volunteer")
          .where("currentVolunteerId", isEqualTo: currentUser.uid)
          .snapshots()
          .listen((snapshot) {
        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added ||
              change.type == DocumentChangeType.modified) {
            final doc = change.doc;
            final data = doc.data() ?? <String, dynamic>{};
            onNewRequest(doc.id, data);
          }
        }
      }, onError: (e) {
        debugPrint("HelpListener error: $e");
      });

      return;
    }

    // ---------------------------------------------
    // REQUESTER: see when their request becomes pending (accepted)
    // ---------------------------------------------
    if (isUser) {
      _sub = FirebaseFirestore.instance
          .collection("help_requests")
          .where("userId", isEqualTo: currentUser.uid)
          .orderBy("createdAt", descending: true)
          .snapshots()
          .listen((snapshot) {
        for (final change in snapshot.docChanges) {
          final doc = change.doc;
          final data = doc.data() ?? <String, dynamic>{};

          if (data["status"] == "pending") {
            onVolunteerAccepted(doc.id, data);
          }
        }
      }, onError: (e) {
        debugPrint("HelpListener error: $e");
      });
    }
  }

  void dispose() => _sub?.cancel();
}
