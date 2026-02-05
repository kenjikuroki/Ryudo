// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:archery/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: ArcheryNoteApp(),
      ),
    );

    // Verify that the title shows 'Kyudo Note'.
    // Note: Since it's inside MaterialApp, finding by text might work if Home is displayed.
    // But async data loading (recent sessions) might not complete.
    // Just checking if it pumps without error is a good start.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
