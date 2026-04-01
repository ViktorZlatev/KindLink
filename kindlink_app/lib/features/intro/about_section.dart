import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindlink/features/intro/navbar.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

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

              // ── HEADER ──
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 80,
                  vertical: isMobile ? 60 : 100,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -60,
                      right: -80,
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF6C63FF).withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: isMobile
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ABOUT",
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6C63FF),
                            letterSpacing: 2.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: isMobile
                              ? CrossAxisAlignment.center
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              "We believe kindness",
                              textAlign: isMobile
                                  ? TextAlign.center
                                  : TextAlign.start,
                              style: GoogleFonts.poppins(
                                fontSize: isMobile ? 34 : 60,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.05,
                                letterSpacing: -1.5,
                              ),
                            ),
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  const LinearGradient(
                                colors: [Color(0xFF9B8FFF), Color(0xFF5B54E6)],
                              ).createShader(Rect.fromLTWH(
                                  0, 0, bounds.width, bounds.height)),
                              blendMode: BlendMode.srcIn,
                              child: Text(
                                "should be effortless.",
                                textAlign: isMobile
                                    ? TextAlign.center
                                    : TextAlign.start,
                                style: GoogleFonts.poppins(
                                  fontSize: isMobile ? 34 : 60,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.05,
                                  letterSpacing: -1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 580),
                          child: Text(
                            "KindLink is a community-driven platform that bridges the gap between volunteers and people in need — making kindness visible, accessible, and deeply meaningful.",
                            textAlign: isMobile
                                ? TextAlign.center
                                : TextAlign.start,
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 15 : 17,
                              color: Colors.white.withOpacity(0.45),
                              height: 1.75,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── STATS ──
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 80,
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
                            _StatItem(value: "5,000+", label: "Volunteers"),
                            _StatItem(value: "150+", label: "Cities"),
                            _StatItem(value: "10K+", label: "Helped"),
                            _StatItem(value: "2024", label: "Founded"),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const _StatItem(
                                value: "5,000+", label: "Volunteers"),
                            _Divider(),
                            const _StatItem(value: "150+", label: "Cities"),
                            _Divider(),
                            const _StatItem(
                                value: "10K+", label: "People Helped"),
                            _Divider(),
                            const _StatItem(
                                value: "2024", label: "Founded"),
                          ],
                        ),
                ),
              ),

              // ── MISSION ──
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 80,
                  vertical: 100,
                ),
                child: Column(
                  children: [
                    Text(
                      "OUR MISSION",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6C63FF),
                        letterSpacing: 2.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Text(
                        "We believe every act of kindness matters. Our mission is to empower individuals to make a real difference in their communities — safely, easily, and meaningfully.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 18 : 26,
                          color: Colors.white.withOpacity(0.75),
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 72),

                    // Value cards
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 20,
                      children: const [
                        _ValueCard(
                          icon: Icons.lightbulb_outline_rounded,
                          title: "Our Vision",
                          text:
                              "A world where helping others is frictionless, safe, and rewarding for everyone.",
                          accentColor: Color(0xFF6C63FF),
                        ),
                        _ValueCard(
                          icon: Icons.groups_2_outlined,
                          title: "Our Community",
                          text:
                              "Thousands of volunteers and people in need, united by a shared belief in human goodness.",
                          accentColor: Color(0xFF5B8AF5),
                        ),
                        _ValueCard(
                          icon: Icons.verified_user_outlined,
                          title: "Safety First",
                          text:
                              "Verified identities and community ratings keep every connection trusted and secure.",
                          accentColor: Color(0xFF9B74FF),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── FOOTER ──
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 40),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: Colors.white.withOpacity(0.06), width: 1),
                  ),
                ),
                child: Text(
                  "© 2026 KindLink — Made with care in Bulgaria",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
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
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
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
          ),
        ),
      ],
    );
  }
}

class _ValueCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final Color accentColor;
  const _ValueCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.3),
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
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: accentColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(icon, size: 21, color: accentColor),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.7,
                color: Colors.white.withOpacity(0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
