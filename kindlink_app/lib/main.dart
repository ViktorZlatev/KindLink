import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kindlink/features/intro/about_section.dart';
import 'package:kindlink/features/intro/contact_section.dart';
import 'firebase_options.dart';

// 👇 Import your home page here
import 'features/intro/home_page.dart';

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
      debugShowCheckedModeBanner: false, // cleaner UI
      title: 'KindLink',
      theme: ThemeData(
        useMaterial3: true, // modern Material You style
        colorSchemeSeed: const Color(0xFF6C63FF),
        fontFamily: 'Poppins',
      ),

      // Original home page
      home: const HomePage(),

      // Placeholder routes (can remain for login/signup)
      routes: {
        '/about': (context) => AboutSection(isMobile: MediaQuery.of(context).size.width < 700),
        '/contact': (context) => ContactSection(isMobile: MediaQuery.of(context).size.width < 700),
        '/login': (context) => const Placeholder(), // replace with LoginPage()
        '/signup': (context) => const Placeholder(), // replace with SignUpPage()
      },
    );
  }
}
