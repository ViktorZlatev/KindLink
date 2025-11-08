import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:kindlink/main.dart';

void main() {
  testWidgets('App shows login page when not authenticated', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const MyApp());

    // Wait for the StreamBuilder to build
    await tester.pumpAndSettle();

    // Check that "Welcome Back!" text from LoginPage is visible
    expect(find.text('Welcome Back!'), findsOneWidget);

    // Optionally check that the email and password fields exist
    expect(find.byType(TextFormField), findsNWidgets(2));

    // Check that the Login button exists
    expect(find.text('Login'), findsOneWidget);
  });
}
