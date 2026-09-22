import 'package:flutter_test/flutter_test.dart';
import 'package:pune_explorer/data/models/bus_seat.dart';
import 'package:pune_explorer/core/enums/app_enums.dart';

void main() {
  group('BusSeat 28-Seat Model Tests', () {
    test('Generates exactly 28 seats across 7 rows (A-G)', () {
      final seats = BusSeat.generateDefaultSeats();
      expect(seats.length, 28);

      final rowASeats = seats.where((s) => s.row == 0).toList();
      expect(rowASeats.length, 4);
      expect(rowASeats[0].id, 'A1');
      expect(rowASeats[3].id, 'A4');
    });

    test('Marks window seats accurately (columns 0 and 3)', () {
      final seats = BusSeat.generateDefaultSeats();
      final a1 = seats.firstWhere((s) => s.id == 'A1');
      final a2 = seats.firstWhere((s) => s.id == 'A2');
      final a4 = seats.firstWhere((s) => s.id == 'A4');

      expect(a1.isWindow, isTrue);
      expect(a2.isWindow, isFalse);
      expect(a4.isWindow, isTrue);
    });

    test('Pre-books specified seats in layout', () {
      final seats = BusSeat.generateDefaultSeats(bookedSeats: ['B2', 'C3']);
      final b2 = seats.firstWhere((s) => s.id == 'B2');
      final b1 = seats.firstWhere((s) => s.id == 'B1');

      expect(b2.state, SeatState.booked);
      expect(b1.state, SeatState.available);
    });
  });
}
