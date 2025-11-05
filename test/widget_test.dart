// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:p014/main.dart';

void main() {
  testWidgets('Color palette generator smoke test', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ColorPaletteApp());

    // Verify that the app title is displayed
    expect(find.text('Color Palette Generator'), findsOneWidget);
    expect(find.text('Discover beautiful color combinations'), findsOneWidget);

    // Verify that the generate button exists
    expect(find.text('Generate New Palette'), findsOneWidget);
  });
}
