import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pune_explorer/data/seed/pune_seed_data.dart';
import 'package:pune_explorer/features/home/presentation/home_screen.dart';
import 'package:pune_explorer/features/home/presentation/widgets/category_section.dart';
import 'package:pune_explorer/features/home/presentation/widgets/darshan_highlight_card.dart';
import 'package:pune_explorer/features/home/presentation/widgets/history_timeline_section.dart';
import 'package:pune_explorer/features/home/presentation/widgets/home_search_bar.dart';
import 'package:pune_explorer/features/home/presentation/widgets/home_footer.dart';
import 'package:pune_explorer/features/home/presentation/widgets/hero_carousel.dart';
import 'package:pune_explorer/features/home/presentation/widgets/home_3d_decorations.dart';

void main() {
  group('HomeScreen Component Widget Tests', () {
    testWidgets('HomeSearchBar renders with search input and suggestions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: EdgeInsets.all(16.0),
                child: HomeSearchBar(),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Search forts, lakes, thalis, Darshan...'), findsOneWidget);
      expect(find.text('Sinhagad Fort'), findsOneWidget);
      expect(find.text('Pawna Lake Camping'), findsOneWidget);
    });

    testWidgets('CategorySection displays experience category chips', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CategorySection(),
            ),
          ),
        ),
      );

      expect(find.text('Forts & Historical'), findsOneWidget);
      expect(find.text('Hill Stations & Ghats'), findsOneWidget);
      expect(find.text('Lakes & Waterfalls'), findsOneWidget);
    });

    testWidgets('DarshanHighlightCard renders official bus banner and pricing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DarshanHighlightCard(),
            ),
          ),
        ),
      );

      expect(find.text('Official Pune Darshan'), findsOneWidget);
      expect(find.text('₹499 / person'), findsOneWidget);
      expect(find.text('Select Seats & Book'), findsOneWidget);
    });

    testWidgets('HistoryTimelineSection renders historical events', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: HistoryTimelineSection(),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Four Centuries of Puneri Glory'), findsOneWidget);
      expect(find.text('Battle of Sinhagad & Tanaji Malusare'), findsOneWidget);
      expect(find.text('Quit India Movement & Aga Khan Palace'), findsOneWidget);
    });

    testWidgets('HomeFooter renders brand tagline, quick links, and 24x7 helpline', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: HomeFooter(),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Discover Pune. Explore its stories.'), findsOneWidget);
      expect(find.text('Landmarks & Forts'), findsOneWidget);
      expect(find.text('Pune Darshan Tours'), findsOneWidget);
      expect(find.text('Itinerary Planner'), findsOneWidget);
      expect(find.text('24x7 Tourist Support Hotline'), findsOneWidget);
      expect(find.text('© ${DateTime.now().year} PuneExplorer. All rights reserved.'), findsOneWidget);
    });
  });

  group('👑 Luxury Hero Section & 3D Decorations Tests', () {
    testWidgets('HeroCarousel renders editorial travel branding, greeting, and Explore Pune CTA', (WidgetTester tester) async {
      final dummyDestinations = PuneSeedData.destinations.take(3).toList();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HeroCarousel(destinations: dummyDestinations),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Discover Pune'), findsOneWidget);
      expect(find.text('One place. Thousands of stories.'), findsOneWidget);
      expect(find.text('Explore Pune'), findsOneWidget);
      expect(find.text('PUNE EXPLORER'), findsOneWidget);
      expect(find.text('Pune, MH'), findsOneWidget);
      expect(find.byType(SlowRotatingCompass3D), findsNothing);
      expect(find.byType(FloatingDestinationBadge3D), findsOneWidget);
    });

    testWidgets('3D decorative travel widgets render cleanly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Floating3DLocationPin(),
                SlowRotatingCompass3D(),
                FloatingDestinationBadge3D(
                  title: 'Sinhagad Fort',
                  rating: '4.8',
                  tag: 'Historic Fort',
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Floating3DLocationPin), findsOneWidget);
      expect(find.byType(SlowRotatingCompass3D), findsOneWidget);
      expect(find.byType(FloatingDestinationBadge3D), findsOneWidget);
      expect(find.text('Sinhagad Fort'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
    });

    testWidgets('HeroCarousel adapts cleanly to small phone (320px width) without overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final dummyDestinations = PuneSeedData.destinations.take(2).toList();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: HeroCarousel(destinations: dummyDestinations),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Discover Pune'), findsOneWidget);
      expect(find.text('Explore Pune'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('📱 HomeScreen Full Integration & Responsive Viewport Tests', () {
    testWidgets('HomeScreen renders cleanly on standard mobile (390x844) without RenderFlex overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Discover Pune'), findsOneWidget);
      expect(find.text('Explore by Experience'), findsOneWidget);
      expect(find.text('Trending Pune Getaways'), findsOneWidget);
      expect(find.text('Curated Weekend Packages'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('HomeScreen renders cleanly on compact phone (320x600) without RenderFlex overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Discover Pune'), findsOneWidget);
      expect(find.text('Explore by Experience'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('HomeScreen renders with 1.25x accessibility scaling on 360x720 without overflow', (WidgetTester tester) async {
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
              child: HomeScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Discover Pune'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('HomeScreen renders cleanly on tablet (768x1024) and desktop (1280x800)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Discover Pune'), findsOneWidget);
      expect(find.text('Trending Pune Getaways'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('🌟 Destination Multi-View Details Tests', () {
    testWidgets('DestinationMultiViewSection toggles between Grid, Detailed, and Compact views', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial Grid View is active
      expect(find.byKey(const ValueKey('grid_view')), findsOneWidget);
      expect(find.byIcon(Icons.grid_view_rounded), findsWidgets);
      expect(find.byIcon(Icons.view_agenda_rounded), findsOneWidget);
      expect(find.byIcon(Icons.view_headline_rounded), findsOneWidget);

      // Switch to Detailed View Mode
      await tester.tap(find.byIcon(Icons.view_agenda_rounded));
      await tester.pumpAndSettle();

      // Verify Detailed View is active and displays deep destination details
      expect(find.byKey(const ValueKey('detailed_view')), findsOneWidget);
      expect(find.text('Entry Fee'), findsWidgets);
      expect(find.text('Timings'), findsWidgets);
      expect(find.text('Best Time'), findsWidgets);
      expect(find.text('Quick Preview'), findsWidgets);

      // Switch to Compact View Mode
      await tester.tap(find.byIcon(Icons.view_headline_rounded));
      await tester.pumpAndSettle();

      // Verify Compact View is active
      expect(find.byKey(const ValueKey('compact_view')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Tapping Quick Preview in Detailed View opens interactive multi-tab details modal', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Detailed View
      await tester.tap(find.byIcon(Icons.view_agenda_rounded));
      await tester.pumpAndSettle();

      // Tap on the first "Quick Preview" button
      final quickPreviewBtn = find.text('Quick Preview').first;
      await tester.tap(quickPreviewBtn);
      await tester.pumpAndSettle();

      // Verify the multi-tab bottom sheet modal opened
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Timings & Fees'), findsOneWidget);
      expect(find.text('Highlights & Tips'), findsOneWidget);
      expect(find.text('Open Full Destination Guide'), findsOneWidget);

      // Switch tab to Timings & Fees
      await tester.tap(find.text('Timings & Fees'));
      await tester.pumpAndSettle();
      expect(find.text('Visiting Hours'), findsOneWidget);
      expect(find.text('Entry Fee Structure'), findsOneWidget);

      // Switch tab to Highlights & Tips
      await tester.tap(find.text('Highlights & Tips'));
      await tester.pumpAndSettle();
      expect(find.text('Notable Attractions & Key Spots'), findsOneWidget);
      expect(find.text('Smart Traveler Tips'), findsOneWidget);

      // Close modal
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Overview'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
