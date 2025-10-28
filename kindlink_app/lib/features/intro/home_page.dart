import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // NAVBAR
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 14 : 44,
                  vertical: isMobile ? 12 : 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EEE6), // Coconut dirty white
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
                            onTap: () => _showMobileMenu(context),
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

              // HERO SECTION
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 600),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFF5F0E8),
                      Color.fromARGB(255, 143, 94, 242),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Empowering Kindness\nConnecting Hearts.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 34 : 48,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Join a growing community of people who care.\nKindLink connects volunteers and those in need — safely and instantly.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 16 : 18,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // FEATURES SECTION
              Container(
                color: const Color.fromARGB(255, 143, 94, 242),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 60,
                  vertical: 48,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    _infoCard(
                      icon: Icons.volunteer_activism_outlined,
                      title: "Help Nearby",
                      text:
                          "Find and support people in your local area who need a helping hand.",
                    ),
                    _infoCard(
                      icon: Icons.verified_outlined,
                      title: "Trusted & Safe",
                      text:
                          "Verified volunteers and transparent feedback create a secure community.",
                    ),
                    _infoCard(
                      icon: Icons.map_outlined,
                      title: "Real-Time Map",
                      text:
                          "Discover nearby opportunities instantly with our Sofia map integration.",
                    ),
                  ],
                ),
              ),

              // FOOTER
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
    );
  }

  // === MOBILE MENU ===
  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text("Home"),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, '/');
                  },
                ),
                ListTile(
                  title: const Text("About"),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, '/about');
                  },
                ),
                ListTile(
                  title: const Text("Contact"),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, '/contact');
                  },
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: const Text("Login"),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text("Sign Up"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  // === NAV BUTTON ===
  Widget _navButton(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
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

  // === PRIMARY BUTTON ===
  Widget _primaryButton({
    required String text,
    required bool filled,
    required VoidCallback onTap,
    bool big = false,
    bool small = false,
  }) {
    final horizontal = big ? 40.0 : (small ? 12.0 : 26.0);
    final vertical = big ? 16.0 : (small ? 8.0 : 12.0);

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
          decoration: BoxDecoration(
            color: filled ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border:
                Border.all(color: filled ? Colors.transparent : Colors.white, width: 2),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(2, 3),
                    ),
                  ]
                : [],
          ),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: filled ? const Color(0xFF6C63FF) : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: big ? 18 : 15,
            ),
          ),
        ),
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
