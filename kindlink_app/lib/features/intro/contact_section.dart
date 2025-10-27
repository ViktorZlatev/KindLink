import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// if you need _infoCard or copy it here

class ContactSection extends StatelessWidget {
  final bool isMobile;
  const ContactSection({super.key, required this.isMobile });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
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
              color: const Color(0xFF3A3A3A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            "Have questions, feedback, or want to become a volunteer? "
            "We’d love to hear from you! Reach out via email or through our contact form below.",
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
        ],
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
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(icon, size: 44, color: const Color(0xFF6C63FF)),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF3A3A3A),
            ),
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
