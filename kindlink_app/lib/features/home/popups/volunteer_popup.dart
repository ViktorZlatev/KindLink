import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> showVolunteerPopupCustom(
  BuildContext context, {
  required String userId,
  required double lat,
  required double lng,
}) async {
  String name = "Unknown";
  String experience = "Not provided";
  String skills = "Not provided";

  try {
    final forms = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("volunteer_forms")
        .where("status", isEqualTo: "accepted")
        .limit(1)
        .get();

    if (forms.docs.isNotEmpty) {
      final data = forms.docs.first.data();
      name = data["name"] ?? name;
      experience = data["experience"] ?? experience;
      skills = data["skills"] ?? skills;
    }
  } catch (_) {}

  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.4),

    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        backgroundColor: Colors.white.withOpacity(0.95),
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
                child: Icon(Icons.volunteer_activism,
                    size: 42, color: Color(0xFF6C63FF)),
              ),

              const SizedBox(height: 15),

              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C63FF),
                ),
              ),

              const SizedBox(height: 10),

              Container(
                width: 50,
                height: 3,
                decoration: BoxDecoration(
                  color: Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF6F0),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Color(0xFF6C63FF).withOpacity(0.15),
                  ),
                ),
                child: Column(
                  children: [
                    _infoRow(Icons.school, "Experience: $experience"),
                    SizedBox(height: 8),
                    _infoRow(Icons.star, "Skills: $skills"),
                    SizedBox(height: 8),
                    _infoRow(Icons.location_on, "Lat: $lat"),
                    SizedBox(height: 8),
                    _infoRow(Icons.location_on_outlined, "Lng: $lng"),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Close",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}

Widget _infoRow(IconData ic, String text) {
  return Row(
    children: [
      Icon(ic, color: Color(0xFF6C63FF)),
      SizedBox(width: 10),
      Expanded(
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}
