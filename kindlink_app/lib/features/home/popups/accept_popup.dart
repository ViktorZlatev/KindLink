import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void showAcceptedPopupUser(
  BuildContext context, {
  required String requestId,
  required Map<String, dynamic> data,
}) {
  final volunteerName = data["volunteerName"] ?? "A volunteer";
  final volunteerId = data["volunteerId"]; 

  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        backgroundColor: const Color(0xFF13131A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.volunteer_activism,
                size: 50,
                color: Color(0xFF6C63FF),
              ),

              const SizedBox(height: 16),

              Text(
                "$volunteerName is offering to help you!",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6C63FF),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context, rootNavigator: true).pop();

                      await FirebaseFirestore.instance
                          .collection("help_requests")
                          .doc(requestId)
                          .update({
                        "status": "open",
                        "volunteerId": null,
                        "volunteerName": null,
                        "currentVolunteerId": null,
                        "acceptedVolunteerId": null,
                        "acceptedAt": null,
                        "userNotified": false,
                      });
                    },
                    child: Text(
                      "Reject",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.55),
                      ),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: volunteerId == null
                        ? null
                        : () async {
                            Navigator.of(context, rootNavigator: true).pop();

                            await FirebaseFirestore.instance
                                .collection("help_requests")
                                .doc(requestId)
                                .update({
                              "status": "accepted",
                              "acceptedVolunteerId": volunteerId,
                              "acceptedAt": FieldValue.serverTimestamp(),
                              "resolved": false,
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "Accept",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
