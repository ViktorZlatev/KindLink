import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> closeHelpRequest({
  required String requestId,
  required bool isVolunteer,
}) async {
  final ref =
      FirebaseFirestore.instance.collection("help_requests").doc(requestId);

  await FirebaseFirestore.instance.runTransaction((tx) async {
    final snap = await tx.get(ref);
    if (!snap.exists) return;

    final data = snap.data()!;
    final status = data["status"];

    if (status != "accepted" && status != "closed_once") return;

    // Existing values from Firestore
    final bool closedByUser = data["closedByUser"] == true;
    final bool closedByVolunteer = data["closedByVolunteer"] == true;

    final update = <String, dynamic>{};

    // ✅ Update ONLY the side that clicked
    if (isVolunteer) {
      if (closedByVolunteer) return; // prevent double click
      update["closedByVolunteer"] = true;
    } else {
      if (closedByUser) return;
      update["closedByUser"] = true;
    }

    // Updated values after this click
    final bool userNowClosed =
        (!isVolunteer && true) || closedByUser;

    final bool volunteerNowClosed =
        (isVolunteer && true) || closedByVolunteer;

    // FIRST CLOSE
    if (status == "accepted") {
      update["status"] = "closed_once";
      update["closedOnceAt"] = FieldValue.serverTimestamp();
    }

    // SECOND CLOSE → RESOLVED
    if (userNowClosed && volunteerNowClosed) {
      update.addAll({
        "status": "resolved",
        "resolved": true,
        "resolvedAt": FieldValue.serverTimestamp(),
      });
    }

    tx.update(ref, update);
  });
}
