import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class Navbar extends StatelessWidget {
  final bool isMobile;
  const Navbar({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 40,
              vertical: 18,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0E8),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: const Color.fromARGB(255, 23, 11, 11).withOpacity(0.1), 
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "KindLink",
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 22 : 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF14151F),
                    letterSpacing: -0.5,
                  ),
                ),
                if (!isMobile)
                  Row(
                    children: [
                      _navItem(context, "Home", '/'),
                      _navItem(context, "About", '/about'),
                      _navItem(context, "Contact", '/contact'),
                      const SizedBox(width: 30),
                      _ctaButton(context, "Login", '/login'),
                    ],
                  )
                else
                 Builder(
                  builder: (context) => GestureDetector(
                    onTap: () => _showMobileMenu(context),
                    child: const Icon(
                      Icons.menu_rounded,
                      color:Color(0xFF14151F),
                      size: 28,
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

  static Widget _navItem(
      BuildContext context, String title, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  static Widget _ctaButton(
      BuildContext context, String text, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7B74FF), Color(0xFF5B54E6)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.5),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
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
    barrierColor: Colors.black.withOpacity(0.35),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, anim1, anim2) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.82,
            height: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(36),
                bottomLeft: Radius.circular(36),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.10),
                        Colors.white.withOpacity(0.03),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 1.2,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 50),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // CLOSE BUTTON
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.08),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.15),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 60),

                          _premiumMobileItem(
                            context,
                            icon: Icons.home_rounded,
                            title: "Home",
                            route: '/',
                          ),
                          const SizedBox(height: 24),

                          // SIGN UP — Primary Action
                          _premiumAuthItem(
                            context,
                            icon: Icons.person_add_alt_1_rounded,
                            title: "Sign Up",
                            route: '/signup',
                            
                          ),
                          const SizedBox(height: 24),

                          _premiumAuthItem(
                            context,
                            icon: Icons.login_rounded,
                            title: "Log In",
                            route: '/login',
                            
                          ),
                          const SizedBox(height: 24),

                          _premiumMobileItem(
                            context,
                            icon: Icons.info_outline_rounded,
                            title: "About",
                            route: '/about',
                          ),
                          const SizedBox(height: 24),

                          _premiumMobileItem(
                            context,
                            icon: Icons.mail_outline_rounded,
                            title: "Contact",
                            route: '/contact',
                          ),
                        
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
          position: Tween(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

static Widget _premiumMobileItem(
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.06),
          border: Border.all(
            color: Colors.white.withOpacity(0.12),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6C63FF).withOpacity(0.15),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF7B74FF),
                size: 22,
              ),
            ),
            const SizedBox(width: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

 
 static Widget _premiumAuthItem(
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
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 146, 140, 247),
              Color(0xFFABA6F1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.45),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.18),
              ),
              child: Icon(
                icon,
                size: 22,
                color: const Color(0xFF14151F),
              ),
            ),
            const SizedBox(width: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF14151F),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
