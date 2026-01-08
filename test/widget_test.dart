// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:gamerch_shinyhunter/main.dart';

void main() {
  testWidgets('Start Scanning Test [Device Screen]', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('No Device Connected'), findsOneWidget);
    expect(find.text('Start Scanning for Device'), findsOneWidget);

    // // Tap the '+' icon and trigger a frame.
    // await tester.tap(find.byElementType(ElevatedButton));
    // await tester.pump();

    // // Verify that our counter has incremented.
    // expect(find.text('Scanning'), findsOneWidget);
    // expect(find.text('No Device Connected'), findsNothing);
  });
}
