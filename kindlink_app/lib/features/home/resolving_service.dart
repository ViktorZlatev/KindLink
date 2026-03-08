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

    
    final bool closedByUser = data["closedByUser"] == true;
    final bool closedByVolunteer = data["closedByVolunteer"] == true;

    final update = <String, dynamic>{};

    
    if (isVolunteer) {
      if (closedByVolunteer) return; 
      update["closedByVolunteer"] = true;
    } else {
      if (closedByUser) return;
      update["closedByUser"] = true;
    }

   
    final bool userNowClosed =
        (!isVolunteer && true) || closedByUser;

    final bool volunteerNowClosed =
        (isVolunteer && true) || closedByVolunteer;

    
    if (status == "accepted") {
      update["status"] = "closed_once";
      update["closedOnceAt"] = FieldValue.serverTimestamp();
    }

    
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
