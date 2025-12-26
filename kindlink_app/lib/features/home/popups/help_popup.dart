import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

void showVolunteerHelpPopup(
  BuildContext context, {
  required String requestId,
  required Map<String, dynamic> data,
}) {
  final volunteer = FirebaseAuth.instance.currentUser;

  final requesterName = data["username"] ?? "Someone";
  final status = data["status"] ?? "open";

  final location = data["location"] as Map<String, dynamic>?;
  final lat = location?["lat"];
  final lng = location?["lng"];

  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.45),

    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        backgroundColor: Colors.white.withOpacity(0.97),
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
                  color: Color(0xFFEDE8FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_amber_rounded,
                    color: Color(0xFF6C63FF), size: 42),
              ),

              const SizedBox(height: 16),

              Text(
                "Immediate Help Needed!",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6C63FF),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "$requesterName requested urgent help.",
                style: GoogleFonts.poppins(fontSize: 15),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              if (lat != null && lng != null)
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF6F0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Color(0xFF6C63FF).withOpacity(0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      _row(Icons.location_on, "Lat: $lat"),
                      SizedBox(height: 6),
                      _row(Icons.location_on_outlined, "Lng: $lng"),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              Text(
                "Status: $status",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  // REJECT
                  TextButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: Text(
                      "Reject",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // ACCEPT
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context, rootNavigator: true).pop();

                      final doc = await FirebaseFirestore.instance
                          .collection("help_requests")
                          .doc(requestId)
                          .get();

                      if (!doc.exists) return;

                      if (doc.data()!["status"] != "open") return;

                      await FirebaseFirestore.instance
                          .collection("help_requests")
                          .doc(requestId)
                          .update({
                        "status": "pending",
                        "volunteerId": volunteer?.uid,
                        "volunteerName":
                            volunteer?.email ?? "Volunteer",
                        "acceptedAt": FieldValue.serverTimestamp(),
                      });
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
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
                  )
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _row(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, color: Color(0xFF6C63FF)),
      SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}
