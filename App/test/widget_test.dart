import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novelpop/src/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify that the app builds and shows the home screen (or at least doesn't crash).
    // Since we have localization and async data, we might just check for MaterialApp for now
    // or wait for data. For a simple smoke test, checking for MaterialApp is enough to prove it launches.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
