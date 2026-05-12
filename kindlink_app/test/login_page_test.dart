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

 
    expect(find.text('Welcome back'), findsOneWidget);

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('Login validation shows errors on empty submit',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginPage(),
      ),
    );

    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Must be 6+ characters'), findsOneWidget);
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
    expect(find.text('Must be 6+ characters'), findsNothing);
  });
}
