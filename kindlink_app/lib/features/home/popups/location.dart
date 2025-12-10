import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showVolunteerLocationPermissionDialog(
  BuildContext context, {
  required VoidCallback onAllow,
  required VoidCallback onDeny,
}) {
  showDialog(
    context: context,
    barrierDismissible: false, // user must choose Allow or Deny
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on,
                size: 60,
                color: Color(0xFF6C63FF),
              ),
              const SizedBox(height: 16),

              Text(
                "Share your location",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6C63FF),
                ),
              ),

              const SizedBox(height: 12),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  children: const [
                    TextSpan(text: "Since you're now a volunteer, "),
                    TextSpan(
                      text: "we can show your real-time location",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: " to people who need your help.\n\n"),
                    TextSpan(
                      text: "Do you allow this?",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // ❌ Deny
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onDeny();
                    },
                    child: Text(
                      "Allow",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // ✅ Allow
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onAllow();
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
                      "Deny",
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
