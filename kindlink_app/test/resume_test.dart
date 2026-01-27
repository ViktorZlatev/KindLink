import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kindlink/features/home/resume.dart';

void main() {
  testWidgets('Health resume dialog renders and allows editing',
      (WidgetTester tester) async {
    final surveyData = {
      'problem': 'Headache',
      'duration': '2 days',
      'symptoms': 'Pain',
      'treatment': 'None',
    };

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                showHelpRequestDialog(
                  context,
                  surveyData: surveyData,
                  onSave: (_) {},
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Your Health Summary'), findsOneWidget);
    expect(find.text('Headache'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pump();

    expect(find.byType(TextFormField), findsWidgets);
  });
}
