import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

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

 Future<void> _signUp() async {
  if (!_formKey.currentState!.validate()) return;
    
  setState(() => _loading = true);
  print("🟣 Sign up started...");

  try {
    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      print("❌ Passwords do not match");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      setState(() => _loading = false);
      
      return;
    }

    // ✅ Create user
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    print("creating user");

    // ✅ Save username to Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(credential.user!.uid)
        .set({
      'uid': credential.user!.uid,
      'username': usernameController.text.trim(),
      'email': emailController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // ✅ Redirect to Home()
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? 'Sign up failed')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unexpected error: $e')),
    );
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
      filled: true,
      fillColor: const Color(0xFFF8F8F8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 240, 236),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // 🔙 Back arrow
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 24,
                  vertical: 16,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, size: 30),
                  color: const Color(0xFF6C63FF),
                  tooltip: "Back to Home",
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(const Color(0xFFE8E5FA)),
                    shape: WidgetStateProperty.all(const CircleBorder()),
                    padding: WidgetStateProperty.all(const EdgeInsets.all(8)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
              ),

              // 🟣 Sign Up header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 60,
                  vertical: 60,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0EAE2),
                ),
                child: Column(
                  children: [
                    Text(
                      "Join KindLink!",
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 30 : 42,
                        fontWeight: FontWeight.w800,
                        color: const Color.fromARGB(255, 161, 107, 241),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🧾 Sign Up form card
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // 🧑 Username
                            TextFormField(
                              controller: usernameController,
                              decoration: _inputDecoration("Username"),
                              validator: (v) =>
                                  v != null && v.isNotEmpty
                                      ? null
                                      : "Enter a username",
                            ),
                            const SizedBox(height: 16),

                            // 📧 Email
                            TextFormField(
                              controller: emailController,
                              decoration: _inputDecoration("Email"),
                              validator: (v) => v != null && v.contains('@')
                                  ? null
                                  : "Enter a valid email",
                            ),
                            const SizedBox(height: 16),

                            // 🔑 Password
                            TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: _inputDecoration("Password"),
                              validator: (v) => v != null && v.length >= 6
                                  ? null
                                  : "Password must be 6+ chars",
                            ),
                            const SizedBox(height: 16),

                            // 🔁 Confirm Password
                            TextFormField(
                              controller: confirmPasswordController,
                              obscureText: true,
                              decoration:
                                  _inputDecoration("Confirm Password"),
                              validator: (v) =>
                                  v != null && v == passwordController.text
                                      ? null
                                      : "Passwords do not match",
                            ),
                            const SizedBox(height: 30),

                            // 💜 Sign Up button
                            GestureDetector(
                              onTap: _loading ? null : _signUp,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 40,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C63FF),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6C63FF)
                                          .withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: _loading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : Text(
                                        "Sign Up",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 🔄 Redirect to login
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/login'),
                              child: Text(
                                "Already have an account? Log in",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF6C63FF),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
