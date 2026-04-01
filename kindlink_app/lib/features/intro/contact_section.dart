import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindlink/features/intro/navbar.dart';

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _submitted = true);
    }
  }

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
                          "CONTACT",
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
                              "Let's start a",
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
                                "conversation.",
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
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: Text(
                            "Have questions, ideas, or want to partner with us? We'd love to hear from you.",
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

              // ── INFO CARDS + FORM ──
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 80,
                  vertical: 0,
                ),
                child: Column(
                  children: [
                    // Info cards
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 16,
                      children: const [
                        _InfoCard(
                          icon: Icons.email_outlined,
                          label: "EMAIL",
                          value: "vzlatev7@gmail.com",
                          accent: Color(0xFF6C63FF),
                        ),
                        _InfoCard(
                          icon: Icons.phone_outlined,
                          label: "PHONE",
                          value: "+359 88 370 3503",
                          accent: Color(0xFF5B8AF5),
                        ),
                        _InfoCard(
                          icon: Icons.location_on_outlined,
                          label: "LOCATION",
                          value: "Sofia, Bulgaria",
                          accent: Color(0xFF9B74FF),
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),

                    // Form card
                    Container(
                      constraints: const BoxConstraints(maxWidth: 680),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6C63FF).withOpacity(0.25),
                            Colors.white.withOpacity(0.03),
                            Colors.transparent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.all(1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF13131A),
                          borderRadius: BorderRadius.circular(23),
                        ),
                        padding: EdgeInsets.all(isMobile ? 28 : 48),
                        child: _submitted
                            ? _SuccessState()
                            : Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Send a message",
                                      style: GoogleFonts.poppins(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "We typically reply within 24 hours.",
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.white.withOpacity(0.4),
                                      ),
                                    ),
                                    const SizedBox(height: 36),
                                    _buildField(
                                      controller: _nameController,
                                      label: "Name",
                                      hint: "Your full name",
                                      icon: Icons.person_outline_rounded,
                                      validator: (v) =>
                                          v == null || v.isEmpty
                                              ? "Please enter your name"
                                              : null,
                                    ),
                                    const SizedBox(height: 20),
                                    _buildField(
                                      controller: _emailController,
                                      label: "Email",
                                      hint: "your@email.com",
                                      icon: Icons.email_outlined,
                                      validator: (v) =>
                                          v == null || !v.contains('@')
                                              ? "Enter a valid email"
                                              : null,
                                    ),
                                    const SizedBox(height: 20),
                                    _buildField(
                                      controller: _messageController,
                                      label: "Message",
                                      hint: "How can we help you?",
                                      icon: Icons.chat_bubble_outline_rounded,
                                      maxLines: 5,
                                      validator: (v) =>
                                          v == null || v.length < 10
                                              ? "Message must be at least 10 characters"
                                              : null,
                                    ),
                                    const SizedBox(height: 32),
                                    SizedBox(
                                      width: double.infinity,
                                      child: GestureDetector(
                                        onTap: _submit,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 18),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF8B83FF),
                                                Color(0xFF5B54E6),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF6C63FF)
                                                    .withOpacity(0.35),
                                                blurRadius: 24,
                                                offset:
                                                    const Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Send Message",
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
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
              ),

              const SizedBox(height: 80),

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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.5),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.2),
              fontSize: 14,
            ),
            prefixIcon: maxLines == 1
                ? Icon(icon, color: const Color(0xFF6C63FF), size: 18)
                : null,
            filled: true,
            fillColor: const Color(0xFF0D0D12),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: maxLines > 1 ? 18 : 0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF6C63FF),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade700, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade600, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _SuccessState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B83FF), Color(0xFF5B54E6)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 20),
          Text(
            "Message sent!",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Thanks for reaching out. We'll be in touch within 24 hours.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.4),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF13131A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: accent.withOpacity(0.2), width: 1),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.35),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }
}
