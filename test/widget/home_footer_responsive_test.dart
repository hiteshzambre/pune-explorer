import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pune_explorer/features/home/presentation/widgets/home_footer.dart';

void main() {
  Widget buildTestFooter({double? textScale, double width = 1280, double height = 900}) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(
              size: Size(width, height),
              textScaler: TextScaler.linear(textScale ?? 1.0),
            ),
            child: const SingleChildScrollView(
              child: HomeFooter(),
            ),
          ),
        ),
      ),
    );
  }

  group('🏰 EXACT Premium Travel Footer Desktop Layout Tests', () {
    testWidgets('Renders panoramic hero branding, cursive quote, and location tag pill', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestFooter(width: 1280, height: 900));
      await tester.pumpAndSettle();

      expect(find.text('PuneExplorer'), findsOneWidget);
      expect(find.text('Travel & Heritage'), findsOneWidget);
      expect(find.text('Discover Pune. Explore its stories.'), findsOneWidget);
      expect(find.text('Explore\n- Pune Beyond\nBoundaries'), findsOneWidget);
      expect(find.text('Forts  •  Culture  •  Nature  •  Food  •  People'), findsOneWidget);
      expect(find.text('A city of heritage, a lifetime of experiences.'), findsOneWidget);
    });

    testWidgets('Renders desktop 4 navigation columns with category headers and links', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestFooter(width: 1440, height: 900));
      await tester.pumpAndSettle();

      // 4 Column Titles
      expect(find.text('DISCOVER PUNE'), findsOneWidget);
      expect(find.text('PLAN & BOOK'), findsOneWidget);
      expect(find.text('TRAVEL TOOLS'), findsOneWidget);
      expect(find.text('SUPPORT & LEGAL'), findsOneWidget);

      // Distinct links
      expect(find.text('Landmarks & Forts'), findsOneWidget);
      expect(find.text('Pune Darshan Tours'), findsOneWidget);
      expect(find.text('Heritage Walks'), findsOneWidget);
      expect(find.text('Itinerary Planner'), findsOneWidget);
      expect(find.text('Tour Packages'), findsOneWidget);
      expect(find.text('Budget Calculator'), findsOneWidget);
      expect(find.text('Omni Search'), findsOneWidget);
      expect(find.text('PunekarBot AI'), findsOneWidget);
      expect(find.text('New'), findsOneWidget); // Saffron New pill badge
      expect(find.text('Help & FAQs'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms & Conditions'), findsOneWidget);
    });

    testWidgets('Renders 3 utility cards (Stay in Loop, 24x7 Support, Socials)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestFooter(width: 1280, height: 900));
      await tester.pumpAndSettle();

      expect(find.text('Stay in the Loop'), findsOneWidget);
      expect(find.text('Subscribe'), findsOneWidget);
      expect(find.text('24x7 Tourist Support'), findsOneWidget);
      expect(find.text('24x7 Tourist Support Hotline'), findsOneWidget);
      expect(find.text('Follow Our Journey'), findsOneWidget);
      expect(find.text('Travel reels, photos and updates'), findsOneWidget);
      expect(find.text('f'), findsOneWidget); // Facebook icon
      expect(find.text('𝕏'), findsOneWidget); // X icon
      expect(find.text('in'), findsOneWidget); // LinkedIn icon
    });

    testWidgets('Renders bottom legal bar and closing brand strip', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestFooter(width: 1440, height: 900));
      await tester.pumpAndSettle();

      expect(find.text('Crafted with ❤️ for Pune & Sahyadri Heritage'), findsOneWidget);
      expect(find.text('Sitemap'), findsOneWidget);
      expect(find.text('Cookies'), findsOneWidget);
      expect(find.text('Accessibility'), findsOneWidget);
      expect(find.text('v2.4.0'), findsOneWidget);
      expect(find.text('More Than a Destination'), findsOneWidget);
      expect(find.text('A Deeper Connection'), findsOneWidget);
    });
  });

  group('📱 Mobile & Responsive Viewport Tests', () {
    testWidgets('Renders collapsible accordions on mobile (390x844)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestFooter(width: 390, height: 844));
      await tester.pumpAndSettle();

      // Accordion headers are visible
      expect(find.text('DISCOVER PUNE'), findsOneWidget);
      expect(find.text('PLAN & BOOK'), findsOneWidget);
      expect(find.text('TRAVEL TOOLS'), findsOneWidget);
      expect(find.text('SUPPORT & LEGAL'), findsOneWidget);

      // Initially collapsed, sublinks not visible
      expect(find.text('Landmarks & Forts'), findsNothing);

      // Tap on DISCOVER PUNE to expand accordion
      await tester.tap(find.text('DISCOVER PUNE'));
      await tester.pumpAndSettle();

      // Sublinks are now visible
      expect(find.text('Landmarks & Forts'), findsOneWidget);
      expect(find.text('Pune Darshan Tours'), findsOneWidget);
      expect(find.text('Heritage Walks'), findsOneWidget);

      // Tap again to collapse
      await tester.tap(find.text('DISCOVER PUNE'));
      await tester.pumpAndSettle();
      expect(find.text('Landmarks & Forts'), findsNothing);
    });

    testWidgets('Renders cleanly on compact mobile (320px) without RenderFlex overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestFooter(width: 320, height: 600));
      await tester.pumpAndSettle();

      expect(find.text('PuneExplorer'), findsOneWidget);
      expect(find.text('Stay in the Loop'), findsOneWidget);
      expect(find.text('24x7 Tourist Support'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders with 1.35x accessibility font scale without overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestFooter(textScale: 1.35, width: 360, height: 780));
      await tester.pumpAndSettle();

      expect(find.text('PuneExplorer'), findsOneWidget);
      expect(find.text('24x7 Tourist Support'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Adapts cleanly to Tablet (768x1024)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestFooter(width: 768, height: 1024));
      await tester.pumpAndSettle();

      expect(find.text('DISCOVER PUNE'), findsOneWidget);
      expect(find.text('PLAN & BOOK'), findsOneWidget);
      expect(find.text('TRAVEL TOOLS'), findsOneWidget);
      expect(find.text('SUPPORT & LEGAL'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Adapts cleanly to Ultra-Wide Desktop (1920x1080)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestFooter(width: 1920, height: 1080));
      await tester.pumpAndSettle();

      expect(find.text('PuneExplorer'), findsOneWidget);
      expect(find.text('More Than a Destination'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('⚡ Interactive Features Tests', () {
    testWidgets('Newsletter subscription validates invalid email and accepts valid email', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestFooter(width: 1200, height: 1600));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Subscribe'));
      await tester.pumpAndSettle();

      // Tap Subscribe with empty email
      await tester.tap(find.text('Subscribe'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid email address'), findsOneWidget);

      // Enter valid email
      await tester.enterText(find.byType(TextField), 'punekar@explorer.com');
      await tester.tap(find.text('Subscribe'));
      await tester.pumpAndSettle();

      expect(find.text('Subscribed to Pune travel updates!'), findsOneWidget);
    });

    testWidgets('Tapping v2.4.0 opens About PuneExplorer modal dialog', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestFooter(width: 1200, height: 1600));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('v2.4.0'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('v2.4.0'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
