import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showEmergencyDialog(
  BuildContext context, {
  required bool surveyCompleted,
  required VoidCallback onConfirm,
}) {
  // Messages shown based on whether user completed survey
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

  // ✅ FIX #1 — Use showDialog() instead of showGeneralDialog()
  // This prevents UI flicker / button movement / map redraw issues.
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        // Optional: semi-transparent background
        insetPadding: const EdgeInsets.symmetric(horizontal: 30),
        backgroundColor: Colors.white.withOpacity(0.95),

        // rounded corners
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

              // bullet points
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: bulletPoints
                    .map(
                      (point) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // bullet icon
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

                            // text
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

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
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
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6C63FF),
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
                    child: Text(
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
}
