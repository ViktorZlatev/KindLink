import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class Navbar extends StatelessWidget {
  final bool isMobile;
  const Navbar({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 40,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1D29).withOpacity(0.85),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo
                GestureDetector(
                  onTap: () => Navigator.pushNamedAndRemoveUntil(
                      context, '/', (_) => false),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7B74FF), Color(0xFF5B54E6)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.volunteer_activism,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "KindLink",
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 20 : 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                if (!isMobile)
                  Row(
                    children: [
                      _navItem(context, "Home", '/'),
                      _navItem(context, "About", '/about'),
                      _navItem(context, "Contact", '/contact'),
                      const SizedBox(width: 24),
                      _outlinedButton(context, "Log In", '/login'),
                      const SizedBox(width: 12),
                      _ctaButton(context, "Sign Up", '/signup'),
                    ],
                  )
                else
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () => _showMobileMenu(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                          ),
                        ),
                        child: const Icon(
                          Icons.menu_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _navItem(BuildContext context, String title, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  static Widget _outlinedButton(
      BuildContext context, String text, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withOpacity(0.18),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.85),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  static Widget _ctaButton(BuildContext context, String text, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7B74FF), Color(0xFF5B54E6)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  static void _showMobileMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close menu",
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  bottomLeft: Radius.circular(32),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1D29).withOpacity(0.97),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF7B74FF),
                                            Color(0xFF5B54E6)
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.volunteer_activism,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "KindLink",
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.08),
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 48),
                            _mobileNavItem(context,
                                icon: Icons.home_rounded,
                                title: "Home",
                                route: '/'),
                            const SizedBox(height: 12),
                            _mobileNavItem(context,
                                icon: Icons.info_outline_rounded,
                                title: "About",
                                route: '/about'),
                            const SizedBox(height: 12),
                            _mobileNavItem(context,
                                icon: Icons.mail_outline_rounded,
                                title: "Contact",
                                route: '/contact'),
                            const SizedBox(height: 32),
                            Divider(color: Colors.white.withOpacity(0.08)),
                            const SizedBox(height: 24),
                            _mobileAuthItem(context,
                                icon: Icons.login_rounded,
                                title: "Log In",
                                route: '/login',
                                outlined: true),
                            const SizedBox(height: 12),
                            _mobileAuthItem(context,
                                icon: Icons.person_add_alt_1_rounded,
                                title: "Sign Up",
                                route: '/signup',
                                outlined: false),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondary, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position:
                Tween(begin: const Offset(1, 0), end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  static Widget _mobileNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF7B74FF), size: 20),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _mobileAuthItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required bool outlined,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: outlined
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF7B74FF), Color(0xFF5B54E6)],
                ),
          borderRadius: BorderRadius.circular(20),
          border: outlined
              ? Border.all(color: Colors.white.withOpacity(0.15))
              : null,
          boxShadow: outlined
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Row(
          children: [
            Icon(icon,
                color: outlined
                    ? Colors.white.withOpacity(0.7)
                    : Colors.white,
                size: 20),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
