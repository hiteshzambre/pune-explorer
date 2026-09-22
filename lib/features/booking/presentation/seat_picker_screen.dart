import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../data/models/bus_seat.dart';

class SeatPickerScreen extends StatefulWidget {
  final int requiredSeatsCount;
  final List<String> initialSelectedSeats;
  final Function(List<String> selectedSeats, double extraTotal) onConfirmed;

  const SeatPickerScreen({
    super.key,
    required this.requiredSeatsCount,
    this.initialSelectedSeats = const [],
    required this.onConfirmed,
  });

  @override
  State<SeatPickerScreen> createState() => _SeatPickerScreenState();
}

class _SeatPickerScreenState extends State<SeatPickerScreen> {
  late List<BusSeat> _seats;
  final Set<String> _selectedSeatIds = {};

  @override
  void initState() {
    super.initState();
    _seats = BusSeat.generateDefaultSeats();
    _selectedSeatIds.addAll(widget.initialSelectedSeats);
  }

  void _toggleSeat(BusSeat seat) {
    if (seat.state == SeatState.booked || seat.state == SeatState.locked) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seat ${seat.id} is already reserved.')),
      );
      return;
    }

    HapticFeedback.lightImpact();

    setState(() {
      if (_selectedSeatIds.contains(seat.id)) {
        _selectedSeatIds.remove(seat.id);
      } else {
        if (_selectedSeatIds.length >= widget.requiredSeatsCount) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You have selected all ${widget.requiredSeatsCount} seat(s) for your travelers.')),
          );
          return;
        }
        _selectedSeatIds.add(seat.id);
      }
    });
  }

  double _calculateExtra() {
    double total = 0;
    for (final seat in _seats) {
      if (_selectedSeatIds.contains(seat.id)) {
        total += seat.extraPrice;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select 28-Seat Bus'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Instructions Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AC Volvo 2+2 Coach',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      Text(
                        'Select ${widget.requiredSeatsCount} seat(s)',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _selectedSeatIds.length == widget.requiredSeatsCount
                          ? AppColors.emerald
                          : AppColors.saffron,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (_selectedSeatIds.length == widget.requiredSeatsCount
                                  ? AppColors.emerald
                                  : AppColors.saffron)
                              .withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${_selectedSeatIds.length} / ${widget.requiredSeatsCount} selected',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),

            // Legend Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLegendItem('Available', isDark ? AppColors.darkSurfaceVariant : Colors.white, Colors.grey),
                  const SizedBox(width: 14),
                  _buildLegendItem('Selected', AppColors.emerald, Colors.transparent),
                  const SizedBox(width: 14),
                  _buildLegendItem('Window (W)', AppColors.saffron.withValues(alpha: 0.2), AppColors.saffron),
                  const SizedBox(width: 14),
                  _buildLegendItem('Booked', isDark ? Colors.grey[800]! : Colors.grey[400]!, Colors.transparent),
                ],
              ),
            ),

            // Bus Chassis Container
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 360),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 2),
                      boxShadow: AppColors.cardShadow(isDark),
                    ),
                    child: Column(
                      children: [
                        // Windshield curve & Driver Cabin
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('🚪', style: TextStyle(fontSize: 13)),
                                  SizedBox(width: 4),
                                  Text('Entrance', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.black38 : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.sports_motorsports_rounded, size: 14, color: AppColors.saffron),
                                    SizedBox(width: 4),
                                    Text('Captain', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Divider(thickness: 1.2),
                        const SizedBox(height: 12),

                        // 7 Rows (A to G)
                        ...List.generate(7, (rowIndex) {
                          final rowLetters = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
                          final rowLetter = rowLetters[rowIndex];
                          final rowSeats = _seats.where((s) => s.row == rowIndex).toList();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Left 2 Seats (e.g. A1, A2)
                                Row(
                                  children: [
                                    if (rowSeats.isNotEmpty) _buildSeatWidget(rowSeats[0], isDark),
                                    const SizedBox(width: 6),
                                    if (rowSeats.length > 1) _buildSeatWidget(rowSeats[1], isDark),
                                  ],
                                ),

                                // Center Aisle Indicator
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.black26 : const Color(0xFFF1F5F9),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    rowLetter,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                    ),
                                  ),
                                ),

                                // Right 2 Seats (e.g. A3, A4)
                                Row(
                                  children: [
                                    if (rowSeats.length > 2) _buildSeatWidget(rowSeats[2], isDark),
                                    const SizedBox(width: 6),
                                    if (rowSeats.length > 3) _buildSeatWidget(rowSeats[3], isDark),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 6),
                        // Rear emergency exit
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '🚨 REAR EMERGENCY EXIT',
                            style: TextStyle(color: Colors.red, fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Confirmation Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Seats: ${_selectedSeatIds.isEmpty ? 'None selected' : _selectedSeatIds.join(', ')}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                        ),
                        if (_calculateExtra() > 0)
                          Text(
                            '+₹${_calculateExtra().toInt()} (Window seats preference)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: AppColors.emerald, fontWeight: FontWeight.w700),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  CustomButton(
                    text: 'Confirm Seats',
                    onPressed: _selectedSeatIds.length == widget.requiredSeatsCount
                        ? () {
                            HapticFeedback.mediumImpact();
                            widget.onConfirmed(_selectedSeatIds.toList(), _calculateExtra());
                            Navigator.of(context).pop();
                          }
                        : null,
                    variant: ButtonVariant.primary,
                    height: 46,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, Color border) {
    return Row(
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: border),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSeatWidget(BusSeat seat, bool isDark) {
    final isSelected = _selectedSeatIds.contains(seat.id);
    final isBooked = seat.state == SeatState.booked;

    Color bg;
    Color fg;
    Border? border;

    if (isBooked) {
      bg = isDark ? Colors.grey[800]! : Colors.grey[300]!;
      fg = isDark ? Colors.grey[600]! : Colors.grey[500]!;
    } else if (isSelected) {
      bg = AppColors.emerald;
      fg = Colors.white;
    } else {
      bg = isDark ? AppColors.darkSurfaceVariant : Colors.white;
      fg = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
      border = Border.all(
        color: seat.isWindow ? AppColors.saffron.withValues(alpha: 0.6) : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        width: seat.isWindow ? 1.5 : 1.2,
      );
    }

    return Semantics(
      label: 'Seat ${seat.id}, ${isBooked ? 'Booked' : isSelected ? 'Selected' : 'Available'}',
      button: true,
      child: InkWell(
        onTap: () => _toggleSeat(seat),
        borderRadius: BorderRadius.circular(9),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(9),
            border: border,
            boxShadow: isSelected ? AppColors.glowShadow(AppColors.emerald) : null,
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mini headrest
              Container(
                width: 20,
                height: 3.5,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white54 : Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                seat.id,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                ),
              ),
              if (seat.isWindow && !isBooked)
                Text(
                  'W',
                  style: TextStyle(
                    color: isSelected ? Colors.white70 : AppColors.saffron,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
