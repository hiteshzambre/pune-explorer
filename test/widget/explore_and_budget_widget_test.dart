import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pune_explorer/core/widgets/custom_button.dart';
import 'package:pune_explorer/core/widgets/empty_state_view.dart';
import 'package:pune_explorer/features/budget/presentation/budget_calculator_screen.dart';

void main() {
  group('Enhanced Widget & Interactive Tests', () {
    testWidgets('CustomButton renders with primary variant and reacts to tap', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Explore Sinhagad',
              onPressed: () => tapped = true,
              variant: ButtonVariant.primary,
            ),
          ),
        ),
      );

      expect(find.text('Explore Sinhagad'), findsOneWidget);
      await tester.tap(find.text('Explore Sinhagad'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('CustomButton shows loader when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Booking Pass',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Booking Pass'), findsNothing);
    });

    testWidgets('EmptyStateView renders icon, title, description, and action button', (WidgetTester tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              icon: 'search',
              title: 'No Destinations Found',
              description: 'Try adjusting your search criteria.',
              actionText: 'Reset Filters',
              onAction: () => actionTriggered = true,
            ),
          ),
        ),
      );

      expect(find.text('search'), findsOneWidget);
      expect(find.text('No Destinations Found'), findsOneWidget);
      expect(find.text('Try adjusting your search criteria.'), findsOneWidget);
      expect(find.text('Reset Filters'), findsOneWidget);

      await tester.tap(find.text('Reset Filters'));
      await tester.pump();
      expect(actionTriggered, isTrue);
    });

    testWidgets('BudgetCalculatorScreen renders estimated total and interactive presets', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: BudgetCalculatorScreen(),
          ),
        ),
      );

      expect(find.text('Pune Travel Budget Planner'), findsOneWidget);
      expect(find.text('Estimated Total Budget'), findsOneWidget);
      expect(find.text('1-Click Budget Presets'), findsOneWidget);
      expect(find.byType(ActionChip), findsNWidgets(3));
    });
  });
}
