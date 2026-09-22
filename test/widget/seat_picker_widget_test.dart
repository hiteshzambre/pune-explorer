import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pune_explorer/features/booking/presentation/seat_picker_screen.dart';

void main() {
  group('SeatPickerScreen Widget Tests', () {
    testWidgets('Renders 28 seats and selects seat upon tap', (WidgetTester tester) async {
      List<String> confirmedSeats = [];

      await tester.pumpWidget(
        MaterialApp(
          home: SeatPickerScreen(
            requiredSeatsCount: 2,
            initialSelectedSeats: const [],
            onConfirmed: (seats, _) {
              confirmedSeats = seats;
            },
          ),
        ),
      );

      // Verify instruction banner
      expect(find.text('Select 2 seat(s)'), findsOneWidget);
      expect(find.text('0 / 2 selected'), findsOneWidget);

      // Find seat A2 (available non-window) and seat A3
      final seatA2 = find.text('A2');
      expect(seatA2, findsOneWidget);
      await tester.tap(seatA2);
      await tester.pump();

      // Verify updated selected count
      expect(find.text('1 / 2 selected'), findsOneWidget);

      // Find seat A3 and tap
      final seatA3 = find.text('A3');
      await tester.tap(seatA3);
      await tester.pump();

      expect(find.text('2 / 2 selected'), findsOneWidget);

      // Confirm button is now enabled
      final confirmBtn = find.text('Confirm Seats');
      expect(confirmBtn, findsOneWidget);
      await tester.tap(confirmBtn);
      await tester.pump();

      expect(confirmedSeats.length, 2);
      expect(confirmedSeats.contains('A2'), isTrue);
      expect(confirmedSeats.contains('A3'), isTrue);
    });
  });
}
