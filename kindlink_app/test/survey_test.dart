import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kindlink/features/home/survey.dart';

void main() {
  testWidgets('Survey dialog renders all questions',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                showSurvey(
                  context,
                  onConfirm: (_) {},
                );
              },
              child: const Text('Open Survey'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Survey'));
    await tester.pumpAndSettle();

    expect(find.text('Health Condition Survey'), findsOneWidget);

    expect(find.textContaining('What health issue'), findsOneWidget);
    expect(find.textContaining('How long have you felt'), findsOneWidget);
    expect(find.textContaining('Symptoms'), findsOneWidget);
    expect(find.textContaining('medication'), findsWidgets);
    expect(find.textContaining('Additional info'), findsOneWidget);

    expect(find.byType(TextField), findsNWidgets(5));
    expect(find.text('Submit'), findsOneWidget);
  });
}
