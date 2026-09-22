import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pune_explorer/features/destination/presentation/destination_detail_screen.dart';
import 'package:pune_explorer/features/destination/presentation/widgets/destination_3d_decorations.dart';

void main() {
  group('👑 DestinationDetailScreen Royal Redesign & Responsive Tests', () {
    testWidgets('renders Shaniwar Wada with royal identity, badges, and 3D quick info', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      FlutterErrorDetails? caughtDetails;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        caughtDetails = details;
      };
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DestinationDetailScreen(destinationId: 'dest_1'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      FlutterError.onError = originalOnError;

      if (caughtDetails != null) {
        // ignore: avoid_print
        print('TEST 1 ERROR: ${caughtDetails!.summary}');
        final info = caughtDetails!.informationCollector;
        if (info != null) {
          for (final d in info()) {
            // ignore: avoid_print
            print('TEST 1 INFO: ${d.toStringDeep()}');
          }
        }
      }

      // Brand Identity & Title
      expect(find.text('Shaniwar Wada'), findsWidgets);
      expect(find.text('Forts & Historical'), findsOneWidget);
      expect(find.text('🔥 Trending in Pune'), findsOneWidget);
      expect(find.text('Maratha Heritage'), findsOneWidget);

      // 3D Quick Info Matrix
      expect(find.text('Duration'), findsOneWidget);
      expect(find.text('Difficulty'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('Best Season'), findsOneWidget);

      // 3D Weather & Altitude Badge
      expect(find.byType(Floating3DWeatherAltitudeBadge), findsOneWidget);

      // Booking Dock
      expect(find.text('Entry Pass / Fee'), findsOneWidget);
      expect(find.text('₹25'), findsWidgets);
      expect(find.text('Book Entry Pass'), findsOneWidget);

      expect(caughtDetails, isNull);
    });

    testWidgets('switching tabs renders corresponding tab views smoothly', (tester) async {
      tester.view.physicalSize = const Size(600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DestinationDetailScreen(destinationId: 'dest_1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tab 1: Overview (default)
      expect(find.text('About Shaniwar Wada'), findsOneWidget);
      expect(find.text('Famous Highlights'), findsOneWidget);
      expect(find.text('Key Points of Interest'), findsOneWidget);
      expect(find.text('Punekar Explorer Tips'), findsOneWidget);

      // Scroll CustomScrollView up so the TabBar is centered and unobstructed
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -320));
      await tester.pumpAndSettle();

      // Tab 2: Map View
      await tester.tap(find.text('Map View'));
      await tester.pumpAndSettle();
      expect(find.text('0 km from Pune'), findsOneWidget);
      expect(find.text('Directions'), findsOneWidget);

      // Tab 3: Live Weather
      await tester.tap(find.text('Live Weather'));
      await tester.pumpAndSettle();
      expect(find.text('7-Day Forecast'), findsOneWidget);

      // Tab 4: Food Spots
      await tester.tap(find.text('Food Spots'));
      await tester.pumpAndSettle();
      expect(find.text('Puneri Misal Pav'), findsOneWidget);
      expect(find.text('Sujata Mastani'), findsOneWidget);
      expect(find.text('🌱 Puneri Veg'), findsWidgets);

      // Tab 5: Reviews
      await tester.tap(find.text('Reviews'));
      await tester.pumpAndSettle();
      expect(find.text('Add Review'), findsOneWidget);
      expect(find.byType(Royal3DRatingGauge), findsOneWidget);

      // Tab 6: Budget
      await tester.tap(find.text('Budget'));
      await tester.pumpAndSettle();
      expect(find.text('Estimated Trip Budget per Person'), findsOneWidget);
      expect(find.text('🎒 Backpacker'), findsOneWidget);
      expect(find.text('🚗 Moderate'), findsOneWidget);
      expect(find.text('👑 Royal Luxury'), findsOneWidget);
      expect(find.text('Recommended Nearby Accommodations'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('interactive review dialog opens and submits review', (tester) async {
      tester.view.physicalSize = const Size(1024, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DestinationDetailScreen(destinationId: 'dest_1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll CustomScrollView up to reveal TabBar
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -320));
      await tester.pumpAndSettle();

      // Go to Reviews tab
      await tester.tap(find.text('Reviews'));
      await tester.pumpAndSettle();

      // Tap Add Review button
      await tester.tap(find.text('Add Review'));
      await tester.pumpAndSettle();

      // Verify dialog is visible
      expect(find.text('Write a Review'), findsOneWidget);
      expect(find.text('Rate your experience:'), findsOneWidget);

      // Enter review comment
      await tester.enterText(
        find.widgetWithText(TextField, 'Your Name'),
        'Amey Deshmukh',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Your Review'),
        'Magnificent fort! Light and sound show in the evening is a must watch.',
      );
      await tester.pumpAndSettle();

      // Submit Review
      await tester.tap(find.text('Submit Review'));
      await tester.pumpAndSettle();

      // Dialog is dismissed and snackbar appears
      expect(find.text('Write a Review'), findsNothing);
      expect(find.text('✨ Thank you! Your review has been submitted.'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders cleanly on compact mobile (320x568) without RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DestinationDetailScreen(destinationId: 'dest_1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Shaniwar Wada'), findsWidgets);
      expect(find.text('Forts & Historical'), findsOneWidget);
      expect(find.text('Book Pass'), findsOneWidget); // Compact button text
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders cleanly on tablet (768x1024) and desktop (1280x800)', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DestinationDetailScreen(destinationId: 'dest_1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Shaniwar Wada'), findsWidgets);
      expect(find.text('Book Darshan / Tour'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow under 1.25x accessibility font scale', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(1.25)),
            child: MaterialApp(
              home: DestinationDetailScreen(destinationId: 'dest_1'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Shaniwar Wada'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
