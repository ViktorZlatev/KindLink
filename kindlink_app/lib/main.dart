import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
// Intro and feature pages
import 'package:kindlink/features/intro/about_section.dart';
import 'package:kindlink/features/intro/contact_section.dart';
import 'package:kindlink/features/intro/home_page.dart';

// Auth pages
import 'package:kindlink/features/auth/login.dart';
import 'package:kindlink/features/auth/sign_up.dart';

//home pages
import 'package:kindlink/features/home/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KindLink',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6C63FF),
        fontFamily: 'Poppins',
      ),

      routes: {

        '/': (context) => StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                 );
               }
              return const HomePage();
             },
           ),

        '/about': (context) => const AboutSection(),
        '/contact': (context) => const ContactSection(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const Home(),
      },
    );
  }
}
