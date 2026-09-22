import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pune_explorer/core/enums/app_enums.dart';
import 'package:pune_explorer/core/widgets/custom_button.dart';
import 'package:pune_explorer/features/home/presentation/widgets/darshan_highlight_card.dart';
import 'package:pune_explorer/features/home/presentation/widgets/home_search_bar.dart';
import 'package:pune_explorer/features/explore/presentation/widgets/destination_card.dart';
import 'package:pune_explorer/features/itinerary/presentation/itinerary_planner_screen.dart';
import 'package:pune_explorer/features/budget/presentation/budget_calculator_screen.dart';
import 'package:pune_explorer/features/routes/presentation/routes_screen.dart';
import 'package:pune_explorer/data/models/destination.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const dummyDestination = Destination(
    id: 'test_sinhagad',
    name: 'Sinhagad Fort Historical Trek',
    category: DestinationCategory.forts,
    city: 'Pune',
    state: 'Maharashtra',
    description: 'Ancient hill fortress famous for Tanaji Malusare battle with panoramic Sahyadri views and authentic Pitla Bhakri.',
    longDescription: 'Long description of Sinhagad fort with detailed historical insights and trek routes.',
    images: ['assets/images/destinations/sinhagad.jpg'],
    rating: 4.8,
    reviewCount: 3420,
    entryFeeIndian: 50,
    entryFeeForeign: 200,
    openingHours: '06:00 AM - 06:00 PM',
    distanceFromPuneKm: 32,
    recommendedDuration: '4-5 Hours',
    difficulty: DifficultyLevel.moderate,
    bestTime: 'July to February',
    famousFor: 'Kalyan Darwaza, Tanaji Samadhi, Pitla Bhakri',
    latitude: 18.3663,
    longitude: 73.7559,
    isTrending: true,
    isFeatured: true,
  );

  group('📱 Responsive Design Audit & Viewport Stress Tests', () {
    testWidgets('CustomButton renders long booking text without overflow on 320px width', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 288, // 320 - 32px screen padding
                child: CustomButton(
                  text: 'Pay & Confirm Booking (₹1,498)',
                  icon: const Icon(Icons.lock_rounded, size: 18),
                  isFullWidth: true,
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Pay & Confirm Booking (₹1,498)'), findsOneWidget);
    });

    testWidgets('DarshanHighlightCard adapts without overflow at 320px, 360px, 412px, and 1280px', (tester) async {
      for (final width in [320.0, 360.0, 412.0, 1280.0]) {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: DarshanHighlightCard(),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull, reason: 'Failed at width $width');
        expect(find.text('Official Pune Darshan'), findsOneWidget);
        expect(find.text('₹499 / person'), findsOneWidget);
        expect(find.text('Select Seats & Book'), findsOneWidget);
      }

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('ItineraryPlannerScreen renders on small 320x568 viewport without RenderFlex overflow', (tester) async {
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
    });

    testWidgets('DestinationCard in Grid and List modes renders at 320px with 1.25x accessibility scaling', (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(320, 700),
                textScaler: TextScaler.linear(1.25),
              ),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 288,
                        child: DestinationCard(
                          destination: dummyDestination,
                          isListView: false,
                        ),
                      ),
                      SizedBox(height: 12),
                      DestinationCard(
                        destination: dummyDestination,
                        isListView: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
      expect(find.text('Sinhagad Fort Historical Trek'), findsWidgets);
    });

    testWidgets('HomeSearchBar renders tune icon on mobile (<600px) and ⌘K on desktop (1280px)', (tester) async {
      // Mobile check
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;

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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
      expect(find.text('K'), findsNothing);

      // Desktop check
      tester.view.physicalSize = const Size(1280, 800);
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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('K'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('BudgetCalculatorScreen renders without overflow on 320x568 compact viewport', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: BudgetCalculatorScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
      expect(find.text('Estimated Total Budget'), findsOneWidget);
      expect(find.text('🚗 Transport'), findsOneWidget);
      expect(find.text('🏨 Stay'), findsOneWidget);
    });

    testWidgets('RoutesScreen renders route cards without overflow on 320x568 compact viewport', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RoutesScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('🏛️ Heritage Walks of Pune'), findsOneWidget);
    });
  });
}
