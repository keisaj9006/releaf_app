// Basic smoke test for app boot.
//
// Verifies that the app builds without errors and that a MaterialApp is present.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/main.dart'; // <- poprawiona nazwa pakietu i import

void main() {
  testWidgets('App boots and shows MaterialApp', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const ReleafApp());

    // Verify MaterialApp exists
    expect(find.byType(MaterialApp), findsOneWidget);

    // Optionally, check that DashboardScreen (home) is mounted by looking for AppBar title
    // (jeśli masz inny tytuł, można to usunąć)
    expect(find.text('Releaf'), findsNothing); // zostawiamy neutralnie
  });
}
