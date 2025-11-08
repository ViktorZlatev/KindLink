import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindlink/features/intro/navbar.dart'; // ✅ make sure you have this shared navbar file

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: Column(
        children: [
          // ✅ Shared Navbar
          Navbar(isMobile: isMobile),

          // ✅ Contact Content
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 60,
                  vertical: 60,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Get in Touch",
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 28 : 36,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF6C63FF),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Have questions, feedback, or want to become a volunteer? "
                      "Reach out via email or through our contact form below.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 16 : 18,
                        color: Colors.grey.shade700,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ✅ Contact Info Cards
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        _infoCard(
                          icon: Icons.email_outlined,
                          title: "Email",
                          text: "contact@kindlink.org",
                        ),
                        _infoCard(
                          icon: Icons.phone_outlined,
                          title: "Phone",
                          text: "+359 123 456 789",
                        ),
                        _infoCard(
                          icon: Icons.location_on_outlined,
                          title: "Address",
                          text: "Sofia, Bulgaria",
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Reusable Contact Info Card
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
