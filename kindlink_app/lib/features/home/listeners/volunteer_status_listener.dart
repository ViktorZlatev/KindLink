import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class VolunteerStatusListener {
  StreamSubscription<DocumentSnapshot>? _sub;

  void start({
    required bool initialIsVolunteer,
    required String initialStatus,
    required void Function() onBecameVolunteer,
    required void Function(String status) onStatusChanged,
  }) {
    _sub?.cancel();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    bool prevIsVolunteer = initialIsVolunteer;
    String prevStatus = initialStatus;

    _sub = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snap) {
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;

      final newIsVolunteer = data['isVolunteer'] == true;
      final newStatus = (data['VolunteerStatus'] as String?) ?? '';

      if (!prevIsVolunteer && newIsVolunteer) {
        prevIsVolunteer = true;
        prevStatus = newStatus;
        onBecameVolunteer();
        return;
      }

      if (newStatus != prevStatus) {
        prevStatus = newStatus;
        onStatusChanged(newStatus);
      }

      prevIsVolunteer = newIsVolunteer;
    }, onError: (e) {
      debugPrint('VolunteerStatusListener error: $e');
    });
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
