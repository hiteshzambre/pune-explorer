import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pune_explorer/features/itinerary/presentation/itinerary_planner_screen.dart';
import 'package:pune_explorer/features/itinerary/presentation/itinerary_detail_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('🗺️ Plan a Trip (ItineraryPlannerScreen) Redesign & 3D Icon Tests', () {
    testWidgets('Renders Hero Banner with 3D badges and smart trip statistics', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ItineraryPlannerScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Custom Itinerary Planner'), findsOneWidget);
      expect(find.text('Smart Trip Studio'), findsOneWidget);
      expect(find.text('SMART PICKS'), findsOneWidget);
      expect(find.text('45+ Curated Spots'), findsOneWidget);
      expect(find.text('Instant Planner'), findsOneWidget);
    });

    testWidgets('Renders Instant Smart AI Generator with 3D themed circuits', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ItineraryPlannerScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Instant Trip Generator'), findsOneWidget);
      expect(find.text('Heritage & Forts'), findsOneWidget);
      expect(find.text('Food & Culture'), findsOneWidget);
      expect(find.text('Lakes & Ghats'), findsOneWidget);
      expect(find.text('Spiritual Darshan'), findsOneWidget);
      expect(find.text('✨ Generate Custom Itinerary'), findsOneWidget);
    });

    testWidgets('Renders Curated Pune Master Circuits with 3D badges & highlights', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ItineraryPlannerScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Scroll down to curated circuits
      await tester.scrollUntilVisible(
        find.text('Curated Pune Master Circuits'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Curated Pune Master Circuits'), findsOneWidget);
      expect(find.text('Monsoon Forts & Waterfalls Trail'), findsWidgets);
      expect(find.text('Old Pune Cultural & Food Trail'), findsOneWidget);
      expect(find.text('Western Ghats Lake & Camping'), findsOneWidget);
    });

    testWidgets('Smart Travel Essentials checklist toggles items interactively', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ItineraryPlannerScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Scroll down until packing checklist is visible
      await tester.scrollUntilVisible(
        find.text('Smart Travel Essentials'),
        250.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Smart Travel Essentials'), findsOneWidget);
      expect(find.text('2 of 5 Packed'), findsOneWidget);

      final itemFinder = find.text('20,000mAh Power Bank');
      expect(itemFinder, findsOneWidget);

      // Tap the unchecked item
      await tester.tap(itemFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('3 of 5 Packed'), findsOneWidget);
    });

    testWidgets('Renders without overflow on compact 320x568 mobile viewport', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ItineraryPlannerScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Custom Itinerary Planner'), findsOneWidget);
      expect(find.text('Smart Trip Studio'), findsOneWidget);
      expect(find.text('Instant Trip Generator'), findsOneWidget);
    });

    testWidgets('Renders with 1.25x accessibility text scaling without overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(360, 720),
                textScaler: TextScaler.linear(1.25),
              ),
              child: ItineraryPlannerScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Custom Itinerary Planner'), findsOneWidget);
      expect(find.text('Smart Trip Studio'), findsOneWidget);
    });

    testWidgets('Renders cleanly on 800x1200 tablet without overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ItineraryPlannerScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Custom Itinerary Planner'), findsOneWidget);
      expect(find.text('Instant Trip Generator'), findsOneWidget);
    });

    testWidgets('Renders cleanly on 1440x900 desktop without overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ItineraryPlannerScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Custom Itinerary Planner'), findsOneWidget);
      expect(find.text('Instant Trip Generator'), findsOneWidget);
    });

    testWidgets('Renders booking option button and opens CustomTripBookingModal', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ItineraryPlannerScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final bookButtonFinder = find.text('Book Private Cab & Guide for this Itinerary');
      await tester.scrollUntilVisible(
        bookButtonFinder,
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(bookButtonFinder, findsOneWidget);

      // Tap the book button to launch the booking modal sheet
      await tester.tap(bookButtonFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('1. Select Private Vehicle Fleet'), findsOneWidget);
      expect(find.text('Private AC Sedan'), findsOneWidget);
      expect(find.text('Sahyadri SUV'), findsOneWidget);
      expect(find.text('Confirm & Reserve Trip'), findsOneWidget);
    });

    testWidgets('ItineraryDetailScreen renders sticky Book This Trip bottom bar', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ItineraryDetailScreen(planId: 'plan_monsoon_weekend'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Book This Trip'), findsOneWidget);
      expect(find.text('Private Cab + Guide Available'), findsOneWidget);

      await tester.tap(find.text('Book This Trip'));
      await tester.pumpAndSettle();

      expect(find.text('1. Select Private Vehicle Fleet'), findsOneWidget);
      expect(find.text('Confirm & Reserve Trip'), findsOneWidget);
    });
  });
}
