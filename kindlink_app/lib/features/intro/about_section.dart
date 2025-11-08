import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindlink/features/intro/navbar.dart';
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    return Scaffold(
      body: Column(
        children: [
          // ✅ Use shared Navbar
          Navbar(isMobile: isMobile),

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
                    const SizedBox(height: 80),

                    // ✅ Footer
                    Container(
                      width: double.infinity,
                      color: const Color(0xFF2E2E2E),
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "© 2025 KindLink • Made with ❤️ in Bulgaria",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
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

  // === INFO CARD ===
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
