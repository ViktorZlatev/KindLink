import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> showAcceptedPopupUser(
  BuildContext context, {
  required String requestId,
  required Map<String, dynamic> data,
}) async {
  final volunteerName = data["volunteerName"] ?? "A volunteer";
  final volunteerId = data["volunteerId"] as String?;

  String? photoUrl;
  String? skills;
  String? experience;
  String? education;
  String? motivation;

  if (volunteerId != null) {
    try {
      final userSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(volunteerId)
          .get();
      photoUrl = userSnap.data()?["profilePhotoUrl"];

      final formSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(volunteerId)
          .collection("volunteer_forms")
          .where("status", isEqualTo: "accepted")
          .limit(1)
          .get();

      if (formSnap.docs.isNotEmpty) {
        final form = formSnap.docs.first.data();
        skills = form["skills"] as String?;
        experience = form["experience"] as String?;
        education = form["education"] as String?;
        motivation = form["motivation"] as String?;
      }
    } catch (_) {}
  }

  if (!context.mounted) return;
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 26, vertical: 36),
        backgroundColor: const Color(0xFF13131A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // Header
                CircleAvatar(
                  radius: 42,
                  backgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.12),
                  backgroundImage:
                      photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null
                      ? const Icon(Icons.volunteer_activism,
                          size: 42, color: Color(0xFF6C63FF))
                      : null,
                ),

                const SizedBox(height: 14),

                Text(
                  volunteerName,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6C63FF),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 4),

                Text(
                  "is offering to help you!",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Divider
                Container(
                  width: 48,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                const SizedBox(height: 20),

                // Details card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1D29),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailRow(
                        Icons.medical_services_outlined,
                        "Experience",
                        experience,
                      ),
                      if (experience != null) const SizedBox(height: 12),
                      _detailRow(
                        Icons.star_outline_rounded,
                        "Skills",
                        skills,
                      ),
                      if (skills != null) const SizedBox(height: 12),
                      _detailRow(
                        Icons.school_outlined,
                        "Education",
                        education,
                      ),
                      if (education != null) const SizedBox(height: 12),
                      _detailRow(
                        Icons.favorite_outline_rounded,
                        "Motivation",
                        motivation,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons
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
                          color: Colors.white.withValues(alpha: 0.45),
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
                          horizontal: 32,
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 6,
                      ),
                      child: Text(
                        "Accept Help",
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
        ),
      );
    },
  );
}

Widget _detailRow(IconData icon, String label, String? value) {
  if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: const Color(0xFF6C63FF), size: 18),
      const SizedBox(width: 10),
      Expanded(
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "$label: ",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              TextSpan(
                text: value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
