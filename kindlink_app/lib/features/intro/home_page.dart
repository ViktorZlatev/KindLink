import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindlink/features/intro/navbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    return Scaffold(
      backgroundColor: Color(0xFFF5F0E8),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Navbar(isMobile: isMobile),

              // ===== HERO SECTION =====
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 650),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFF5F0E8),
                      Color(0xFF6C63FF),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    // Soft radial glow
                    Positioned(
                      top: -120,
                      left: -100,
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFFF5F0E8),  
                              const Color.fromARGB(255, 98, 78, 158).withOpacity(0.15),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 100),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Empowering Kindness\nConnecting Hearts",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 34 : 56,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.15,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            "KindLink connects volunteers and people in need.\nSafe. Instant. Human.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 17 : 20,
                              color: Colors.white.withOpacity(0.8),
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Premium CTA
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF7B74FF),
                                  Color(0xFF5B54E6),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6C63FF)
                                      .withOpacity(0.4),
                                  blurRadius: 30,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 48, vertical: 22),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                              onPressed: () {},
                              child: Text(
                                "Get Started",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ===== FEATURES =====
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 80,
                  vertical: 80,
                ),
                color: Color(0xFF6C63FF),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 30,
                  runSpacing: 30,
                  children: [
                    _premiumCard(
                      icon: Icons.volunteer_activism_outlined,
                      title: "Help Nearby",
                      text:
                          "Support people in your local area with verified requests.",
                    ),
                    _premiumCard(
                      icon: Icons.verified_outlined,
                      title: "Trusted & Safe",
                      text:
                          "Identity checks and community ratings ensure safety.",
                    ),
                    _premiumCard(
                      icon: Icons.map_outlined,
                      title: "Real-Time Map",
                      text:
                          "Find nearby opportunities instantly with smart location.",
                    ),
                  ],
                ),
              ),

              // ===== FOOTER =====
              Container(
                color: const Color(0xFF0D0D12),
                padding: const EdgeInsets.all(28),
                child: Text(
                  "© 2026 KindLink • Made in Bulgaria",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _premiumCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1D29),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: const Color(0xFF6C63FF)),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.6,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
