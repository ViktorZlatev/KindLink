import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showEmergencyDialog(
  BuildContext context, {
  required bool surveyCompleted,
  required Future<void> Function() onConfirm, // 🔥 async
}) {
  final List<String> bulletPoints = surveyCompleted
      ? [
          'Notifies volunteers who best match your personal profile.',
          'Uses our AI system to identify the most suitable volunteers.',
          'Ensures faster and more effective emergency assistance.',
        ]
      : [
          'For urgent situations only.',
          'Alerts multiple nearby volunteers instantly.',
          'Use only if someone needs immediate help.',
        ];

  showDialog(
    context: context,
    barrierDismissible: false, // 🔒 prevent dismiss while sending
    builder: (context) {
      bool isSending = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 30),
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
                    Icons.warning_amber_rounded,
                    color: Color(0xFF6C63FF),
                    size: 60,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Emergency Use Only',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6C63FF),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: bulletPoints
                        .map(
                          (point) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF6C63FF),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    point,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: Colors.black87,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: isSending
                            ? null
                            : () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                   ElevatedButton(
                    onPressed: isSending
                        ? null
                        : () async {
                            setState(() => isSending = true);

                            try {
                              await onConfirm(); // Firestore + AI call

                              if (!context.mounted) return;
                              Navigator.pop(context); // ✅ close ONLY on success
                            } catch (e) {
                              // ✅ keep dialog open so user can retry
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Failed to send signal. Please try again.",
                                    style: GoogleFonts.poppins(),
                                  ),
                                ),
                              );

                              setState(() => isSending = false); // ✅ re-enable button
                            }
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
                          elevation: 4,
                        ),
                        child: isSending
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(
                            'Send Signal',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
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
    },
  );
}
