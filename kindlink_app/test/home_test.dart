import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:kindlink/features/intro/home_page.dart';

void main() {
  testWidgets('Intro home page renders hero text',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        
        data: MediaQueryData(size: Size(375, 800)),
        child: MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    expect(
      find.textContaining('Empowering Kindness'),
      findsOneWidget,
    );

    expect(find.text('Help Nearby'), findsOneWidget);
    expect(find.text('Trusted & Safe'), findsOneWidget);
  });
}
