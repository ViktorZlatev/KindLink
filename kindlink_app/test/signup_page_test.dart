import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kindlink/features/auth/sign_up.dart';

void main() {
  testWidgets('Sign up page renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SignUpPage(),
      ),
    );

    expect(find.textContaining('Join KindLink'), findsOneWidget);

    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm password'), findsOneWidget);

    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('Sign up shows validation errors on empty submit',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SignUpPage(),
      ),
    );

    await tester.ensureVisible(find.text('Create account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create account'));
    await tester.pump();

    expect(find.text('Enter a username'), findsOneWidget);
    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Must be 6+ characters'), findsOneWidget);
  });

  testWidgets('Sign up detects password mismatch',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SignUpPage(),
      ),
    );

    await tester.enterText(
        find.byType(TextFormField).at(0), 'testuser');
    await tester.enterText(
        find.byType(TextFormField).at(1), 'test@example.com');
    await tester.enterText(
        find.byType(TextFormField).at(2), '123456');
    await tester.enterText(
        find.byType(TextFormField).at(3), '654321');

    await tester.ensureVisible(find.text('Create account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create account'));
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });
}
