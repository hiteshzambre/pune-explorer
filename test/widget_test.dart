import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pune_explorer/app/app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('PuneExplorerApp root smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PuneExplorerApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(PuneExplorerApp), findsOneWidget);

    // Clean up timer by unmounting widgets
    await tester.pumpWidget(const SizedBox());
  });
}
