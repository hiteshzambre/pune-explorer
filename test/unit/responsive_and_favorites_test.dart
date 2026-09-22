import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pune_explorer/core/enums/app_enums.dart';
import 'package:pune_explorer/core/providers/app_providers.dart';
import 'package:pune_explorer/core/widgets/custom_button.dart';
import 'package:pune_explorer/features/booking/presentation/booking_screen.dart';
import 'package:pune_explorer/features/booking/presentation/booking_confirmation_screen.dart';
import 'package:pune_explorer/features/booking/presentation/digital_ticket_screen.dart';
import 'package:pune_explorer/features/journey/presentation/journey_mode_screen.dart';

void main() {
  group('Enhanced Search & State Management Tests', () {
    test('Favorites state set reactivity toggling', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Add a test favorite
      await container.read(favoritesProvider.notifier).toggle('dest_test_landmark');
      expect(container.read(favoritesProvider).contains('dest_test_landmark'), isTrue);

      // Toggle off
      await container.read(favoritesProvider.notifier).toggle('dest_test_landmark');
      expect(container.read(favoritesProvider).contains('dest_test_landmark'), isFalse);
    });

    test('Faceted search matches city and category labels', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Await future provider to load seed destinations
      await container.read(destinationsAsyncProvider.future);

      // Search for 'Lonavala'
      container.read(exploreFilterProvider.notifier).setSearchQuery('Lonavala');
      final lonavalaResults = container.read(filteredDestinationsProvider);
      expect(lonavalaResults.isNotEmpty, isTrue);
      expect(lonavalaResults.any((d) => d.name.contains('Lonavala') || d.city.contains('Lonavala') || d.state.contains('Lonavala')), isTrue);

      // Search for 'Forts'
      container.read(exploreFilterProvider.notifier).setSearchQuery('Forts');
      final fortsResults = container.read(filteredDestinationsProvider);
      expect(fortsResults.isNotEmpty, isTrue);
      expect(fortsResults.every((d) => d.category == DestinationCategory.forts || d.name.toLowerCase().contains('fort') || d.famousFor.toLowerCase().contains('fort')), isTrue);
    });

    test('Memoized trending and featured destinations providers return cached subsets', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(destinationsAsyncProvider.future);
      final trending = container.read(trendingDestinationsProvider);
      final featured = container.read(featuredDestinationsProvider);

      expect(trending.isNotEmpty, isTrue);
      expect(trending.every((d) => d.isTrending), isTrue);
      expect(featured.isNotEmpty, isTrue);
      expect(featured.length, lessThanOrEqualTo(5));
    });

    test('RecentSearchesNotifier performs immediate optimistic updates', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(recentSearchesProvider.notifier).add('Sinhagad Fort');
      expect(container.read(recentSearchesProvider).first, 'Sinhagad Fort');

      await container.read(recentSearchesProvider.notifier).clear();
      expect(container.read(recentSearchesProvider).isEmpty, isTrue);
    });
  });

  group('Responsive CustomButton & Component Widget Tests', () {
    testWidgets('CustomButton does not overflow inside constrained narrow parent', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100, // Very narrow container
              child: CustomButton(
                text: 'Extremely Long Action Button Text That Would Overflow Non-Flexible Rows',
                icon: const Icon(Icons.check, size: 16),
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Ensure widget renders without any RenderFlex exception
      expect(tester.takeException(), isNull);
      expect(find.byType(CustomButton), findsOneWidget);
    });

    testWidgets('Responsive widgets render cleanly on 320px viewport without overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 320,
                child: CustomButton(
                  text: 'Book Darshan / Tour Package',
                  icon: Icon(Icons.directions_bus),
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
    testWidgets('BookingScreen renders for any tour package without DropdownButton value assertion error', (WidgetTester tester) async {
      // Test tour_bhimashankar_jyotirlinga which has different pickup points than Swargate 8:20 AM
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: BookingScreen(tourId: 'tour_bhimashankar_jyotirlinga'),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(BookingScreen), findsOneWidget);
    });

    testWidgets('JourneyModeScreen renders graceful empty state when 0 bookings exist', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: JourneyModeScreen(bookingId: 'non_existent_id'),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(find.byType(JourneyModeScreen), findsOneWidget);
    });

    testWidgets('DigitalTicketScreen renders graceful empty state for invalid bookingId', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DigitalTicketScreen(bookingId: 'invalid_pass_id'),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(find.byType(DigitalTicketScreen), findsOneWidget);
    });

    testWidgets('BookingConfirmationScreen renders graceful empty state for invalid bookingId', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BookingConfirmationScreen(bookingId: 'invalid_booking_id'),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(find.byType(BookingConfirmationScreen), findsOneWidget);
    });
  });
}
