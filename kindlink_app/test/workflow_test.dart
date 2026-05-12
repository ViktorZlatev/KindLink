import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kindlink/features/home/popups/popup.dart';
import 'package:kindlink/features/home/popups/help_popup.dart';
import 'package:kindlink/features/home/resume.dart';
import 'package:kindlink/features/home/survey.dart';
import 'package:kindlink/features/home/volunteer.dart';

Widget _app(void Function(BuildContext) action) => MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: ElevatedButton(
            onPressed: () => action(ctx),
            child: const Text('Open'),
          ),
        ),
      ),
    );

void main() {
  // ── Emergency dialog ────────────────────────────────────────────────────────

  group('Emergency dialog workflow', () {
    testWidgets('Cancel does not fire onConfirm callback', (tester) async {
      bool confirmed = false;
      await tester.pumpWidget(_app((ctx) => showEmergencyDialog(
            ctx,
            surveyCompleted: false,
            onConfirm: () => confirmed = true,
          )));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(confirmed, isFalse);
      expect(find.text('Emergency Use Only'), findsNothing);
    });

    testWidgets('Send Signal fires onConfirm exactly once and closes dialog',
        (tester) async {
      int callCount = 0;
      await tester.pumpWidget(_app((ctx) => showEmergencyDialog(
            ctx,
            surveyCompleted: false,
            onConfirm: () => callCount++,
          )));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send Signal'));
      await tester.pumpAndSettle();

      expect(callCount, 1);
      expect(find.text('Emergency Use Only'), findsNothing);
    });

    testWidgets(
        'surveyCompleted flag controls which bullet-point set is shown',
        (tester) async {
      // Without survey — generic bullets
      await tester.pumpWidget(_app((ctx) => showEmergencyDialog(
            ctx,
            surveyCompleted: false,
            onConfirm: () {},
          )));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('For urgent situations only.'), findsOneWidget);
      expect(
          find.text('Notifies volunteers who best match your personal profile.'),
          findsNothing);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // With survey — AI-matching bullets
      await tester.pumpWidget(_app((ctx) => showEmergencyDialog(
            ctx,
            surveyCompleted: true,
            onConfirm: () {},
          )));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(
          find.text('Notifies volunteers who best match your personal profile.'),
          findsOneWidget);
      expect(find.text('For urgent situations only.'), findsNothing);
    });
  });

  // ── Volunteer help popup ─────────────────────────────────────────────────────

  group('Volunteer help popup workflow', () {
    testWidgets('Shows requester name, problem and symptoms from resume',
        (tester) async {
      final data = {
        'username': 'Alice',
        'status': 'awaiting_volunteer',
        'resume': {
          'problem': 'Chest pain',
          'symptoms': 'Shortness of breath',
        },
      };

      await tester.pumpWidget(_app(
          (ctx) => showVolunteerHelpPopup(ctx, requestId: 'req1', data: data)));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Immediate Help Needed!'), findsOneWidget);
      expect(find.textContaining('Alice'), findsOneWidget);
      expect(find.text('Problem'), findsOneWidget);
      expect(find.text('Chest pain'), findsOneWidget);
      expect(find.text('Symptoms'), findsOneWidget);
      expect(find.text('Shortness of breath'), findsOneWidget);
    });

    testWidgets('Detail card is hidden when resume is absent', (tester) async {
      final data = {'username': 'Bob', 'status': 'awaiting_volunteer'};

      await tester.pumpWidget(_app(
          (ctx) => showVolunteerHelpPopup(ctx, requestId: 'req2', data: data)));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Immediate Help Needed!'), findsOneWidget);
      expect(find.text('Problem'), findsNothing);
      expect(find.text('Symptoms'), findsNothing);
    });

    testWidgets('Detail card is hidden when resume fields are empty',
        (tester) async {
      final data = {
        'username': 'Carol',
        'status': 'awaiting_volunteer',
        'resume': {'problem': '', 'symptoms': ''},
      };

      await tester.pumpWidget(_app(
          (ctx) => showVolunteerHelpPopup(ctx, requestId: 'req3', data: data)));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Problem'), findsNothing);
      expect(find.text('Symptoms'), findsNothing);
    });

    testWidgets('Shows only the filled field when one is missing',
        (tester) async {
      final data = {
        'username': 'Dan',
        'status': 'awaiting_volunteer',
        'resume': {'problem': 'Back pain', 'symptoms': ''},
      };

      await tester.pumpWidget(_app(
          (ctx) => showVolunteerHelpPopup(ctx, requestId: 'req4', data: data)));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Problem'), findsOneWidget);
      expect(find.text('Back pain'), findsOneWidget);
      expect(find.text('Symptoms'), findsNothing);
    });

    testWidgets('Accept and Reject buttons are present', (tester) async {
      final data = {
        'username': 'Eve',
        'status': 'awaiting_volunteer',
        'resume': {},
      };

      await tester.pumpWidget(_app(
          (ctx) => showVolunteerHelpPopup(ctx, requestId: 'req5', data: data)));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
    });
  });

  // ── Health resume dialog ─────────────────────────────────────────────────────

  group('Health resume dialog workflow', () {
    testWidgets('Done fires onSave with the original survey data',
        (tester) async {
      Map<String, dynamic>? saved;
      final surveyData = {'problem': 'Headache', 'symptoms': 'Nausea'};

      await tester.pumpWidget(_app((ctx) => showHelpRequestDialog(
            ctx,
            surveyData: surveyData,
            onSave: (d) => saved = d,
          )));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Your Health Summary'), findsOneWidget);
      expect(find.text('Headache'), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(saved, isNotNull);
      expect(saved!['problem'], 'Headache');
      expect(saved!['symptoms'], 'Nausea');
      expect(find.text('Your Health Summary'), findsNothing);
    });

    testWidgets('Cancel does not fire onSave and closes dialog',
        (tester) async {
      bool saved = false;

      await tester.pumpWidget(_app((ctx) => showHelpRequestDialog(
            ctx,
            surveyData: {'problem': 'Headache'},
            onSave: (_) => saved = true,
          )));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(saved, isFalse);
      expect(find.text('Your Health Summary'), findsNothing);
    });

    testWidgets('Edit mode update is reflected in onSave data', (tester) async {
      Map<String, dynamic>? saved;
      final surveyData = {'problem': 'Headache', 'symptoms': 'Nausea'};

      await tester.pumpWidget(_app((ctx) => showHelpRequestDialog(
            ctx,
            surveyData: surveyData,
            onSave: (d) => saved = d,
          )));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Enter edit mode
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      expect(find.byType(TextFormField), findsWidgets);

      // Change the first field (problem)
      await tester.enterText(find.byType(TextFormField).first, 'Migraine');
      await tester.pump();

      // Save — button label switches to "Save" when editing
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(saved, isNotNull);
      expect(saved!['problem'], 'Migraine');
    });

    testWidgets('Empty survey field shows "No information" placeholder',
        (tester) async {
      await tester.pumpWidget(_app((ctx) => showHelpRequestDialog(
            ctx,
            surveyData: {'problem': '', 'symptoms': 'Nausea'},
            onSave: (_) {},
          )));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('No information'), findsOneWidget);
      expect(find.text('Nausea'), findsOneWidget);
    });
  });

  // ── Survey dialog ────────────────────────────────────────────────────────────

  group('Survey dialog workflow', () {
    testWidgets('Cancel closes dialog without firing onConfirm',
        (tester) async {
      bool called = false;

      await tester.pumpWidget(_app((ctx) => showSurvey(
            ctx,
            onConfirm: (_) => called = true,
          )));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Health Condition Survey'), findsOneWidget);

      await tester.ensureVisible(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(called, isFalse);
      expect(find.text('Health Condition Survey'), findsNothing);
    });

    testWidgets('All five fields accept text input', (tester) async {
      await tester.pumpWidget(_app((ctx) => showSurvey(
            ctx,
            onConfirm: (_) {},
          )));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(5));

      await tester.enterText(fields.at(0), 'dizziness');
      await tester.enterText(fields.at(1), '3 days');
      await tester.enterText(fields.at(2), 'headache, nausea');
      await tester.enterText(fields.at(3), 'Ibuprofen');
      await tester.enterText(fields.at(4), 'none');
      await tester.pump();

      expect(find.text('dizziness'), findsOneWidget);
      expect(find.text('3 days'), findsOneWidget);
      expect(find.text('headache, nausea'), findsOneWidget);
    });
  });

  // ── Volunteer form ───────────────────────────────────────────────────────────

  group('Volunteer form workflow', () {
    testWidgets('Cancel closes the form dialog', (tester) async {
      await tester.pumpWidget(_app((ctx) => showVolunteerForm(
            ctx,
            onConfirm: (_) {},
          )));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Volunteer Application'), findsOneWidget);

      await tester.ensureVisible(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Volunteer Application'), findsNothing);
    });

    testWidgets('All five text fields accept input', (tester) async {
      await tester.pumpWidget(_app((ctx) => showVolunteerForm(
            ctx,
            onConfirm: (_) {},
          )));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(5));

      await tester.enterText(fields.at(0), 'John Doe');
      await tester.enterText(fields.at(1), 'BSc Nursing');
      await tester.enterText(fields.at(2), '5 years ICU');
      await tester.enterText(fields.at(3), 'CPR, First Aid');
      await tester.enterText(fields.at(4), 'I want to help');
      await tester.pump();

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('BSc Nursing'), findsOneWidget);
      expect(find.text('I want to help'), findsOneWidget);
    });
  });
}
