import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthBrandPanel extends StatelessWidget {
  final VoidCallback onBack;
  const AuthBrandPanel({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D0D12),
      child: Stack(
        children: [
          // Central glow
          Positioned(
            top: 100,
            left: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6C63FF).withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF5B54E6).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthBackButton(onTap: onBack, light: true),
                  const Spacer(),

                  // Logo
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B83FF), Color(0xFF5B54E6)],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withOpacity(0.45),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.volunteer_activism,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(height: 28),

                  // Brand name
                  Text(
                    "KindLink",
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Connecting volunteers\nwith people in need.\nMaking kindness visible.",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.45),
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 52),

                  // Feature pills
                  _Pill(
                    icon: Icons.verified_user_outlined,
                    text: "Verified & safe community",
                  ),
                  const SizedBox(height: 14),
                  _Pill(
                    icon: Icons.map_outlined,
                    text: "Real-time map of requests",
                  ),
                  const SizedBox(height: 14),
                  _Pill(
                    icon: Icons.bolt_outlined,
                    text: "Instant connections",
                  ),

                  const Spacer(),
                  Text(
                    "© 2026 KindLink",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Pill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF6C63FF).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(icon, color: const Color(0xFF8B83FF), size: 17),
        ),
        const SizedBox(width: 14),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white.withOpacity(0.55),
          ),
        ),
      ],
    );
  }
}

class AuthBackButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool light;
  const AuthBackButton({super.key, required this.onTap, this.light = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: light
                ? Colors.white.withOpacity(0.1)
                : const Color(0xFFE0DEFF),
            width: 1,
          ),
          color: light
              ? Colors.white.withOpacity(0.05)
              : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              size: 15,
              color: light
                  ? Colors.white.withOpacity(0.6)
                  : const Color(0xFF6C63FF),
            ),
            const SizedBox(width: 6),
            Text(
              "Back",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: light
                    ? Colors.white.withOpacity(0.6)
                    : const Color(0xFF6C63FF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
