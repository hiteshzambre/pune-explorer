import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/error_boundary.dart';
import '../../../data/models/booking.dart';
import '../../../data/models/destination.dart';
import '../../../data/models/tour_customization.dart';

/// Interactive modal sheet to book an entry pass for an individual destination
void showDestinationBookingModal(BuildContext context, Destination destination) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DestinationBookingModal(destination: destination),
  );
}

/// Standalone Full-Screen for direct route navigation (`/destination/:id/book`)
class DestinationBookingScreen extends ConsumerWidget {
  final String destinationId;

  const DestinationBookingScreen({super.key, required this.destinationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final destinationsAsync = ref.watch(destinationsAsyncProvider);

    return destinationsAsync.when(
      data: (destinations) {
        final destination = destinations
            .where((d) => d.id == destinationId)
            .firstOrNull;

        if (destination == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Book Entry Pass')),
            body: const ErrorBoundaryWidget(
              errorMessage: 'Destination not found for booking.',
            ),
          );
        }

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF090D16) : AppColors.creamBg,
          appBar: AppBar(
            backgroundColor: AppColors.deepForest,
            title: Text(
              'Book Pass: ${destination.name}',
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w800),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go('/destination/${destination.id}');
                }
              },
            ),
          ),
          body: MaxWidthWrapper(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              child: DestinationBookingContent(
                destination: destination,
                isModal: false,
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.deepForest,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.goldAccent),
        ),
      ),
      error: (e, _) => Scaffold(
        body: ErrorBoundaryWidget(errorMessage: e.toString()),
      ),
    );
  }
}

/// Bottom Sheet Wrapper for Destination Booking
class DestinationBookingModal extends StatelessWidget {
  final Destination destination;

  const DestinationBookingModal({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.50,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 25, offset: Offset(0, -6)),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 6),
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: DestinationBookingContent(
                    destination: destination,
                    isModal: true,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Core Interactive Booking Form & Logic
class DestinationBookingContent extends ConsumerStatefulWidget {
  final Destination destination;
  final bool isModal;

  const DestinationBookingContent({
    super.key,
    required this.destination,
    this.isModal = false,
  });

  @override
  ConsumerState<DestinationBookingContent> createState() =>
      _DestinationBookingContentState();
}

class _DestinationBookingContentState
    extends ConsumerState<DestinationBookingContent> {
  // Pass Type: 0 = Standard Pass, 1 = Guided Heritage Pass, 2 = VIP Explorer Pass
  int _selectedPassTypeIndex = 0;

  // Visit Date & Slot
  late DateTime _selectedDate;
  int _selectedDateOffset = 0; // 0: Today, 1: Tomorrow, 2: Day After, 3: Custom
  String _selectedTimeSlot = 'Morning (09:00 AM - 11:30 AM)';

  // Visitors Count
  int _adultCount = 1;
  int _studentCount = 0;
  int _foreignCount = 0;

  // Add-ons
  bool _includeAudioGuide = false;
  bool _includeCameraPermit = false;
  bool _includeHistorianGuide = false;

  // Contact Info
  final _nameController = TextEditingController(text: 'Punekar Explorer');
  final _emailController = TextEditingController(text: 'explorer@puneheritage.in');
  final _phoneController = TextEditingController(text: '+91 98220 12345');
  String _selectedIdProof = 'Aadhaar Card';

  // Coupon Engine
  final _couponController = TextEditingController();
  bool _isCouponApplied = false;
  double _appliedDiscount = 0.0;
  String? _couponMessage;

  bool _isSubmitting = false;

  final List<String> _timeSlots = [
    'Morning (09:00 AM - 11:30 AM)',
    'Afternoon (12:00 PM - 03:00 PM)',
    'Evening (03:30 PM - 06:00 PM)',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  // Pass Types
  List<Map<String, dynamic>> get _passTypes {
    return [
      {
        'title': 'Standard Entry Pass',
        'badge': 'Official Entry',
        'extraPerPerson': 0.0,
        'icon': Icons.confirmation_number_outlined,
        'description': 'Standard entry permit with QR gate scan & access to historic grounds.',
      },
      {
        'title': 'Guided Heritage Walk',
        'badge': 'Historian Guide',
        'extraPerPerson': 199.0,
        'icon': Icons.record_voice_over_outlined,
        'description': 'Includes monument entry plus 60-min guided story walkthrough with a certified local historian.',
      },
      {
        'title': 'VIP Explorer Experience',
        'badge': 'All-Inclusive',
        'extraPerPerson': 399.0,
        'icon': Icons.stars_rounded,
        'description': 'Entry, private certified guide, camera permit, & complimentary Pune souvenir / snack pass.',
      },
    ];
  }

  // Pricing calculations
  double get _baseEntryTotal {
    final indianRate = widget.destination.entryFeeIndian;
    final foreignRate = widget.destination.entryFeeForeign > 0
        ? widget.destination.entryFeeForeign
        : (indianRate > 0 ? indianRate * 4 : 100.0);

    final adultTotal = _adultCount * indianRate;
    final studentTotal = _studentCount * (indianRate * 0.5); // 50% student discount
    final foreignTotal = _foreignCount * foreignRate;
    return adultTotal + studentTotal + foreignTotal;
  }

  int get _totalVisitors => _adultCount + _studentCount + _foreignCount;

  double get _passTypeUpgradeTotal {
    final extra = _passTypes[_selectedPassTypeIndex]['extraPerPerson'] as double;
    return extra * _totalVisitors;
  }

  double get _addonsTotal {
    double sum = 0.0;
    if (_includeAudioGuide) sum += 99.0 * _totalVisitors;
    if (_includeCameraPermit) sum += 50.0;
    if (_includeHistorianGuide && _selectedPassTypeIndex == 0) sum += 299.0;
    return sum;
  }

  double get _subtotal => _baseEntryTotal + _passTypeUpgradeTotal + _addonsTotal;

  double get _gst => _subtotal > 0 ? _subtotal * 0.05 : 0.0; // 5% GST

  double get _grandTotal => max(0.0, _subtotal + _gst - _appliedDiscount);

  void _applyCoupon(List<dynamic> availableCoupons) {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    if (_subtotal <= 0) {
      setState(() {
        _couponMessage = 'Coupon cannot be applied to free entry passes.';
      });
      return;
    }

    if (code == 'PUNEPASS20' || code == 'PUNE20') {
      setState(() {
        _isCouponApplied = true;
        _appliedDiscount = min(200.0, _subtotal * 0.20);
        _couponMessage = '20% Pune Heritage discount applied!';
      });
    } else if (code == 'HERITAGE10' || code == 'EXPLORE10') {
      setState(() {
        _isCouponApplied = true;
        _appliedDiscount = min(100.0, _subtotal * 0.10);
        _couponMessage = '10% Explorer discount applied!';
      });
    } else {
      setState(() {
        _isCouponApplied = false;
        _appliedDiscount = 0.0;
        _couponMessage = 'Invalid coupon code. Try PUNEPASS20 or HERITAGE10.';
      });
    }
  }

  Future<void> _handleBookPass() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide your name, email, and phone number.')),
      );
      return;
    }

    if (_totalVisitors <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 1 visitor.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dest = widget.destination;
      final bookingId = 'DEST-${dest.id.replaceAll('dest_', '')}-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
      final passTypeName = _passTypes[_selectedPassTypeIndex]['title'] as String;
      final dateStr = DateFormat('EEE, dd MMM yyyy').format(_selectedDate);

      final passengers = <Passenger>[];
      for (int i = 0; i < _adultCount; i++) {
        passengers.add(Passenger(
          fullName: i == 0 ? name : 'Visitor ${i + 1} (Adult)',
          age: 30,
          gender: 'Adult',
          seatNumber: 'ENTRY-${i + 1}',
        ));
      }
      for (int i = 0; i < _studentCount; i++) {
        passengers.add(Passenger(
          fullName: 'Student ${i + 1}',
          age: 18,
          gender: 'Student',
          seatNumber: 'STU-${i + 1}',
        ));
      }
      for (int i = 0; i < _foreignCount; i++) {
        passengers.add(Passenger(
          fullName: 'International Visitor ${i + 1}',
          age: 32,
          gender: 'International',
          seatNumber: 'INT-${i + 1}',
        ));
      }

      final isFreePass = _grandTotal == 0.0;

      final booking = Booking(
        id: bookingId,
        tourId: 'DEST_${dest.id}',
        tourTitle: '${dest.name} - $passTypeName',
        travelDate: '$dateStr ($_selectedTimeSlot)',
        pickupPoint: '${dest.name} - Entry Gate (${dest.city})',
        passengers: passengers,
        selectedSeats: [
          'Pass: $passTypeName',
          'Slot: $_selectedTimeSlot',
          'Total Pax: $_totalVisitors',
        ],
        basePrice: _baseEntryTotal,
        seatExtraPrice: _passTypeUpgradeTotal + _addonsTotal,
        discountAmount: _appliedDiscount,
        appliedCoupon: _isCouponApplied ? _couponController.text.trim().toUpperCase() : null,
        gstAmount: _gst,
        platformFee: 0.0,
        totalAmount: _grandTotal,
        status: isFreePass ? BookingStatus.confirmed : BookingStatus.pendingPayment,
        createdAt: DateTime.now().toIso8601String(),
        paymentId: isFreePass ? 'FREE_PASS_${dest.id.toUpperCase()}' : null,
        customerName: name,
        customerEmail: email,
        customerPhone: phone,
        verificationHash: Booking.generatePassHash(bookingId, phone),
        customization: TourCustomization(
          travelersCount: _totalVisitors,
        ),
      );

      if (isFreePass) {
        // Free monument entry pass: immediately confirmed!
        final confirmedBooking = booking.copyWith(
          paymentStatus: PaymentStatus.paid,
          paymentMethod: 'Free Monument Permit',
          verifiedAt: DateTime.now().toIso8601String(),
        );

        await ref.read(userBookingsProvider.notifier).addBooking(confirmedBooking);

        if (mounted) {
          setState(() => _isSubmitting = false);
          if (widget.isModal && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Text('🎟️', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Free Entry Pass Issued for ${dest.name}!',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Booking ID: $bookingId • Digital Ticket Ready',
                            style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF064E3B),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );

          context.push('/digital-ticket/${confirmedBooking.id}');
        }
      } else {
        // Paid monument pass: create PaymentOrder and redirect to UPI QR payment
        final order = await ref.read(paymentOrdersProvider.notifier).createOrder(
          bookingId: booking.id,
          userId: email,
          packageId: 'DEST_${dest.id}',
          packageName: '${dest.name} - Entry Pass',
          amount: _grandTotal,
        );

        final linkedBooking = booking.copyWith(
          orderId: order.orderId,
          paymentStatus: PaymentStatus.pendingPayment,
          paymentMethod: 'UPI QR',
        );

        await ref.read(userBookingsProvider.notifier).addBooking(linkedBooking);

        if (mounted) {
          setState(() => _isSubmitting = false);
          if (widget.isModal && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Text('🏛️', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pass Reserved for ${dest.name}!',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Order: ${order.orderId} • Complete Payment via UPI QR',
                            style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF003C36),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );

          context.push('/payment/qr/${order.orderId}');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not create destination pass: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dest = widget.destination;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Destination Header Summary Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              AppCardImage(
                imageUrl: dest.primaryImage,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(14),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.emerald.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              dest.category.label,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.emerald,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: AppColors.goldAccent),
                            const SizedBox(width: 2),
                            Text(
                              dest.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      dest.name,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.darkText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            dest.openingHours,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 2. Select Experience / Pass Type
        _buildSectionTitle('1. Choose Visit Pass Type', 'Official entry permits & guided experiences'),
        const SizedBox(height: 10),
        ...List.generate(_passTypes.length, (index) {
          final item = _passTypes[index];
          final isSelected = _selectedPassTypeIndex == index;
          final extra = item['extraPerPerson'] as double;

          return InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedPassTypeIndex = index);
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFECFDF5))
                    : (isDark ? const Color(0xFF1E293B) : Colors.white),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppColors.emerald : borderColor,
                  width: isSelected ? 1.8 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    item['icon'] as IconData,
                    color: isSelected ? AppColors.emerald : Colors.grey,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['title'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: isSelected ? AppColors.emerald : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              extra == 0
                                  ? (dest.entryFeeIndian == 0 ? 'Free' : '₹${dest.entryFeeIndian.toInt()}')
                                  : '+₹${extra.toInt()}/pax',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: isSelected ? AppColors.emerald : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item['description'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),

        // 3. Visit Date & Time Slot
        _buildSectionTitle('2. Visit Date & Slot', 'Permits are slot-controlled to prevent overcrowding'),
        const SizedBox(height: 10),

        // Date selection chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildDateChip('Today', DateTime.now(), 0),
              const SizedBox(width: 8),
              _buildDateChip('Tomorrow', DateTime.now().add(const Duration(days: 1)), 1),
              const SizedBox(width: 8),
              _buildDateChip('Day After', DateTime.now().add(const Duration(days: 2)), 2),
              const SizedBox(width: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 60)),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                      _selectedDateOffset = 3;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: _selectedDateOffset == 3
                        ? AppColors.emerald
                        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 14,
                        color: _selectedDateOffset == 3 ? Colors.white : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _selectedDateOffset == 3
                            ? DateFormat('dd MMM').format(_selectedDate)
                            : 'Pick Date',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _selectedDateOffset == 3 ? Colors.white : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Time slot chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _timeSlots.map((slot) {
            final isSelected = _selectedTimeSlot == slot;
            return ChoiceChip(
              label: Text(slot, style: TextStyle(fontSize: 11.5, fontWeight: isSelected ? FontWeight.bold : null)),
              selected: isSelected,
              selectedColor: AppColors.emerald.withValues(alpha: 0.2),
              side: BorderSide(
                color: isSelected ? AppColors.emerald : borderColor,
              ),
              onSelected: (val) {
                if (val) setState(() => _selectedTimeSlot = slot);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // 4. Visitors Count Steppers
        _buildSectionTitle('3. Visitors', 'Add all adult and student travelers in your party'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              _buildVisitorCounterRow(
                title: 'Indian Adults (12+ yrs)',
                subtitle: dest.entryFeeIndian == 0 ? 'Free Entry' : '₹${dest.entryFeeIndian.toInt()} per ticket',
                count: _adultCount,
                onChanged: (val) => setState(() => _adultCount = max(1, val)),
                isDark: isDark,
              ),
              const Divider(height: 18),
              _buildVisitorCounterRow(
                title: 'Children / Students',
                subtitle: dest.entryFeeIndian == 0 ? 'Free Entry' : '₹${(dest.entryFeeIndian * 0.5).toInt()} (50% Concession)',
                count: _studentCount,
                onChanged: (val) => setState(() => _studentCount = max(0, val)),
                isDark: isDark,
              ),
              const Divider(height: 18),
              _buildVisitorCounterRow(
                title: 'International Tourists',
                subtitle: dest.entryFeeForeign > 0 ? '₹${dest.entryFeeForeign.toInt()} per pass' : '₹100 ASI Foreign Rate',
                count: _foreignCount,
                onChanged: (val) => setState(() => _foreignCount = max(0, val)),
                isDark: isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 5. Add-on Services
        _buildSectionTitle('4. Add-on Services', 'Optional enhancements for your visit'),
        const SizedBox(height: 10),
        _buildAddonTile(
          icon: Icons.headphones_rounded,
          title: 'Audio Guide Device Rental',
          subtitle: 'Available in English, Marathi, & Hindi at entrance counter (₹99/pax)',
          value: _includeAudioGuide,
          onChanged: (val) => setState(() => _includeAudioGuide = val ?? false),
          isDark: isDark,
          borderColor: borderColor,
        ),
        _buildAddonTile(
          icon: Icons.camera_alt_outlined,
          title: 'Photography & DSLR Camera Permit',
          subtitle: 'Official monument photography permit tag (₹50 flat)',
          value: _includeCameraPermit,
          onChanged: (val) => setState(() => _includeCameraPermit = val ?? false),
          isDark: isDark,
          borderColor: borderColor,
        ),
        if (_selectedPassTypeIndex == 0)
          _buildAddonTile(
            icon: Icons.person_pin_circle_outlined,
            title: 'Dedicated Local Historian Guide',
            subtitle: 'Certified Pune guide meets you at the gate (₹299 group)',
            value: _includeHistorianGuide,
            onChanged: (val) => setState(() => _includeHistorianGuide = val ?? false),
            isDark: isDark,
            borderColor: borderColor,
          ),
        const SizedBox(height: 20),

        // 6. Visitor Contact Details
        _buildSectionTitle('5. Lead Visitor Details', 'Required for official digital pass verification'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name (as per Govt ID)',
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address (for e-Ticket delivery)',
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _selectedIdProof,
                decoration: InputDecoration(
                  labelText: 'ID Verification Type',
                  prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'Aadhaar Card', child: Text('Aadhaar Card')),
                  DropdownMenuItem(value: 'Passport', child: Text('Passport')),
                  DropdownMenuItem(value: 'Driving License', child: Text('Driving License')),
                  DropdownMenuItem(value: 'Student ID', child: Text('Student ID')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedIdProof = val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 7. Coupon Section
        _buildSectionTitle('6. Offers & Promo Code', 'Apply discount coupon'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _couponController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Try PUNEPASS20',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CustomButton(
              text: 'Apply',
              variant: ButtonVariant.secondary,
              height: 46,
              onPressed: () => _applyCoupon([]),
            ),
          ],
        ),
        if (_couponMessage != null) ...[
          const SizedBox(height: 6),
          Text(
            _couponMessage!,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: _isCouponApplied ? AppColors.emerald : AppColors.error,
            ),
          ),
        ],
        const SizedBox(height: 24),

        // 8. Price Breakdown Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131C2E) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fare Breakdown',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
              const SizedBox(height: 12),
              _buildSummaryLine('Entry Passes ($_totalVisitors pax)', '₹${_baseEntryTotal.toInt()}'),
              if (_passTypeUpgradeTotal > 0)
                _buildSummaryLine('Package Upgrade', '₹${_passTypeUpgradeTotal.toInt()}'),
              if (_addonsTotal > 0)
                _buildSummaryLine('Selected Add-ons', '₹${_addonsTotal.toInt()}'),
              if (_appliedDiscount > 0)
                _buildSummaryLine('Coupon Discount', '-₹${_appliedDiscount.toInt()}', isDiscount: true),
              if (_gst > 0)
                _buildSummaryLine('GST (5%)', '₹${_gst.toInt()}'),
              _buildSummaryLine('Platform Convenience Fee', 'Free (₹0)', isGreen: true),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Grand Total',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  Text(
                    _grandTotal == 0 ? 'Free Entry Pass' : '₹${_grandTotal.toInt()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: AppColors.emerald,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 9. Booking Submission Button
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: _grandTotal == 0
                ? 'Confirm Free Pass for ${dest.name}'
                : 'Pay ₹${_grandTotal.toInt()} & Generate Pass',
            icon: const Icon(Icons.confirmation_number_rounded, size: 18),
            variant: ButtonVariant.primary,
            height: 50,
            isLoading: _isSubmitting,
            onPressed: _handleBookPass,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDateChip(String label, DateTime date, int offset) {
    final isSelected = _selectedDateOffset == offset;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedDate = date;
          _selectedDateOffset = offset;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.emerald
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.emerald : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : null,
              ),
            ),
            Text(
              DateFormat('dd MMM').format(date),
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitorCounterRow({
    required String title,
    required String subtitle,
    required int count,
    required ValueChanged<int> onChanged,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded),
              iconSize: 22,
              color: AppColors.emerald,
              onPressed: () => onChanged(count - 1),
            ),
            Text(
              '$count',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              iconSize: 22,
              color: AppColors.emerald,
              onPressed: () => onChanged(count + 1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddonTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required bool isDark,
    required Color borderColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: CheckboxListTile(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.emerald,
          secondary: Icon(icon, color: AppColors.emerald, size: 22),
          title: Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
          controlAffinity: ListTileControlAffinity.trailing,
        ),
      ),
    );
  }

  Widget _buildSummaryLine(String label, String value, {bool isDiscount = false, bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDiscount ? AppColors.error : (isGreen ? AppColors.emerald : null),
            ),
          ),
        ],
      ),
    );
  }
}
