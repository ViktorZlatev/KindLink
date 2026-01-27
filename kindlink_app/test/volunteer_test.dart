import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kindlink/features/home/volunteer.dart';

void main() {
  testWidgets('Volunteer form renders correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                showVolunteerForm(
                  context,
                  onConfirm: (_) {},
                );
              },
              child: const Text('Open Volunteer Form'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Volunteer Form'));
    await tester.pumpAndSettle();

    expect(find.text('Volunteer Application'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(5));
    expect(find.text('Submit'), findsOneWidget);
  });
}
