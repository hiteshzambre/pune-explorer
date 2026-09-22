import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pune_explorer/core/enums/app_enums.dart';
import 'package:pune_explorer/data/models/destination.dart';
import 'package:pune_explorer/features/explore/presentation/explore_screen.dart';
import 'package:pune_explorer/features/explore/presentation/widgets/destination_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const dummyDestinationShort = Destination(
    id: 'test_short',
    name: 'Shaniwar Wada',
    city: 'Pune',
    state: 'Maharashtra',
    category: DestinationCategory.forts,
    description: 'The historic heart of Pune.',
    longDescription: 'Historic Peshwa palace and fort built in 1732.',
    images: ['https://images.unsplash.com/photo-1599661046289-e31897846e41?q=80&w=600'],
    rating: 4.6,
    reviewCount: 3200,
    latitude: 18.5196,
    longitude: 73.8553,
    entryFeeIndian: 25.0,
    entryFeeForeign: 300.0,
    bestTime: 'October to March',
    openingHours: '8:00 AM - 6:30 PM',
    recommendedDuration: '1-2 hours',
    famousFor: 'Peshwa History, Light & Sound Show',
    difficulty: DifficultyLevel.easy,
    distanceFromPuneKm: 0.0,
  );

  const dummyDestinationLong = Destination(
    id: 'test_long',
    name: 'Sinhagad Fort Sahyadri Heritage Trek & Memorial',
    city: 'Haveli',
    state: 'Pune District',
    category: DestinationCategory.forts,
    description:
        'The Lion Fort rising majestic above the Sahyadris offers panoramic valley views, historic ruins, scenic trails and stories connected with Tanaji Malusare and Maratha military strategy.',
    longDescription: 'Detailed Sinhagad fortress guide with scenic Sahyadri trekking paths.',
    images: ['https://images.unsplash.com/photo-1626015365107-275d4fa5e905?q=80&w=600'],
    rating: 4.8,
    reviewCount: 12500,
    latitude: 18.3663,
    longitude: 73.7558,
    entryFeeIndian: 0.0, // Free entry
    entryFeeForeign: 0.0,
    bestTime: 'Monsoon & Winter',
    openingHours: '5:00 AM - 7:00 PM',
    recommendedDuration: 'Half day trek',
    famousFor: 'Kanda Bhaji, Pithla Bhakri, Trekking',
    difficulty: DifficultyLevel.moderate,
    distanceFromPuneKm: 32.0,
  );

  const dummyDestinationEmptyDesc = Destination(
    id: 'test_empty_desc',
    name: 'Kasarsai Dam Boating Point',
    city: 'Hinjawadi',
    state: 'Pune District',
    category: DestinationCategory.lakesNature,
    description: '',
    longDescription: 'Kasarsai Dam peaceful waterside retreat.',
    images: [],
    rating: 4.2,
    reviewCount: 450,
    latitude: 18.6200,
    longitude: 73.6800,
    entryFeeIndian: 50.0,
    entryFeeForeign: 50.0,
    bestTime: 'Evenings',
    openingHours: '9:00 AM - 6:00 PM',
    recommendedDuration: '',
    famousFor: 'Sunset views, Speed boating',
    difficulty: DifficultyLevel.easy,
    distanceFromPuneKm: 18.0,
  );

  group('Explore Page Content-Driven Card & Layout Tests', () {
    testWidgets('DestinationCard renders short content cleanly without artificial empty space', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: 320,
                  child: DestinationCard(
                    destination: dummyDestinationShort,
                    isListView: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Shaniwar Wada'), findsOneWidget);
      expect(find.text('The historic heart of Pune.'), findsOneWidget);
      expect(find.text('₹25'), findsOneWidget);
      expect(find.text('In City'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DestinationCard renders multi-line title and long description without overflow', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: 280,
                  child: DestinationCard(
                    destination: dummyDestinationLong,
                    isListView: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Free Entry'), findsOneWidget);
      expect(find.text('32 km away'), findsOneWidget);
      expect(find.text('Half day trek'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DestinationCard handles empty description and missing duration cleanly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: 300,
                  child: DestinationCard(
                    destination: dummyDestinationEmptyDesc,
                    isListView: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kasarsai Dam Boating Point'), findsOneWidget);
      expect(find.text('₹50'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    final testBreakpoints = [
      {'name': 'Compact 320px', 'size': const Size(320, 600)},
      {'name': 'Phone 360px', 'size': const Size(360, 720)},
      {'name': 'Phone 375px', 'size': const Size(375, 667)},
      {'name': 'Phone 390px', 'size': const Size(390, 844)},
      {'name': 'Phone 412px', 'size': const Size(412, 915)},
      {'name': 'Phone 430px', 'size': const Size(430, 932)},
      {'name': 'Foldable 600px', 'size': const Size(600, 900)},
      {'name': 'Tablet 768px', 'size': const Size(768, 1024)},
      {'name': 'Small Laptop 1024px', 'size': const Size(1024, 768)},
      {'name': 'Desktop 1280px', 'size': const Size(1280, 800)},
      {'name': 'Wide Desktop 1440px', 'size': const Size(1440, 900)},
      {'name': 'Ultra Wide 1920px', 'size': const Size(1920, 1080)},
    ];

    for (final bp in testBreakpoints) {
      testWidgets('ExploreScreen renders without overflow on ', (tester) async {
        final size = bp['size'] as Size;
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: ExploreScreen(),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Explore Pune Destinations'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('ExploreScreen renders under 1.35x high accessibility scaling on 360px without overflow', (tester) async {
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
                textScaler: TextScaler.linear(1.35),
              ),
              child: ExploreScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Explore Pune Destinations'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ExploreScreen toggles to List View mode and back cleanly', (tester) async {
      tester.view.physicalSize = const Size(412, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ExploreScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final toggleButton = find.byTooltip('Switch to List View');
      expect(toggleButton, findsOneWidget);
      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      expect(find.byTooltip('Switch to Grid View'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
