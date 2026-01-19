import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showVolunteerAcceptedPopup(
  BuildContext context, {
  required String requestId,
  required Map<String, dynamic> data,
}) {
  final requesterName = data["username"] ?? "The requester";

  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        backgroundColor: Colors.white.withOpacity(0.97),
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
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();

                  // 👉 OPTIONAL NEXT STEP:
                  // Navigate to map / chat / request details
                  // Example:
                  // Navigator.pushNamed(context, '/active_request', arguments: requestId);
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
