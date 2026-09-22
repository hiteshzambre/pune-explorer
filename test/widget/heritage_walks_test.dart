import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pune_explorer/data/seed/pune_seed_data.dart';
import 'package:pune_explorer/features/heritage_walks/presentation/heritage_walks_screen.dart';
import 'package:pune_explorer/features/heritage_walks/presentation/heritage_walk_detail_screen.dart';
import 'package:pune_explorer/features/heritage_walks/presentation/widgets/turn_by_turn_walk_guide_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('🏛️ Heritage Walks Feature & UI Tests', () {
    testWidgets('HeritageWalksScreen renders header, search bar, category chips, and walk cards', (tester) async {
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
            home: HeritageWalksScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      FlutterError.onError = originalOnError;

      expect(caughtDetails, isNull);
      expect(find.text('🏛️ Heritage Walks of Pune'), findsOneWidget);
      expect(find.text('पुणे वारसा पदभ्रमण'), findsOneWidget);
      expect(find.text('Walk Through 400 Years of History'), findsOneWidget);

      // Verify category chips
      expect(find.text('All Walks'), findsOneWidget);
      expect(find.text('Royal Wadas'), findsOneWidget);

      // Verify walk card
      expect(find.text('Famous Five Ganapatis'), findsOneWidget);
    });

    testWidgets('HeritageWalksScreen category filter toggles category selection', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
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

      // Tap on Royal Wadas category chip
      final royalWadasChip = find.text('Royal Wadas');
      expect(royalWadasChip, findsOneWidget);
      await tester.tap(royalWadasChip);
      await tester.pumpAndSettle();

      expect(find.text('Old Pune Heritage Walk'), findsOneWidget);
    });

    testWidgets('HeritageWalksScreen search filter updates search query results', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
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

      // Enter search query 'Tambat'
      await tester.enterText(find.byType(TextField), 'Tambat');
      await tester.pumpAndSettle();

      expect(find.text('Tambat Aali Copper Craft Walk'), findsOneWidget);
    });

    testWidgets('HeritageWalkDetailScreen renders stops timeline, quick facts, and guidelines without overflow', (tester) async {
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
            home: HeritageWalkDetailScreen(walkId: 'walk_old_pune'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      FlutterError.onError = originalOnError;

      expect(caughtDetails, isNull);
      expect(find.text('Old Pune Heritage Walk'), findsWidgets);
      expect(find.text('The Story Behind The Walk'), findsOneWidget);
      expect(find.text('Interactive Trail Map'), findsOneWidget);
      expect(find.text('Walking Route & Stops'), findsOneWidget);
      expect(find.text('Start Walking Tour'), findsOneWidget);
      expect(find.text('Book Walk'), findsOneWidget);
    });

    testWidgets('HeritageWalkDetailScreen booking section renders date selector, session chips, and walkers counter', (tester) async {
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
            home: HeritageWalkDetailScreen(walkId: 'walk_old_pune'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      FlutterError.onError = originalOnError;

      expect(caughtDetails, isNull);

      // Scroll to booking section
      await tester.scrollUntilVisible(
        find.text('Book Guided Heritage Walk'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Book Guided Heritage Walk'), findsOneWidget);
      expect(find.text('SELECT DATE'), findsOneWidget);
      expect(find.text('Tomorrow'), findsOneWidget);
      expect(find.text('This Saturday'), findsOneWidget);
      expect(find.text('SELECT WALKING SESSION'), findsOneWidget);
      expect(find.text('Morning Batch (06:30 AM – 09:30 AM)'), findsOneWidget);
      expect(find.text('NUMBER OF WALKERS'), findsOneWidget);
      expect(find.text('INCLUDED WITH THIS HISTORIAN PASS'), findsOneWidget);

      // Scroll to walker counter buttons
      await tester.scrollUntilVisible(
        find.byTooltip('Increase walkers'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Tap + to increase walkers
      final addWalkerBtn = find.byTooltip('Increase walkers');
      expect(addWalkerBtn, findsOneWidget);
      await tester.tap(addWalkerBtn);
      await tester.pumpAndSettle();

      expect(find.textContaining('× 2'), findsOneWidget);
    });

    testWidgets('TurnByTurnWalkGuideModal renders stop-by-stop live guidance and advances to next stop', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final walk = PuneSeedData.heritageWalks.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TurnByTurnWalkGuideModal(walk: walk),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('STOP 1 OF ${walk.stops.length}'), findsOneWidget);
      expect(find.text(walk.stops[0].name), findsOneWidget);

      // Tap Next Stop button
      final nextButton = find.text('Next: ${walk.stops[1].name}');
      expect(nextButton, findsOneWidget);
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      expect(find.text('STOP 2 OF ${walk.stops.length}'), findsOneWidget);
      expect(find.text(walk.stops[1].name), findsOneWidget);
    });

    testWidgets('HeritageWalksScreen renders cleanly on 320x568 compact phone without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
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
            home: HeritageWalksScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      FlutterError.onError = originalOnError;

      expect(caughtDetails, isNull);
      expect(find.text('🏛️ Heritage Walks of Pune'), findsOneWidget);
    });

    testWidgets('HeritageWalksScreen renders cleanly on 800x1200 tablet without overflow', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
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
            home: HeritageWalksScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      FlutterError.onError = originalOnError;

      expect(caughtDetails, isNull);
    });

    testWidgets('HeritageWalksScreen renders cleanly on 1440x900 desktop without overflow', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
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
            home: HeritageWalksScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      FlutterError.onError = originalOnError;

      expect(caughtDetails, isNull);
    });
  });
}
