import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shoproute/main.dart';

void
main() {
  testWidgets(
    'App loads correctly',
    (
      WidgetTester tester,
    ) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        const ShopRouteApp(),
      );

      // Verify that the app loads (splash screen should be visible initially)
      await tester.pump(
        const Duration(
          seconds: 1,
        ),
      );

      // Basic smoke test that the app renders something
      expect(
        find.byType(
          MaterialApp,
        ),
        findsOneWidget,
      );
    },
  );
}
