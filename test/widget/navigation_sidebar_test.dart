import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pune_explorer/core/responsive/adaptive_scaffold.dart';
import 'package:pune_explorer/core/providers/app_providers.dart';
import 'package:pune_explorer/data/models/user_profile.dart';
import 'package:pune_explorer/data/repositories/auth_repository.dart';

GoRouter _createTestRouter({String initialLocation = '/test-0'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdaptiveNavigationScaffold(navigationShell: navigationShell);
        },
        branches: List.generate(
          7,
          (index) => StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/test-$index',
                builder: (context, state) => Scaffold(
                  body: Center(child: Text('Screen $index')),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('🏛️ PuneExplorer Exact Premium Navigation Redesign Tests', () {
    // ── 1. Mandatory 14 Breakpoints Zero-Overflow Verification ──────────────
    final breakpoints = <String, Size>{
      '320px (Small Mobile)': const Size(320, 568),
      '360px (Android Compact)': const Size(360, 640),
      '375px (iPhone SE)': const Size(375, 667),
      '390px (iPhone 13/14)': const Size(390, 844),
      '414px (iPhone Plus)': const Size(414, 896),
      '430px (iPhone Pro Max)': const Size(430, 932),
      '600px (Foldable / Small Tablet)': const Size(600, 960),
      '768px (iPad / Tablet)': const Size(768, 1024),
      '820px (iPad Air)': const Size(820, 1180),
      '1024px (Small Laptop)': const Size(1024, 768),
      '1280px (Standard Laptop)': const Size(1280, 800),
      '1366px (Popular Laptop)': const Size(1366, 768),
      '1440px (Large Desktop)': const Size(1440, 900),
      '1920px (Full HD Desktop)': const Size(1920, 1080),
    };

    for (final entry in breakpoints.entries) {
      testWidgets('Zero RenderFlex overflow at ${entry.key}', (WidgetTester tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final router = _createTestRouter();

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(tester.takeException(), isNull, reason: 'Overflow occurred at ${entry.key}');
        expect(find.text('Screen 0'), findsOneWidget);
      });
    }

    // ── 2. Full Desktop Sidebar Visual Hierarchy & Collapsing ───────────────
    testWidgets('Renders full reference visual hierarchy and supports collapse/expand on Desktop (1440x900)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = _createTestRouter();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Branding
      expect(find.text('PuneExplorer'), findsWidgets);
      expect(find.text('Travel • Heritage • Culture'), findsOneWidget);

      // 2. Desktop Header Wide Search Bar with ⌘K shortcut
      expect(find.text('Search destinations, forts, temples, food, experiences...'), findsOneWidget);
      expect(find.text('⌘ K'), findsOneWidget);

      // 3. Desktop Header Quick Links & Notifications
      expect(find.text('My Trips'), findsOneWidget);
      expect(find.text('Saved'), findsOneWidget);
      expect(find.byTooltip('Notifications'), findsOneWidget);

      // 4. Desktop Header Profile Pill
      expect(find.text('Puneri Explorer'), findsOneWidget);
      expect(find.text('Guest Explorer'), findsOneWidget);

      // 5. Main Nav Items with accessible subtitles via Tooltip & Semantics
      expect(find.text('Home'), findsWidgets);
      expect(find.byTooltip('Home: Your travel journey begins'), findsOneWidget);
      expect(find.text('Explore'), findsWidgets);
      expect(find.byTooltip('Explore: Forts, places & experiences'), findsOneWidget);
      expect(find.text('Plan Trip'), findsOneWidget);
      expect(find.byTooltip('Plan Trip: Create your itinerary'), findsOneWidget);
      expect(find.text('Pune Darshan'), findsWidgets);
      expect(find.byTooltip('Pune Darshan: Book tickets & passes'), findsOneWidget);
      expect(find.text('Heritage Walks'), findsWidgets);
      expect(find.byTooltip('Heritage Walks: Guided trails & stories'), findsOneWidget);
      expect(find.text('Budget Planner'), findsOneWidget);
      expect(find.byTooltip('Budget Planner: Plan smart, travel more'), findsOneWidget);

      // 6. PunekarBot Card (Reference Design: Chat with AI)
      expect(find.text('PunekarBot AI'), findsOneWidget);
      expect(find.text('Ask. Plan. Explore. Discover Pune your way.'), findsOneWidget);
      expect(find.text('Chat with AI'), findsOneWidget);

      // 7. Bottom Promo Card ("Preserve Explore Belong")
      expect(find.text('Preserve'), findsOneWidget);
      expect(find.text('Belong'), findsOneWidget);

      // 6. Test Collapse Toggle
      final collapseBtn = find.byTooltip('Collapse sidebar');
      expect(collapseBtn, findsOneWidget);
      await tester.tap(collapseBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // In collapsed state, expand button is shown
      expect(find.byTooltip('Expand navigation sidebar'), findsOneWidget);

      // Expand back
      final expandBtn = find.byTooltip('Expand navigation sidebar');
      await tester.tap(expandBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byTooltip('Collapse sidebar'), findsOneWidget);
    });

    // ── 3. Profile Card Click Navigates to Profile (Branch 6) ────────────────
    testWidgets('Tapping Profile card navigates directly to Profile Branch 6', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = _createTestRouter();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Screen 0'), findsOneWidget);

      final profileCard = find.text('Puneri Explorer');
      expect(profileCard, findsOneWidget);
      await tester.tap(profileCard);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Screen 6'), findsOneWidget);
    });

    // ── 4. Mobile Drawer Opens and Closes Smoothly ──────────────────────────
    testWidgets('Mobile Drawer opens via Scaffold and navigates smoothly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = _createTestRouter();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Open drawer programmatically via ScaffoldState
      final scaffoldState = tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Inside mobile drawer, all branding and items are present
      expect(find.text('DESTINATIONS & TRAILS'), findsOneWidget);
      expect(find.text('PunekarBot AI'), findsOneWidget);

      // Tap on Plan Trip in drawer
      final planTripDrawerItem = find.descendant(
        of: find.byType(Drawer),
        matching: find.widgetWithText(InkWell, 'Plan Trip'),
      );
      expect(planTripDrawerItem, findsOneWidget);
      await tester.tap(planTripDrawerItem);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Screen 2'), findsOneWidget);
    });

    // ── 5. Stress Test: Extremely Long User Name & Subtitles ────────────────
    testWidgets('Handles extreme user name and long content without overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = _createTestRouter();

      const longUser = UserProfile(
        id: 'usr_long',
        name: 'Chhatrapati Shahu Maharaj Tourism Enthusiast Pune Explorer Extraordinaire',
        email: 'extremely_long_puneri_heritage_traveler_address_123456789@maharashtratourism.gov.in',
        isGuest: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => _MockAuthNotifier(longUser)),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
    });
  });
}

class _MockAuthNotifier extends AuthNotifier {
  _MockAuthNotifier(UserProfile user) : super(LocalAuthRepository()) {
    state = AsyncValue.data(user);
  }
}
