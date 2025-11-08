import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Navbar extends StatelessWidget {
  final bool isMobile;
  const Navbar({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 44,
        vertical: isMobile ? 12 : 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EEE6), // same as home page
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
          // Logo / App title
          Text(
            "KindLink",
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 22 : 30,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2E2E2E),
              letterSpacing: -0.5,
            ),
          ),

          // --- Desktop menu ---
          if (!isMobile)
            Row(
              children: [
                _navButton("Home", () => Navigator.pushNamed(context, '/')),
                _navButton("About", () => Navigator.pushNamed(context, '/about')),
                _navButton("Contact", () => Navigator.pushNamed(context, '/contact')),
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
          // --- Mobile menu ---
          else
            Row(
              children: [
                _primaryButton(
                  text: "Login",
                  filled: true,
                  onTap: () => Navigator.pushNamed(context, '/login'),
                  small: true,
                ),
                const SizedBox(width: 7),
                _primaryButton(
                  text: "Sign Up",
                  filled: true,
                  onTap: () => Navigator.pushNamed(context, '/signup'),
                  small: true,
                ),
                const SizedBox(width: 12),
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
    );
  }

  // === NAV BUTTON ===
  static Widget _navButton(String title, VoidCallback onTap) {
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
  static Widget _primaryButton({
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
            color: filled ? const Color(0xFF6C63FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border:
                Border.all(color: filled ? Colors.transparent : const Color(0xFF6C63FF), width: 2),
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
              color: filled ? Colors.white : const Color(0xFF6C63FF),
              fontWeight: FontWeight.w700,
              fontSize: big ? 18 : 15,
            ),
          ),
        ),
      ),
    );
  }

  // === MOBILE MENU ===
  static void _showMobileMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Menu",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.45,
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 242, 240, 238),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(-4, 4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded, size: 30, color: Color(0xFF6C63FF)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 10),

                      _menuItem(context, Icons.home_rounded, "Home", '/'),
                      _menuItem(context, Icons.info_outline_rounded, "About", '/about'),
                      _menuItem(context, Icons.mail_outline_rounded, "Contact", '/contact'),
                      const Spacer(),
                      
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  // === MENU ITEM ===
  static Widget _menuItem(BuildContext context, IconData icon, String text, String route) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6C63FF), size: 26),
      title: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Color(0xFF333333),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }
}
