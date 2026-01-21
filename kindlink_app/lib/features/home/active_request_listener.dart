import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActiveHelpRequestListener {
  StreamSubscription<QuerySnapshot>? _subscription;

  void start({
    required void Function({
      String? requestId,
      String? status,
    }) onChanged,
  }) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _subscription?.cancel();

    _subscription = FirebaseFirestore.instance
        .collection("help_requests")
        .where("status", whereIn: [
          "accepted",
          "closed_once",
          "resolved",
        ])
        .where(
          Filter.or(
            Filter("userId", isEqualTo: user.uid),
            Filter("acceptedVolunteerId", isEqualTo: user.uid),
          ),
        )
        .limit(1)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isEmpty) {
            onChanged(requestId: null, status: null);
            return;
          }

          final doc = snapshot.docs.first;
          final status = doc.data()["status"];

          // ✅ FORCE UI CLEAR WHEN RESOLVED
          if (status == "resolved") {
            onChanged(requestId: null, status: null);
            return;
          }

          onChanged(
            requestId: doc.id,
            status: status,
          );
        });
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
