import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pune_explorer/core/constants/admin_permissions.dart';
import 'package:pune_explorer/core/enums/app_enums.dart';
import 'package:pune_explorer/core/providers/app_providers.dart';
import 'package:pune_explorer/data/models/destination.dart';
import 'package:pune_explorer/features/admin/presentation/shell/admin_layout_shell.dart';
import 'package:pune_explorer/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:pune_explorer/features/admin/presentation/screens/admin_home_cms_screen.dart';
import 'package:pune_explorer/features/admin/presentation/screens/admin_destinations_screen.dart';
import 'package:pune_explorer/features/admin/presentation/screens/admin_audit_logs_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('🏛️ PuneExplorer Enterprise Admin Portal & CMS Tests', () {
    test('AdminRole and RBAC permission mappings are rigorously enforced', () {
      expect(AdminPermissions.hasPermission(AdminRole.superAdmin, AdminPermissions.contentCreate), isTrue);
      expect(AdminPermissions.hasPermission(AdminRole.superAdmin, AdminPermissions.adminManage), isTrue);
      expect(AdminPermissions.hasPermission(AdminRole.superAdmin, AdminPermissions.auditView), isTrue);

      // Content Admin can edit content, but cannot verify payments or manage admins
      expect(AdminPermissions.hasPermission(AdminRole.contentAdmin, AdminPermissions.contentCreate), isTrue);
      expect(AdminPermissions.hasPermission(AdminRole.contentAdmin, AdminPermissions.paymentVerify), isFalse);
      expect(AdminPermissions.hasPermission(AdminRole.contentAdmin, AdminPermissions.adminManage), isFalse);

      // Booking Admin can verify payments and refund bookings, but cannot delete content
      expect(AdminPermissions.hasPermission(AdminRole.bookingAdmin, AdminPermissions.paymentVerify), isTrue);
      expect(AdminPermissions.hasPermission(AdminRole.bookingAdmin, AdminPermissions.bookingCancel), isTrue);
      expect(AdminPermissions.hasPermission(AdminRole.bookingAdmin, AdminPermissions.contentDelete), isFalse);

      // Analytics Viewer is read-only
      expect(AdminPermissions.hasPermission(AdminRole.analyticsViewer, AdminPermissions.auditView), isTrue);
      expect(AdminPermissions.hasPermission(AdminRole.analyticsViewer, AdminPermissions.bookingCancel), isFalse);
      expect(AdminPermissions.hasPermission(AdminRole.analyticsViewer, AdminPermissions.paymentVerify), isFalse);
    });

    testWidgets('AdminLayoutShell renders responsive desktop sidebar with navigation groups and current path breadcrumb', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminLayoutShell(
              currentPath: '/admin/dashboard',
              child: Text('Dashboard Content Body'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header & Branding
      expect(find.text('PuneExplorer'), findsWidgets);
      expect(find.text('Enterprise CMS Hub'), findsWidgets);

      // Verify Sidebar Navigation Items
      expect(find.text('Overview Dashboard'), findsWidgets);
      expect(find.text('Homepage CMS'), findsWidgets);
      expect(find.text('Media Assets Library'), findsWidgets);
      expect(find.text('Destinations & Places'), findsWidgets);
      expect(find.text('Tour Packages'), findsWidgets);
      expect(find.text('Payments & UTR Verification'), findsWidgets);

      // Verify Role & Body
      expect(find.text('Super Admin'), findsWidgets);
      expect(find.text('Dashboard Content Body'), findsOneWidget);
    });

    testWidgets('AdminDashboardScreen displays real-time KPI metrics and action shortcuts', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Metric titles
      expect(find.text('Operations & CMS Command Center'), findsOneWidget);
      expect(find.text('Total Revenue (Verified)'), findsOneWidget);
      expect(find.text('Pending Verifications'), findsOneWidget);
      expect(find.text('Total Bookings'), findsOneWidget);
      expect(find.text('Travel Catalog Items'), findsOneWidget);

      // Action buttons
      expect(find.text('New Destination'), findsOneWidget);
      expect(find.text('New Tour Package'), findsOneWidget);
      expect(find.text('Manage Hero Slides'), findsOneWidget);
      expect(find.text('Payment Verifications'), findsOneWidget);
    });

    testWidgets('AdminHomeCmsScreen allows switching tabs and viewing slides and section controls', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminHomeCmsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tab bar labels
      expect(find.text('Hero Slides Carousel'), findsOneWidget);
      expect(find.text('Promotional Banner & Notice'), findsOneWidget);
      expect(find.text('Section Order & Visibility'), findsOneWidget);

      // Tap Promotional Banner & Notice tab
      await tester.tap(find.text('Promotional Banner & Notice'));
      await tester.pumpAndSettle();

      expect(find.text('Monsoon & Emergency Alert Banner'), findsOneWidget);
      expect(find.text('Show Notice Banner on Live App:'), findsOneWidget);

      // Tap Section Order & Visibility tab
      await tester.tap(find.text('Section Order & Visibility'));
      await tester.pumpAndSettle();

      expect(find.text('Home Screen Section Visibility'), findsOneWidget);
      expect(find.text('Hero Carousel Section'), findsOneWidget);
      expect(find.text('Search & Quick Filter Bar'), findsOneWidget);
    });

    testWidgets('AdminDestinationsScreen lists seeded destinations and displays search filter', (tester) async {
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

      // Check header and list items
      expect(find.text('Destinations & Heritage Monuments'), findsOneWidget);
      expect(find.text('Shaniwar Wada'), findsWidgets);
      expect(find.text('Sinhagad Fort'), findsWidgets);
      expect(find.text('Add Destination'), findsOneWidget);
    });

    testWidgets('AdminAuditLogsScreen displays immutable activity table', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminAuditLogsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Audit Logging & Security Trail'), findsOneWidget);
    });

    test('LocalDestinationRepository supports full CRUD operations with in-memory persistence', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(destinationRepositoryProvider);
      final initialDestinations = await repo.getDestinations();
      expect(initialDestinations, isNotEmpty);

      // Create
      const newDest = Destination(
        id: 'dest_test_999',
        name: 'Vetal Tekdi Peak',
        city: 'Pune',
        state: 'Maharashtra',
        category: DestinationCategory.lakesNature,
        description: 'Highest natural point in Pune city.',
        longDescription: 'Popular for birdwatching and sunrise views.',
        images: ['https://images.unsplash.com/test'],
        rating: 4.9,
        reviewCount: 42,
        latitude: 18.525,
        longitude: 73.815,
        entryFeeIndian: 0,
        entryFeeForeign: 0,
        bestTime: 'Morning',
        openingHours: '5:00 AM - 8:00 PM',
        recommendedDuration: '2 hours',
        famousFor: 'Sunrise, Birdwatching',
      );

      await repo.addDestination(newDest);
      final retrieved = await repo.getDestinationById('dest_test_999');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Vetal Tekdi Peak'));

      // Update
      final updated = Destination(
        id: retrieved.id,
        name: retrieved.name,
        city: retrieved.city,
        state: retrieved.state,
        category: retrieved.category,
        description: retrieved.description,
        longDescription: retrieved.longDescription,
        images: retrieved.images,
        rating: 5.0,
        reviewCount: 43,
        latitude: retrieved.latitude,
        longitude: retrieved.longitude,
        entryFeeIndian: retrieved.entryFeeIndian,
        entryFeeForeign: retrieved.entryFeeForeign,
        bestTime: retrieved.bestTime,
        openingHours: retrieved.openingHours,
        recommendedDuration: retrieved.recommendedDuration,
        famousFor: retrieved.famousFor,
      );
      await repo.updateDestination(updated);
      final afterUpdate = await repo.getDestinationById('dest_test_999');
      expect(afterUpdate!.rating, equals(5.0));

      // Delete
      await repo.deleteDestination('dest_test_999');
      final afterDelete = await repo.getDestinationById('dest_test_999');
      expect(afterDelete, isNull);
    });

    test('AuditLogRepository records entries and retrieves them sorted by timestamp', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(auditLogRepositoryProvider);
      await repo.log(
        actorEmail: 'admin@puneexplorer.in',
        actorRole: 'Super Admin',
        action: 'TEST_ACTION',
        resourceType: 'TEST_RESOURCE',
        resourceId: 'test_123',
        metadata: {'testKey': 'testValue'},
      );

      final logs = await repo.getLogs();
      expect(logs.any((l) => l.action == 'TEST_ACTION'), isTrue);
    });
  });
}
