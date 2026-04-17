import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class HelpListenerService {
  StreamSubscription<QuerySnapshot>? _sub;

  void startListening({
    required bool isVolunteer,
    required bool isUser,

    required void Function(String requestId, Map<String, dynamic> data)
        onNewRequest,

    required void Function(String requestId, Map<String, dynamic> data)
        onVolunteerHelpAccepted,

    required void Function(String requestId, Map<String, dynamic> data)
        onVolunteerPendingForUser,
  }) {
    _sub?.cancel();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // VOLUNTEER LISTENER

    if (isVolunteer) {
      _sub = FirebaseFirestore.instance
          .collection("help_requests")
          .where(
            "status",
            whereIn: ["awaiting_volunteer", "accepted"],
          )
          .where("currentVolunteerId", isEqualTo: currentUser.uid)
          .snapshots()
          .listen((snapshot) {
        for (final change in snapshot.docChanges) {
          if (change.type != DocumentChangeType.added &&
              change.type != DocumentChangeType.modified) {
            continue;
          }

          final doc = change.doc;
          final data = doc.data() ?? <String, dynamic>{};
          final status = data["status"];

          if (status == "awaiting_volunteer") {
            onNewRequest(doc.id, data);
            continue;
          }

          if (status == "accepted" &&
              data["acceptedVolunteerId"] == currentUser.uid &&
              data["volunteerNotified"] != true) {

            onVolunteerHelpAccepted(doc.id, data);

            FirebaseFirestore.instance
                .collection("help_requests")
                .doc(doc.id)
                .update({
              "volunteerNotified": true,
            });
          }
        }
      }, onError: (e) {
        debugPrint("HelpListener (volunteer) error: $e");
      });

      return;
    }

    // REQUESTER LISTENER

    if (isUser) {
      _sub = FirebaseFirestore.instance
          .collection("help_requests")
          .where("userId", isEqualTo: currentUser.uid)
          .snapshots()
          .listen((snapshot) {
        for (final change in snapshot.docChanges) {
          if (change.type != DocumentChangeType.added &&
              change.type != DocumentChangeType.modified) {
            continue;
          }

          final doc = change.doc;
          final data = doc.data() ?? <String, dynamic>{};

          if (data["status"] == "pending" &&
              data["userNotified"] != true) {
            onVolunteerPendingForUser(doc.id, data);

            FirebaseFirestore.instance
                .collection("help_requests")
                .doc(doc.id)
                .update({"userNotified": true});
          }
        }
      }, onError: (e) {
        debugPrint("HelpListener (user) error: $e");
      });
    }
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
