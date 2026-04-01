import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindlink/features/intro/navbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Navbar(isMobile: isMobile),
              _HeroSection(isMobile: isMobile),
              _StatsRow(isMobile: isMobile),
              _FeaturesSection(isMobile: isMobile),
              _Footer(isMobile: isMobile),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────── HERO ──────────────────────────────

class _HeroSection extends StatelessWidget {
  final bool isMobile;
  const _HeroSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0D0D12),
      child: Stack(
        children: [
          // Central radial glow from below
          Positioned(
            bottom: -120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 900,
                height: 500,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF6C63FF).withOpacity(0.13),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Top-right subtle glow
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6C63FF).withOpacity(0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 80,
              vertical: isMobile ? 80 : 130,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Eyebrow badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: const Color(0xFF6C63FF).withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF8B83FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Community-driven volunteering platform",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF8B83FF),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Headline
                Column(
                  children: [
                    Text(
                      "Give back to your",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 42 : 80,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.0,
                        letterSpacing: -2.5,
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF9B8FFF), Color(0xFF5B54E6)],
                      ).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        "community.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 42 : 80,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.05,
                          letterSpacing: -2.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Subheadline
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Text(
                    "KindLink connects volunteers and people in need — safe, instant, and deeply human.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 15 : 18,
                      color: Colors.white.withOpacity(0.45),
                      height: 1.7,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // CTAs
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, '/signup'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B83FF), Color(0xFF5B54E6)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C63FF).withOpacity(0.4),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Text(
                          "Get started free",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, '/about'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 17),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Learn more",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.65),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: Colors.white.withOpacity(0.65),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────── STATS ──────────────────────────────

class _StatsRow extends StatelessWidget {
  final bool isMobile;
  const _StatsRow({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 0,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 48,
          vertical: 32,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF13131A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
            width: 1,
          ),
        ),
        child: isMobile
            ? Wrap(
                alignment: WrapAlignment.center,
                spacing: 32,
                runSpacing: 24,
                children: const [
                  _StatItem(number: "5,000+", label: "Volunteers"),
                  _StatItem(number: "150+", label: "Cities"),
                  _StatItem(number: "10K+", label: "People Helped"),
                  _StatItem(number: "★ 4.9", label: "Avg. Rating"),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const _StatItem(number: "5,000+", label: "Volunteers"),
                  _VerticalDivider(),
                  const _StatItem(number: "150+", label: "Cities"),
                  _VerticalDivider(),
                  const _StatItem(number: "10K+", label: "People Helped"),
                  _VerticalDivider(),
                  const _StatItem(number: "★ 4.9", label: "Avg. Rating"),
                ],
              ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withOpacity(0.07),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String number;
  final String label;
  const _StatItem({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.white.withOpacity(0.4),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ────────────────────────── FEATURES ──────────────────────────────

class _FeaturesSection extends StatelessWidget {
  final bool isMobile;
  const _FeaturesSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Section label
          Text(
            "FEATURES",
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6C63FF),
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 16),

          // Heading with gradient
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Text(
                  "Everything you need",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 30 : 48,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: -1,
                  ),
                ),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF9B8FFF), Color(0xFF5B54E6)],
                  ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    "to help others",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 30 : 48,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Powerful tools wrapped in a simple, human experience.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity(0.4),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 64),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 20,
            children: const [
              _FeatureCard(
                icon: Icons.volunteer_activism_outlined,
                title: "Help Nearby",
                text:
                    "Support people in your local area with verified, genuine requests posted in real time.",
                accentColor: Color(0xFF6C63FF),
              ),
              _FeatureCard(
                icon: Icons.verified_user_outlined,
                title: "Trusted & Safe",
                text:
                    "Identity checks and community ratings ensure every connection is secure and authentic.",
                accentColor: Color(0xFF5B8AF5),
              ),
              _FeatureCard(
                icon: Icons.map_outlined,
                title: "Real-Time Map",
                text:
                    "Discover volunteer opportunities near you instantly using smart geolocation technology.",
                accentColor: Color(0xFF9B74FF),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final Color accentColor;
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    // Gradient border wrapper
    return Container(
      width: 320,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.35),
            Colors.white.withOpacity(0.04),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(1),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF13131A),
          borderRadius: BorderRadius.circular(19),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: accentColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(icon, size: 22, color: accentColor),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.7,
                color: Colors.white.withOpacity(0.45),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────── FOOTER ──────────────────────────────

class _Footer extends StatelessWidget {
  final bool isMobile;
  const _Footer({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: isMobile ? 0 : 0),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 56,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.06),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          if (!isMobile)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF8B83FF),
                                  Color(0xFF5B54E6)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(Icons.volunteer_activism,
                                color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "KindLink",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        "Connecting volunteers\nwith people in need.",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.35),
                          height: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FooterHeading("Product"),
                      _FooterLink(context, "Home", '/'),
                      _FooterLink(context, "About", '/about'),
                      _FooterLink(context, "Contact", '/contact'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FooterHeading("Account"),
                      _FooterLink(context, "Log In", '/login'),
                      _FooterLink(context, "Sign Up", '/signup'),
                    ],
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B83FF), Color(0xFF5B54E6)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.volunteer_activism,
                      color: Colors.white, size: 13),
                ),
                const SizedBox(width: 8),
                Text(
                  "KindLink",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 40),
          Divider(color: Colors.white.withOpacity(0.06), height: 1),
          const SizedBox(height: 28),
          Text(
            "© 2026 KindLink — Made with care in Bulgaria",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.25),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _FooterHeading(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.35),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  static Widget _FooterLink(
      BuildContext context, String text, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
