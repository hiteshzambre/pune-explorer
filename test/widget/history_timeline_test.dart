import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pune_explorer/features/home/presentation/widgets/history_timeline_section.dart';

void main() {
  const allBreakpoints = [
    320.0,
    360.0,
    390.0,
    412.0,
    480.0,
    600.0,
    768.0,
    840.0,
    1024.0,
    1200.0,
    1280.0,
    1440.0,
    1600.0,
    1920.0,
  ];

  Widget buildTestWidget({
    double width = 1280,
    double height = 900,
    double textScale = 1.0,
    Brightness brightness = Brightness.light,
  }) {
    return MaterialApp(
      theme: ThemeData(
        brightness: brightness,
        useMaterial3: true,
      ),
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, height),
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: width,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: HistoryTimelineSection(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void setTestViewport(WidgetTester tester, double width, [double height = 900]) {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1.0;
  }

  group('🚩 HistoryTimelineSection — Exact Visual Design Tests', () {
    testWidgets('Renders all header titles, badge, and skyline text', (tester) async {
      setTestViewport(tester, 1200);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget(width: 1200));
      await tester.pumpAndSettle();

      expect(find.text('🚩 HERITAGE CHRONICLES'), findsOneWidget);
      expect(find.text('Four Centuries of Puneri Glory'), findsOneWidget);
      expect(
        find.text('A journey through the people, battles, movements and milestones that shaped modern Pune.'),
        findsOneWidget,
      );
      expect(find.text('History Lives Here.'), findsOneWidget);
      expect(find.text('Oldest First'), findsOneWidget);
    });

    testWidgets('Renders all 5 milestone titles, periods, tags, and quotes', (tester) async {
      setTestViewport(tester, 1200);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget(width: 1200));
      await tester.pumpAndSettle();

      // Check all 5 titles
      expect(find.text('Shivaji Maharaj & Childhood at Lal Mahal'), findsOneWidget);
      expect(find.text('Battle of Sinhagad & Tanaji Malusare'), findsOneWidget);
      expect(find.text('Peshwa Era & Shaniwar Wada Capital'), findsOneWidget);
      expect(find.text('Sarvajanik Ganeshotsav Movement'), findsOneWidget);
      expect(find.text('Quit India Movement & Aga Khan Palace'), findsOneWidget);

      // Check all 5 period displays
      expect(find.text('1630s – 1640s'), findsOneWidget);
      expect(find.text('1670'), findsOneWidget);
      expect(find.text('1732 – 1818'), findsOneWidget);
      expect(find.text('1893'), findsOneWidget);
      expect(find.text('1942 – 1944'), findsOneWidget);

      // Check historic quotes
      expect(find.text('“The seeds of Swarajya were sown in Pune.”'), findsOneWidget);
      expect(find.text('“Gad aala pan Sinha gela.”'), findsOneWidget);
      expect(find.text('“Pune rose as the heart of a new India.”'), findsOneWidget);
      expect(find.text('“A festival that united a nation.”'), findsOneWidget);
      expect(find.text('“Sacrifice today for a brighter tomorrow.”'), findsOneWidget);

      // Check key tags
      expect(find.text('Lal Mahal'), findsOneWidget);
      expect(find.text('Sinhagad'), findsOneWidget);
      expect(find.text('Shaniwar Wada'), findsOneWidget);
      expect(find.text('Ganeshotsav'), findsOneWidget);
      expect(find.text('Aga Khan Palace'), findsOneWidget);
    });

    testWidgets('Sort dropdown toggles between Oldest First and Newest First', (tester) async {
      setTestViewport(tester, 1200);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget(width: 1200));
      await tester.pumpAndSettle();

      // Initially, oldest first (1630s is first, 1940s is last)
      final titlesBefore = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).toList();
      final lalMahalIdxBefore = titlesBefore.indexOf('Shivaji Maharaj & Childhood at Lal Mahal');
      final agaKhanIdxBefore = titlesBefore.indexOf('Quit India Movement & Aga Khan Palace');
      expect(lalMahalIdxBefore < agaKhanIdxBefore, isTrue);

      // Tap sort dropdown
      await tester.tap(find.text('Oldest First'));
      await tester.pumpAndSettle();

      // Select Newest First
      await tester.tap(find.text('Newest First').last);
      await tester.pumpAndSettle();

      // Verify order is reversed: Aga Khan is first, Lal Mahal is last
      final titlesAfter = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).toList();
      final lalMahalIdxAfter = titlesAfter.indexOf('Shivaji Maharaj & Childhood at Lal Mahal');
      final agaKhanIdxAfter = titlesAfter.indexOf('Quit India Movement & Aga Khan Palace');
      expect(agaKhanIdxAfter < lalMahalIdxAfter, isTrue);
    });

    testWidgets('Tapping milestone card opens interactive details bottom sheet', (tester) async {
      setTestViewport(tester, 1024);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget(width: 1024));
      await tester.pumpAndSettle();

      // Tap on Lal Mahal milestone card
      await tester.tap(find.text('Shivaji Maharaj & Childhood at Lal Mahal'));
      await tester.pumpAndSettle();

      // Verify details modal opened with action buttons
      expect(find.text('Explore Destination'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // Tap Close button
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Verify modal dismissed
      expect(find.text('Explore Destination'), findsNothing);
    });

    testWidgets('Renders in dark mode with dark styling', (tester) async {
      setTestViewport(tester, 1200);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget(width: 1200, brightness: Brightness.dark));
      await tester.pumpAndSettle();

      expect(find.text('🚩 HERITAGE CHRONICLES'), findsOneWidget);
      expect(find.text('Four Centuries of Puneri Glory'), findsOneWidget);
    });

    testWidgets('Renders with 1.5x accessibility text scaling without overflow on compact 360px screen', (tester) async {
      setTestViewport(tester, 360, 900);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget(width: 360, height: 900, textScale: 1.5));
      await tester.pumpAndSettle();

      expect(find.text('🚩 HERITAGE CHRONICLES'), findsOneWidget);
      expect(find.text('Shivaji Maharaj & Childhood at Lal Mahal'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('📱 HistoryTimelineSection — All 14 Breakpoints Zero-Overflow Verification', () {
    for (final width in allBreakpoints) {
      testWidgets('Renders without overflow at width: ${width}px', (tester) async {
        setTestViewport(tester, width, 1000);
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(buildTestWidget(width: width, height: 1000));
        await tester.pumpAndSettle();

        expect(find.text('🚩 HERITAGE CHRONICLES'), findsOneWidget);
        expect(find.text('Four Centuries of Puneri Glory'), findsOneWidget);
        expect(find.text('Shivaji Maharaj & Childhood at Lal Mahal'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
