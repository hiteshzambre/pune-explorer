import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pune_explorer/core/providers/app_providers.dart';
import 'package:pune_explorer/data/models/cms_models.dart';
import 'package:pune_explorer/features/admin/presentation/widgets/admin_multi_image_picker.dart';
import 'package:pune_explorer/features/admin/presentation/screens/admin_destinations_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('📸 Admin Multi-Image Management System Tests', () {
    testWidgets('AdminMultiImagePicker renders initial images with primary cover badge and counter', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final testImages = [
        'https://images.unsplash.com/photo-1599661046289-e31897846e41',
        'https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272',
      ];

      List<String> outputImages = [];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AdminMultiImagePicker(
                initialImages: testImages,
                onImagesChanged: (updated) => outputImages = updated,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify counter
      expect(find.text('2 / 20 Photos'), findsOneWidget);

      // Verify Primary Cover badge
      expect(find.text('★ PRIMARY COVER'), findsOneWidget);
      expect(find.text('#2'), findsOneWidget);

      // Verify action buttons
      expect(find.text('Add URL'), findsOneWidget);
      expect(find.text('Batch Paste URLs'), findsOneWidget);
      expect(find.text('From Media Library'), findsOneWidget);
      expect(find.text('Clear All'), findsOneWidget);

      // Set second image as primary cover
      final makePrimaryFinder = find.byTooltip('Set as Primary Cover');
      expect(makePrimaryFinder, findsOneWidget);
      await tester.tap(makePrimaryFinder);
      await tester.pumpAndSettle();

      // Output should now have photo-1588668214407 first
      expect(outputImages.first, equals('https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272'));
    });

    testWidgets('AdminMultiImagePicker single URL add dialog inserts new photo', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      List<String> outputImages = [];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AdminMultiImagePicker(
                initialImages: const [],
                onImagesChanged: (updated) => outputImages = updated,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No photos configured yet'), findsOneWidget);

      // Tap Add URL button
      await tester.tap(find.text('Add URL'));
      await tester.pumpAndSettle();

      expect(find.text('Add Image URL'), findsOneWidget);

      // Enter URL
      await tester.enterText(
        find.byType(TextField).first,
        'https://images.unsplash.com/photo-new-place',
      );
      await tester.pumpAndSettle();

      // Tap Add Photo
      await tester.tap(find.text('Add Photo'));
      await tester.pumpAndSettle();

      expect(outputImages.length, equals(1));
      expect(outputImages.first, equals('https://images.unsplash.com/photo-new-place'));
      expect(find.text('1 / 20 Photos'), findsOneWidget);
    });

    testWidgets('AdminMultiImagePicker batch paste dialog imports multiple URLs simultaneously', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      List<String> outputImages = [];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AdminMultiImagePicker(
                initialImages: const [],
                onImagesChanged: (updated) => outputImages = updated,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Batch Paste URLs
      await tester.tap(find.text('Batch Paste URLs'));
      await tester.pumpAndSettle();

      expect(find.text('Batch Import Image URLs'), findsOneWidget);

      const batchText = '''
https://images.unsplash.com/batch-photo-1
https://images.unsplash.com/batch-photo-2
https://images.unsplash.com/batch-photo-3
''';

      await tester.enterText(find.byType(TextField).first, batchText);
      await tester.pumpAndSettle();

      expect(find.text('Detected: 3 valid URLs'), findsOneWidget);

      // Tap Import 3 Photos
      await tester.tap(find.text('Import 3 Photos'));
      await tester.pumpAndSettle();

      expect(outputImages.length, equals(3));
      expect(outputImages[0], equals('https://images.unsplash.com/batch-photo-1'));
      expect(outputImages[1], equals('https://images.unsplash.com/batch-photo-2'));
      expect(outputImages[2], equals('https://images.unsplash.com/batch-photo-3'));
      expect(find.text('3 / 20 Photos'), findsOneWidget);
    });

    test('LocalMediaLibraryRepository bulk batch adds media assets', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(mediaLibraryRepositoryProvider);
      final initialCount = (await repo.getAssets()).length;

      final batchAssets = [
        const MediaAsset(
          id: 'batch_test_1',
          url: 'https://images.unsplash.com/test1',
          title: 'Batch Asset 1',
          altText: 'Alt 1',
          category: 'Heritage',
          uploadedAt: '2026-09-15T12:00:00Z',
          fileSizeKb: 300,
          dimensions: '1920x1080',
          usageCount: 0,
        ),
        const MediaAsset(
          id: 'batch_test_2',
          url: 'https://images.unsplash.com/test2',
          title: 'Batch Asset 2',
          altText: 'Alt 2',
          category: 'Heritage',
          uploadedAt: '2026-09-15T12:00:00Z',
          fileSizeKb: 310,
          dimensions: '1920x1080',
          usageCount: 0,
        ),
      ];

      await repo.addAssets(batchAssets);
      final updatedAssets = await repo.getAssets();
      expect(updatedAssets.length, equals(initialCount + 2));
      expect(updatedAssets.any((a) => a.id == 'batch_test_1'), isTrue);
      expect(updatedAssets.any((a) => a.id == 'batch_test_2'), isTrue);
    });

    testWidgets('AdminDestinationsScreen shows photo count pill and opens multi-image editor in form', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminDestinationsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check destination list card has photo count pill
      expect(find.textContaining('photos'), findsWidgets);

      // Tap Add Destination
      await tester.tap(find.text('Add Destination'));
      await tester.pumpAndSettle();

      expect(find.text('Create New Destination'), findsOneWidget);
      expect(find.text('Destination Photo Gallery'), findsOneWidget);
      expect(find.text('Batch Paste URLs'), findsOneWidget);
    });
  });
}
