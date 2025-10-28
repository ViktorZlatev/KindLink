import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutSection extends StatelessWidget {
  final bool isMobile;
  const AboutSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ✅ Full NAVBAR from your home_page.dart
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 14 : 44,
              vertical: isMobile ? 12 : 20,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EAE2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "KindLink",
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 22 : 30,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E2E2E),
                    letterSpacing: -0.5,
                  ),
                ),
                if (!isMobile)
                  Row(
                    children: [
                      _navButton("Home", () {
                        Navigator.pushNamed(context, '/');
                      }),
                      _navButton("About", () {
                        Navigator.pushNamed(context, '/about');
                      }),
                      _navButton("Contact", () {
                        Navigator.pushNamed(context, '/contact');
                      }),
                      const SizedBox(width: 28),
                      _primaryButton(
                        text: "Login",
                        filled: true,
                        onTap: () => Navigator.pushNamed(context, '/login'),
                      ),
                      const SizedBox(width: 12),
                      _primaryButton(
                        text: "Sign Up",
                        filled: false,
                        onTap: () => Navigator.pushNamed(context, '/signup'),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      _primaryButton(
                        text: "Login",
                        filled: true,
                        onTap: () => Navigator.pushNamed(context, '/login'),
                        small: true,
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {}, // Add mobile menu later
                        child: const Icon(
                          Icons.menu_rounded,
                          size: 28,
                          color: Color(0xFF3A3A3A),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // ✅ Page content
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF5F0E8),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 60,
                  vertical: 60,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "About KindLink",
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 28 : 36,
                        fontWeight: FontWeight.w800,
                        color: const Color.fromARGB(255, 161, 107, 241),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "KindLink is a community-driven platform that connects volunteers with people in need. "
                      "Its mission is to make kindness visible and accessible, empowering everyone to lend a hand, share their skills, and positively impact their local communities.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 16 : 18,
                        color: Colors.grey.shade700,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        _infoCard(
                          icon: Icons.lightbulb_outline,
                          title: "Our Vision",
                          text:
                              "A world where helping others is easy, safe, and rewarding for everyone.",
                        ),
                        _infoCard(
                          icon: Icons.group_outlined,
                          title: "Our Community",
                          text:
                              "Thousands of volunteers and people in need, coming together every day.",
                        ),
                        _infoCard(
                          icon: Icons.security_outlined,
                          title: "Safety & Trust",
                          text:
                              "Verified volunteers and secure connections keep the community safe.",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Reused button widgets
  Widget _navButton(String title, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 17,
              color: const Color(0xFF4A4A4A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String text,
    required bool filled,
    required VoidCallback onTap,
    bool small = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: small ? 14 : 20,
          vertical: small ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: filled ? const Color(0xFF6C63FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF6C63FF), width: 2),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: filled ? Colors.white : const Color(0xFF6C63FF),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 44, color: const Color(0xFF6C63FF)),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
