import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pune_explorer/data/models/heritage_walk.dart';
import 'package:pune_explorer/features/heritage_walks/presentation/heritage_walks_screen.dart';
import 'package:pune_explorer/features/heritage_walks/presentation/widgets/heritage_walk_card.dart';
import 'package:pune_explorer/features/home/presentation/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const dummyWalkShort = HeritageWalk(
    id: 'walk_short',
    title: 'Old Pune Heritage Walk',
    marathiTitle: 'जुने पुणे वारसा पदभ्रमण',
    subtitle: "Explore old Pune's heritage.",
    description: "Short walking trail through historic core.",
    category: HeritageWalkCategory.royalWadas,
    coverImage: 'https://images.unsplash.com/photo-1599661046289-e31897846e41?q=80',
    durationMinutes: 120,
    distanceKm: 2.5,
    difficulty: WalkDifficulty.easy,
    startLocationName: 'Shaniwar Wada',
    endLocationName: 'Vishrambaug Wada',
    startLatitude: 18.5196,
    startLongitude: 73.8553,
    historicalContext: 'Peshwa Era History',
    stops: [],
    isFeatured: true,
    rating: 4.8,
    price: 699.0,
  );

  const dummyWalkMedium = HeritageWalk(
    id: 'walk_medium',
    title: 'Tambat Aali Copper Craft Walk',
    marathiTitle: 'तांबट आळी तांबे कला पदभ्रमण',
    subtitle: "Walk through Pune's historic streets, wadas and cultural landmarks.",
    description: "Detailed walking tour exploring the rhythmic beating of coppersmiths.",
    category: HeritageWalkCategory.craftsCulture,
    coverImage: 'https://images.unsplash.com/photo-1626015365107-275d4fa5e905?q=80',
    durationMinutes: 90,
    distanceKm: 1.8,
    difficulty: WalkDifficulty.moderate,
    startLocationName: 'Kasba Peth',
    endLocationName: 'Tambat Aali',
    startLatitude: 18.5204,
    startLongitude: 73.8567,
    historicalContext: 'Traditional Metal Crafts of Pune',
    stops: [],
    isFeatured: false,
    rating: 4.7,
    price: 0.0,
  );

  const dummyWalkLong = HeritageWalk(
    id: 'walk_long',
    title: 'Old Pune Peshwa Heritage & Maratha Wada Freedom Trail',
    marathiTitle: 'ऐतिहासिक पेशवे वारसा व मराठा वाडा स्वातंत्र्य लढा पदभ्रमण',
    subtitle: "Walk through Pune's historic streets and discover the architecture, people, traditions and stories that shaped the old city over several centuries.",
    description: "Comprehensive walking tour uncovering hidden courtyards, secret tunnels, wooden facades, and freedom struggle epicenters.",
    category: HeritageWalkCategory.freedomTrail,
    coverImage: 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?q=80',
    durationMinutes: 180,
    distanceKm: 4.2,
    difficulty: WalkDifficulty.extended,
    startLocationName: 'Aga Khan Palace',
    endLocationName: 'Kesari Wada',
    startLatitude: 18.5524,
    startLongitude: 73.9015,
    historicalContext: 'Indian Independence Movement in Pune',
    stops: [],
    isFeatured: true,
    rating: 4.9,
    price: 1250.0,
  );

  const dummyWalkMissingFields = HeritageWalk(
    id: 'walk_missing',
    title: 'Minimalist Heritage Walk',
    marathiTitle: '',
    subtitle: '',
    description: '',
    category: HeritageWalkCategory.sacred,
    coverImage: '',
    durationMinutes: 0,
    distanceKm: 0.0,
    difficulty: WalkDifficulty.easy,
    startLocationName: 'Omkareshwar',
    endLocationName: 'Trishund Ganapati',
    startLatitude: 18.5190,
    startLongitude: 73.8500,
    historicalContext: '',
    stops: [],
    isFeatured: false,
    rating: 0.0,
    price: 0.0,
  );

  group('🏛️ HeritageWalkCard Dynamic Content-Driven Tests', () {
    testWidgets('HeritageWalkCard naturally grows in height with longer content', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: 360,
                  child: HeritageWalkCard(
                    walk: dummyWalkShort,
                    variant: HeritageWalkCardVariant.full,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final shortCardFinder = find.byType(HeritageWalkCard);
      expect(shortCardFinder, findsOneWidget);
      final shortHeight = tester.getSize(shortCardFinder).height;

      // Pump long content in same width
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: 360,
                  child: HeritageWalkCard(
                    walk: dummyWalkLong,
                    variant: HeritageWalkCardVariant.full,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final longCardFinder = find.byType(HeritageWalkCard);
      expect(longCardFinder, findsOneWidget);
      final longHeight = tester.getSize(longCardFinder).height;

      // Card height MUST be dynamic and grow with longer content (Rule 5)
      expect(longHeight, greaterThan(shortHeight));
      expect(tester.takeException(), isNull);
    });

    testWidgets('HeritageWalkCard cleanly collapses missing optional fields without gaps', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: 360,
                  child: HeritageWalkCard(
                    walk: dummyWalkMissingFields,
                    variant: HeritageWalkCardVariant.full,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Minimalist Heritage Walk'), findsAtLeastNWidgets(1));
      expect(find.text('FREE'), findsOneWidget);
      expect(find.text('Free • Self-guided'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('HeritageWalkCard compact variant renders correctly in narrow containers', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: 250,
                  child: HeritageWalkCard(
                    walk: dummyWalkMedium,
                    variant: HeritageWalkCardVariant.compact,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tambat Aali Copper Craft Walk'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('📐 HeritageWalksScreen 12-Breakpoint Responsive Tests', () {
    final testBreakpoints = [
      {'name': 'Compact Small Phone 320px', 'size': const Size(320, 568)},
      {'name': 'Standard Android 360px', 'size': const Size(360, 720)},
      {'name': 'iPhone SE 375px', 'size': const Size(375, 667)},
      {'name': 'iPhone 13/14 390px', 'size': const Size(390, 844)},
      {'name': 'Pixel 7 412px', 'size': const Size(412, 915)},
      {'name': 'iPhone Pro Max 430px', 'size': const Size(430, 932)},
      {'name': 'Foldable Unfolded 600px', 'size': const Size(600, 900)},
      {'name': 'Tablet Portrait 768px', 'size': const Size(768, 1024)},
      {'name': 'Small Laptop / Tablet Landscape 1024px', 'size': const Size(1024, 768)},
      {'name': 'Standard Desktop 1280px', 'size': const Size(1280, 800)},
      {'name': 'Wide Desktop 1440px', 'size': const Size(1440, 900)},
      {'name': 'Ultra Wide Display 1920px', 'size': const Size(1920, 1080)},
    ];

    for (final bp in testBreakpoints) {
      testWidgets('HeritageWalksScreen renders cleanly on ${bp["name"]}', (tester) async {
        final size = bp['size'] as Size;
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: HeritageWalksScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('🏛️ Heritage Walks of Pune'), findsOneWidget);
        expect(find.text('Walk Through 400 Years of History'), findsOneWidget);
        expect(find.text('Famous Five Ganapatis'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('HeritageWalksScreen renders under 1.35x accessibility font scale without overflow', (tester) async {
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
              child: HeritageWalksScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('🏛️ Heritage Walks of Pune'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('🏠 Home "Walk Through Pune" Section Responsive Tests', () {
    testWidgets('Walk Through Pune carousel renders and scrolls horizontally without page overflow', (tester) async {
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

      expect(find.text('Walk Through Pune'), findsOneWidget);
      expect(find.text('All Walks'), findsOneWidget);

      // Find horizontal scrollable
      final horizontalListFinder = find.byWidgetPredicate(
        (widget) => widget is ListView && widget.scrollDirection == Axis.horizontal,
      );
      expect(horizontalListFinder, findsWidgets);

      // Drag the carousel to verify smooth horizontal scrolling
      await tester.drag(horizontalListFinder.first, const Offset(-200, 0));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Home carousel renders under 1.35x accessibility scaling cleanly', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(390, 844),
                textScaler: TextScaler.linear(1.35),
              ),
              child: HomeScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Walk Through Pune'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
