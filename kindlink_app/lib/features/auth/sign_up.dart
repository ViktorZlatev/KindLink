import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_widgets.dart';
import 'pn_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _loading = false;
  bool _showPassword = false;
  bool _showConfirm = false;
  String? _errorMessage;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _errorMessage = null; });
    try {
      final username = usernameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      bool isAdmin = username == "admin" && email == "admin@gmail.com" && password == "admin123";
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      await PushNotificationService.initAndSaveToken();
      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid, 'username': username, 'email': email,
        'role': isAdmin ? "admin" : "user", 'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) Navigator.pushReplacementNamed(context, isAdmin ? '/admin_home' : '/home');
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message ?? 'Sign up failed');
    } catch (e) {
      setState(() => _errorMessage = 'Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    usernameController.dispose(); emailController.dispose();
    passwordController.dispose(); confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(top: -80, right: -80, child: _Glow(color: const Color(0xFF6C63FF), size: 400, opacity: 0.1)),
            Positioned(bottom: -60, left: -60, child: _Glow(color: const Color(0xFF5B54E6), size: 300, opacity: 0.08)),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AuthBackButton(onTap: () => Navigator.pushReplacementNamed(context, '/'), light: true),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [const Color(0xFF6C63FF).withOpacity(0.25), Colors.white.withOpacity(0.03), Colors.transparent],
                              begin: Alignment.topLeft, end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.all(1),
                          child: Container(
                            decoration: BoxDecoration(color: const Color(0xFF13131A), borderRadius: BorderRadius.circular(23)),
                            padding: const EdgeInsets.all(36),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 44, height: 44,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [Color(0xFF8B83FF), Color(0xFF5B54E6)]),
                                        borderRadius: BorderRadius.circular(13),
                                        boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                                      ),
                                      child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 22),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text("Create an account", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                                  const SizedBox(height: 4),
                                  Text("Join KindLink and start making a difference", style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.4))),
                                  const SizedBox(height: 28),

                                  if (_errorMessage != null) ...[
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                                      ),
                                      child: Row(children: [
                                        Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(_errorMessage!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.red.shade400))),
                                      ]),
                                    ),
                                    const SizedBox(height: 20),
                                  ],

                                  _FieldLabel("Username"),
                                  const SizedBox(height: 7),
                                  _DarkField(controller: usernameController, hint: "Choose a username", icon: Icons.person_outline_rounded,
                                    validator: (v) => v != null && v.isNotEmpty ? null : "Enter a username"),
                                  const SizedBox(height: 16),

                                  _FieldLabel("Email address"),
                                  const SizedBox(height: 7),
                                  _DarkField(controller: emailController, hint: "you@example.com", icon: Icons.email_outlined,
                                    validator: (v) => v != null && v.contains('@') ? null : "Enter a valid email"),
                                  const SizedBox(height: 16),

                                  _FieldLabel("Password"),
                                  const SizedBox(height: 7),
                                  _DarkField(
                                    controller: passwordController, hint: "At least 6 characters", icon: Icons.lock_outline_rounded, obscure: !_showPassword,
                                    suffix: GestureDetector(onTap: () => setState(() => _showPassword = !_showPassword),
                                      child: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 17, color: Colors.white.withOpacity(0.3))),
                                    validator: (v) => v != null && v.length >= 6 ? null : "Must be 6+ characters",
                                  ),
                                  const SizedBox(height: 16),

                                  _FieldLabel("Confirm password"),
                                  const SizedBox(height: 7),
                                  _DarkField(
                                    controller: confirmPasswordController, hint: "Repeat your password", icon: Icons.lock_outline_rounded, obscure: !_showConfirm,
                                    suffix: GestureDetector(onTap: () => setState(() => _showConfirm = !_showConfirm),
                                      child: Icon(_showConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 17, color: Colors.white.withOpacity(0.3))),
                                    validator: (v) => v == passwordController.text ? null : "Passwords do not match",
                                  ),
                                  const SizedBox(height: 28),

                                  SizedBox(
                                    width: double.infinity,
                                    child: GestureDetector(
                                      onTap: _loading ? null : _signUp,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(colors: [Color(0xFF8B83FF), Color(0xFF5B54E6)]),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 6))],
                                        ),
                                        child: Center(child: _loading
                                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                          : Text("Create account", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15))),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Center(
                                    child: GestureDetector(
                                      onTap: () => Navigator.pushNamed(context, '/login'),
                                      child: RichText(text: TextSpan(style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.4)), children: [
                                        const TextSpan(text: "Already have an account? "),
                                        TextSpan(text: "Sign in", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF8B83FF))),
                                      ])),
                                    ),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;
  const _Glow({required this.color, required this.size, required this.opacity});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color.withOpacity(opacity), Colors.transparent])),
  );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.5)));
}

class _DarkField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;
  const _DarkField({required this.controller, required this.hint, required this.icon, this.obscure = false, this.suffix, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, obscureText: obscure, validator: validator,
      style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.2), fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.25), size: 18),
        suffixIcon: suffix != null ? Padding(padding: const EdgeInsets.only(right: 12), child: suffix) : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        filled: true, fillColor: const Color(0xFF0D0D12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withOpacity(0.08), width: 1)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withOpacity(0.08), width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.red.shade700, width: 1)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.red.shade600, width: 1.5)),
      ),
    );
  }
}
