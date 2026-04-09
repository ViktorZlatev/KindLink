import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

void showVolunteerHelpPopup(
  BuildContext context, {
  required String requestId,
  required Map<String, dynamic> data,
}) {
  final requesterName = data["username"] ?? "Someone";
  final status = data["status"] ?? "open";

  showDialog(
    context: context,
    barrierDismissible: true,
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
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFF6C63FF),
                  size: 42,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                "Immediate Help Needed!",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6C63FF),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "$requesterName requested urgent help.",
                style: GoogleFonts.poppins(fontSize: 15, color: Colors.white.withOpacity(0.85)),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Text(
                "Status: $status",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.55),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  TextButton(
                    onPressed: () async {
                      Navigator.of(context, rootNavigator: true).pop();

                      try {
                        final callable = FirebaseFunctions.instance
                            .httpsCallable('rejectHelpRequest');

                        await callable.call({
                          'requestId': requestId,
                        });
                      } on FirebaseFunctionsException catch (e) {
                        debugPrint(
                          'rejectHelpRequest failed: ${e.code} — ${e.message}',
                        );
                      } catch (e) {
                        debugPrint('Unexpected error rejecting request: $e');
                      }
                    },
                    child: Text(
                      "Reject",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context, rootNavigator: true).pop();

                      final v = FirebaseAuth.instance.currentUser;
                      if (v == null) return;

                      final doc = await FirebaseFirestore.instance
                          .collection("help_requests")
                          .doc(requestId)
                          .get();

                      if (!doc.exists) return;

                      final data = doc.data()!;
                      if (data["status"] != "awaiting_volunteer") return;
                      if (data["currentVolunteerId"] != v.uid) return;

                      final userDoc = await FirebaseFirestore.instance
                          .collection("users")
                          .doc(v.uid)
                          .get();

                      final volunteerName =
                          userDoc.data()?["username"] ?? "Volunteer";

                      await FirebaseFirestore.instance
                          .collection("help_requests")
                          .doc(requestId)
                          .update({
                        "status": "pending",
                        "volunteerId": v.uid,
                        "volunteerName": volunteerName ?? "Volunteer",
                        "acceptedAt": FieldValue.serverTimestamp(),
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
