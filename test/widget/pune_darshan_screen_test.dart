import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pune_explorer/features/darshan/presentation/pune_darshan_screen.dart';

void main() {
  group('🚌 PuneDarshanScreen Redesign & Responsive Tests', () {
    testWidgets('renders cleanly on small mobile (320x600) without RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PuneDarshanScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pune Darshan Bus Tours'), findsOneWidget);
      expect(find.text('Pune Darshan Sightseeing Tours'), findsOneWidget);
      expect(find.text('Official 7-Stop Circuit'), findsOneWidget);
      expect(find.text('Shaniwar Wada'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders on standard phone (390x844) with full tour cards & stops', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PuneDarshanScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PMPML & MTDC OFFICIAL'), findsOneWidget);
      expect(find.text('Select Tour Package'), findsOneWidget);
      expect(find.text('Classic Pune Darshan'), findsOneWidget);
      expect(find.text('Boarding Points & Morning Timings'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders on tablet (768x1024) and desktop (1280x800) in responsive multi-column layout', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PuneDarshanScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pune Darshan Bus Tours'), findsOneWidget);
      expect(find.text('Onboard Luxury Amenities'), findsOneWidget);
      expect(find.text('Frequently Asked Questions'), findsOneWidget);

      // Verify desktop renders 3 tour cards per row in GridView
      final packageGrid = tester.widget<GridView>(find.byType(GridView).first);
      final gridDelegate = packageGrid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(gridDelegate.crossAxisCount, equals(3));
      expect(gridDelegate.mainAxisExtent, equals(512));

      // Test tablet 768px adapts to 2 tour cards per row
      tester.view.physicalSize = const Size(768, 1024);
      await tester.pumpAndSettle();
      final tabletGrid = tester.widget<GridView>(find.byType(GridView).first);
      final tabletDelegate = tabletGrid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(tabletDelegate.crossAxisCount, equals(2));

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders with 1.25x accessibility scaling on narrow 360px screen without overflow', (tester) async {
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
              child: PuneDarshanScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pune Darshan Bus Tours'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('category filter chips filter tour packages correctly', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PuneDarshanScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially All Tours has multiple tours
      expect(find.text('Classic Pune Darshan'), findsOneWidget);
      expect(find.text('Sinhagad Sunrise & Pithla-Bhakri'), findsOneWidget);

      // Tap "Official Darshan" filter chip
      await tester.tap(find.text('Official Darshan'));
      await tester.pumpAndSettle();

      expect(find.text('Classic Pune Darshan'), findsOneWidget);
      expect(find.text('Sinhagad Sunrise & Pithla-Bhakri'), findsNothing);

      // Tap "All Tours" again
      await tester.tap(find.text('All Tours'));
      await tester.pumpAndSettle();
      expect(find.text('Sinhagad Sunrise & Pithla-Bhakri'), findsOneWidget);
    });

    testWidgets('tapping "View Hour-by-Hour Itinerary & Stops" opens itinerary bottom sheet', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PuneDarshanScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to the first itinerary button
      final itineraryBtn = find.text('View Full Day Itinerary & Stops').first;
      await tester.scrollUntilVisible(
        itineraryBtn,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(itineraryBtn);
      await tester.pumpAndSettle();

      // Modal sheet should now be open
      expect(find.text('Hour-by-Hour Schedule'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('What is Included'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('What is Included'), findsOneWidget);
      expect(find.text('Total per seat'), findsOneWidget);

      // Close modal sheet
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Hour-by-Hour Schedule'), findsNothing);
    });

    testWidgets('expanding FAQ tile shows answer content', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PuneDarshanScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to FAQ section using the main vertical scrollable
      await tester.scrollUntilVisible(
        find.text('How does the VIP Dagdusheth Ganpati Darshan work?'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('How does the VIP Dagdusheth Ganpati Darshan work?'), findsOneWidget);

      // Tap to expand
      await tester.tap(find.text('How does the VIP Dagdusheth Ganpati Darshan work?'));
      await tester.pumpAndSettle();

      expect(find.textContaining('authorized express group pass'), findsOneWidget);
    });
  });
}
