import '../../core/enums/app_enums.dart';

class BusSeat {
  final String id; // e.g. "A1", "A2", "B3"
  final int row; // 0 to 6 (A through G)
  final int column; // 0, 1 (Left), 2, 3 (Right)
  final bool isWindow;
  final double extraPrice;
  final SeatState state;

  const BusSeat({
    required this.id,
    required this.row,
    required this.column,
    required this.isWindow,
    this.extraPrice = 0.0,
    this.state = SeatState.available,
  });

  BusSeat copyWith({
    SeatState? state,
    double? extraPrice,
  }) {
    return BusSeat(
      id: id,
      row: row,
      column: column,
      isWindow: isWindow,
      extraPrice: extraPrice ?? this.extraPrice,
      state: state ?? this.state,
    );
  }

  /// Generates the standard 28-seat AC Volvo layout for Pune Darshan & Tours
  static List<BusSeat> generateDefaultSeats({List<String> bookedSeats = const ['A1', 'B2', 'D4', 'F1']}) {
    final List<String> rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
    final List<BusSeat> seats = [];

    for (int r = 0; r < rows.length; r++) {
      for (int c = 0; c < 4; c++) {
        final seatId = '${rows[r]}${c + 1}';
        final isWindow = (c == 0 || c == 3);
        final isBooked = bookedSeats.contains(seatId);

        seats.add(
          BusSeat(
            id: seatId,
            row: r,
            column: c,
            isWindow: isWindow,
            extraPrice: isWindow ? 50.0 : 0.0, // ₹50 nominal window seat preference
            state: isBooked ? SeatState.booked : SeatState.available,
          ),
        );
      }
    }
    return seats;
  }
}
