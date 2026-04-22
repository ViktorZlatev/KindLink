import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ActiveHelpRequestListener {
  StreamSubscription<QuerySnapshot>? _subscription;

  void start({
    required bool isVolunteer,
    required void Function({
      String? requestId,
      String? status,
    }) onChanged,
  }) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _subscription?.cancel();

    // Use a single-field equality filter based on role to avoid
    // composite index requirements from Filter.or() + whereIn.
    final field = isVolunteer ? "acceptedVolunteerId" : "userId";

    _subscription = FirebaseFirestore.instance
        .collection("help_requests")
        .where(field, isEqualTo: user.uid)
        .where("status", whereIn: ["accepted", "closed_once"])
        .limit(1)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isEmpty) {
            onChanged(requestId: null, status: null);
            return;
          }

          final doc = snapshot.docs.first;
          onChanged(requestId: doc.id, status: doc.data()["status"]);
        }, onError: (e) {
          debugPrint("ActiveRequestListener error: $e");
          onChanged(requestId: null, status: null);
        });
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
