import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kindlink/features/auth/login.dart';

void main() {
  testWidgets('Login page renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginPage(),
      ),
    );

 
    expect(find.text('Welcome Back!'), findsOneWidget);

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Login validation shows errors on empty submit',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginPage(),
      ),
    );

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Password must be 6+ chars'), findsOneWidget);
  });

  testWidgets('Login form accepts valid input without validation errors',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginPage(),
      ),
    );

    await tester.enterText(
        find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(
        find.byType(TextFormField).at(1), '123456');

    await tester.pump();

    expect(find.text('Enter a valid email'), findsNothing);
    expect(find.text('Password must be 6+ chars'), findsNothing);
  });
}
