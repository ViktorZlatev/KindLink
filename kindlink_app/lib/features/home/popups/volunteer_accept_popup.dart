import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showVolunteerAcceptedPopup(
  BuildContext context, {
  required String requestId,
  required Map<String, dynamic> data,
}) {
  final requesterName = data["username"] ?? "The requester";

  final location = data["location"] as Map<String, dynamic>?;
  final lat = location?["lat"];
  final lng = location?["lng"];

  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        backgroundColor: const Color(0xFF13131A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 56,
                color: Color(0xFF6C63FF),
              ),

              const SizedBox(height: 16),

              Text(
                "Your help was accepted!",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6C63FF),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                "$requesterName has accepted your offer.\nYou can now proceed to help.",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.85),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              if (lat != null && lng != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1D29),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6C63FF).withOpacity(0.25),
                    ),
                  ),
                  child: Column(
                    children: [
                      _row(Icons.location_on, "Latitude: $lat"),
                      const SizedBox(height: 6),
                      _row(Icons.location_on_outlined, "Longitude: $lng"),
                    ],
                  ),
                ),

              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Continue",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
      Icon(icon, color: const Color(0xFF6C63FF)),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.85),
          ),
        ),
      ),
    ],
  );
}
