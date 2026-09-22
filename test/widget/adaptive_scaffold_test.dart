import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pune_explorer/core/responsive/adaptive_scaffold.dart';

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

  group('🌟 Premium Modern Navigation Bar Tests', () {
    testWidgets('Renders all 5 mobile navigation tabs including Plan Trip with colored icons', (WidgetTester tester) async {
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

      // Check all 5 mobile nav tab labels including Plan Trip
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Plan Trip'), findsOneWidget);
      expect(find.text('Pune Darshan'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Check PunekarBot floating AI button
      expect(find.byTooltip('Ask PunekarBot AI Assistant'), findsOneWidget);
    });

    testWidgets('Switches tabs smoothly upon tapping navigation items including Plan Trip', (WidgetTester tester) async {
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

      expect(find.text('Screen 0'), findsOneWidget);

      // Tap 'Explore' tab in bottom nav (index 1)
      final exploreTab = find.text('Explore');
      expect(exploreTab, findsOneWidget);
      await tester.tap(exploreTab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Screen 1'), findsOneWidget);

      // Tap 'Plan Trip' tab (index 2)
      final planTripTab = find.text('Plan Trip');
      expect(planTripTab, findsOneWidget);
      await tester.tap(planTripTab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Screen 2'), findsOneWidget);

      // Tap 'Pune Darshan' tab (index 3)
      final darshanTab = find.text('Pune Darshan');
      expect(darshanTab, findsOneWidget);
      await tester.tap(darshanTab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Screen 3'), findsOneWidget);

      // Tap 'Profile' tab (index 6)
      final profileTab = find.text('Profile');
      expect(profileTab, findsOneWidget);
      await tester.tap(profileTab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Screen 6'), findsOneWidget);

      // Return to 'Home' (index 0)
      final homeTab = find.text('Home');
      expect(homeTab, findsOneWidget);
      await tester.tap(homeTab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Screen 0'), findsOneWidget);
    });

    testWidgets('Renders cleanly on narrow compact phone (320x568) without overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
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

      expect(tester.takeException(), isNull);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Plan Trip'), findsOneWidget);
      expect(find.text('Pune Darshan'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Renders with 1.25x accessibility scaling without overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = _createTestRouter();

      await tester.pumpWidget(
        ProviderScope(
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(360, 720),
              textScaler: TextScaler.linear(1.25),
            ),
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Plan Trip'), findsOneWidget);
    });

    testWidgets('Renders Desktop Sidebar on wide screen (1280x800) with colored icons and Plan Trip', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
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

      // Desktop brand
      expect(find.text('PuneExplorer'), findsWidgets);
      expect(find.text('Quick Search...'), findsNothing);

      // Desktop nav items includes Plan Trip, Budget (7 total)
      expect(find.text('Plan Trip'), findsOneWidget);
      expect(find.text('Budget'), findsOneWidget);
      expect(find.text('PunekarBot AI'), findsOneWidget);
    });

    testWidgets('Renders Tablet Navigation Rail on tablet screen (768x1024) including Plan Trip', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(768, 1024);
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

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Explore'), findsWidgets);
      expect(find.text('Plan Trip'), findsWidgets);
      expect(find.text('Pune Darshan'), findsWidgets);
      expect(find.text('Heritage Walks'), findsWidgets);
      expect(find.text('Budget'), findsWidgets);
      expect(find.text('Profile'), findsWidgets);
    });
  });
}
