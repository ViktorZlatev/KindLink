import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kindlink/features/home/popups/popup.dart';

void main() {
  testWidgets(
    'Emergency dialog renders correctly when survey is NOT completed',
    (WidgetTester tester) async {
      bool confirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showEmergencyDialog(
                        context,
                        surveyCompleted: false,
                        onConfirm: () => confirmed = true,
                      );
                    },
                    child: const Text('Open'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      
      expect(find.text('Emergency Use Only'), findsOneWidget);

      expect(find.text('For urgent situations only.'), findsOneWidget);
      expect(find.text('Alerts multiple nearby volunteers instantly.'), findsOneWidget);
      expect(find.text('Use only if someone needs immediate help.'), findsOneWidget);

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Send Signal'), findsOneWidget);

      await tester.tap(find.text('Send Signal'));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
      expect(find.text('Emergency Use Only'), findsNothing);
    },
  );

  testWidgets(
    'Emergency dialog renders correctly when survey IS completed',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showEmergencyDialog(
                        context,
                        surveyCompleted: true,
                        onConfirm: () {},
                      );
                    },
                    child: const Text('Open'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(
        find.text('Notifies volunteers who best match your personal profile.'),
        findsOneWidget,
      );
      expect(
        find.text('Uses our AI system to identify the most suitable volunteers.'),
        findsOneWidget,
      );
      expect(
        find.text('Ensures faster and more effective emergency assistance.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Cancel button closes emergency dialog',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    showEmergencyDialog(
                      context,
                      surveyCompleted: false,
                      onConfirm: () {},
                    );
                  },
                  child: const Text('Open'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Emergency Use Only'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Emergency Use Only'), findsNothing);
    },
  );
}
