import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/models/booking.dart';
import '../../../../data/models/itinerary_model.dart';

/// Interactive modal sheet to book a custom trip with private transport,
/// certified historian guide, fast-track permits, and authentic local meals.
void showCustomTripBookingModal(
  BuildContext context, {
  ItineraryPlan? plan,
  String? defaultTitle,
  int? defaultDays,
  String? defaultTheme,
  double? initialBudget,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => CustomTripBookingModal(
      plan: plan,
      defaultTitle: defaultTitle,
      defaultDays: defaultDays,
      defaultTheme: defaultTheme,
      initialBudget: initialBudget,
    ),
  );
}

class CustomTripBookingModal extends ConsumerStatefulWidget {
  final ItineraryPlan? plan;
  final String? defaultTitle;
  final int? defaultDays;
  final String? defaultTheme;
  final double? initialBudget;

  const CustomTripBookingModal({
    super.key,
    this.plan,
    this.defaultTitle,
    this.defaultDays,
    this.defaultTheme,
    this.initialBudget,
  });

  @override
  ConsumerState<CustomTripBookingModal> createState() => _CustomTripBookingModalState();
}

class _CustomTripBookingModalState extends ConsumerState<CustomTripBookingModal> {
  // Vehicle Fleet
  // 0: Sedan (₹2,200/d), 1: SUV (₹3,400/d), 2: Tempo (₹5,800/d)
  int _selectedVehicleIndex = 0;

  // Inclusions
  bool _includeGuide = true;
  bool _includePermits = true;
  bool _includeMeals = false;

  // Travel Logistics
  late DateTime _startDate;
  late int _durationDays;
  String _selectedPickupPoint = 'Swargate Bus Stand';

  // Travelers
  int _travelersCount = 2;

  // Contact Info
  final _nameController = TextEditingController(text: 'Rahul Patil');
  final _phoneController = TextEditingController(text: '+91 98220 12345');
  final _emailController = TextEditingController(text: 'rahul.patil@example.com');

  // Coupon
  final _couponController = TextEditingController();
  bool _isCouponApplied = false;
  String? _couponMessage;

  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _vehicles = [
    {
      'name': 'Private AC Sedan',
      'model': 'Dzire / Etios',
      'icon': '🚗',
      'rate': 2200.0,
      'capacity': '1-4 Pax',
      'maxPax': 4,
    },
    {
      'name': 'Sahyadri SUV',
      'model': 'Innova / Ertiga',
      'icon': '🚙',
      'rate': 3400.0,
      'capacity': '4-7 Pax',
      'maxPax': 7,
    },
    {
      'name': 'Tempo Traveller',
      'model': 'Force Urbania 12S',
      'icon': '🚐',
      'rate': 5800.0,
      'capacity': '8-15 Pax',
      'maxPax': 15,
    },
  ];

  final List<String> _pickupLocations = [
    'Swargate Bus Stand',
    'Pune Railway Station (PF 1)',
    'Pune Airport (Lohegaon)',
    'Hinjawadi IT Park / Wakad',
    'Kothrud / Deccan Gymkhana',
    'Custom Doorstep (Home / Hotel)',
  ];

  @override
  void initState() {
    super.initState();
    _durationDays = widget.plan?.totalDays ?? widget.defaultDays ?? 2;
    if (_durationDays < 1) _durationDays = 1;

    final parsedStart = DateTime.tryParse(widget.plan?.startDate ?? '');
    _startDate = parsedStart ?? DateTime.now().add(const Duration(days: 2));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() {
      if (code == 'PUNEPASS20' || code == 'PUNEEXPLORER' || code == 'PUNE20') {
        _isCouponApplied = true;
        _couponMessage = '20% PunePass Explorer discount applied! 🎉';
      } else if (code == 'MONSOON10') {
        _isCouponApplied = true;
        _couponMessage = '10% Monsoon Ghats discount applied! 🌧️';
      } else {
        _isCouponApplied = false;
        _couponMessage = 'Invalid code. Try "PUNEPASS20" for 20% off.';
      }
    });
  }

  double get _vehicleTotal => (_vehicles[_selectedVehicleIndex]['rate'] as double) * _durationDays;
  double get _guideTotal => _includeGuide ? (1200.0 * _durationDays) : 0.0;
  double get _permitsTotal => _includePermits ? (250.0 * _travelersCount) : 0.0;
  double get _mealsTotal => _includeMeals ? (350.0 * _travelersCount * _durationDays) : 0.0;

  double get _subtotal => _vehicleTotal + _guideTotal + _permitsTotal + _mealsTotal;
  double get _discount => _isCouponApplied ? (_subtotal * 0.20) : 0.0;
  double get _net => max(0.0, _subtotal - _discount);
  double get _gst => _net * 0.05;
  double get _platformFee => 99.0;
  double get _grandTotal => _net + _gst + _platformFee;

  Future<void> _handleConfirmBooking() async {
    if (_isSubmitting) return;

    final customerName = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Explorer';
    final customerPhone = _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : '+91 98220 12345';
    final customerEmail = _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : 'explorer@pune.com';

    setState(() => _isSubmitting = true);
    HapticFeedback.heavyImpact();

    final tripTitle = widget.plan?.title ?? widget.defaultTitle ?? 'Pune Explorer Custom Tour';
    final vehicle = _vehicles[_selectedVehicleIndex];
    final bookingId = 'PUNE-CUSTOM-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    final passengers = List.generate(
      _travelersCount,
      (i) => Passenger(
        fullName: i == 0 ? customerName : 'Traveler ${i + 1}',
        age: 28,
        gender: 'Not Specified',
        seatNumber: '${vehicle['name']} (${i + 1}/$_travelersCount)',
      ),
    );

    final booking = Booking(
      id: bookingId,
      tourId: widget.plan?.id ?? 'custom_trip_${DateTime.now().millisecondsSinceEpoch}',
      tourTitle: 'Custom Trip: $tripTitle',
      travelDate: '${DateFormat('MMM dd, yyyy').format(_startDate)} ($_durationDays Days)',
      pickupPoint: '$_selectedPickupPoint (08:30 AM)',
      passengers: passengers,
      selectedSeats: [vehicle['name'] as String],
      basePrice: _vehicleTotal,
      seatExtraPrice: _guideTotal + _permitsTotal + _mealsTotal,
      discountAmount: _discount,
      appliedCoupon: _isCouponApplied ? _couponController.text.trim().toUpperCase() : null,
      gstAmount: _gst,
      platformFee: _platformFee,
      totalAmount: _grandTotal,
      status: BookingStatus.pendingPayment,
      createdAt: DateTime.now().toIso8601String(),
      paymentId: 'pay_UPI_PUNE_${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      verificationHash: 'PUNEPASS-${bookingId.replaceAll('-', '')}',
    );

    // Create server-authoritative payment order
    final order = await ref.read(paymentOrdersProvider.notifier).createOrder(
      bookingId: booking.id,
      userId: customerEmail,
      packageId: booking.tourId,
      packageName: booking.tourTitle,
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
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🎉', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Custom Trip Reserved Successfully!', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Order ID: ${order.orderId} • Complete Payment via UPI QR', style: const TextStyle(fontSize: 11)),
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

      context.push('/payment/qr/${order.orderId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    final tripTitle = widget.plan?.title ?? widget.defaultTitle ?? 'Pune Custom Circuit';

    return DraggableScrollableSheet(
      initialChildSize: 0.90,
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
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Sticky Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: borderColor, width: 0.8)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF064E3B), Color(0xFF047857)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Text('🚗', style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  tripTitle,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF064E3B).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$_durationDays Days',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFF064E3B),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Book Private Cab, Guide & Permits',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),

              // Scrollable Configuration Form
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    // ── 1. Vehicle Fleet Selection ──
                    _buildSectionHeader('1. Select Private Vehicle Fleet', '🚗', isDark),
                    const SizedBox(height: 10),
                    Column(
                      children: List.generate(_vehicles.length, (index) {
                        final v = _vehicles[index];
                        final isSelected = _selectedVehicleIndex == index;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedVehicleIndex = index);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFECFDF5))
                                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC)),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF059669) : borderColor,
                                  width: isSelected ? 1.6 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(v['icon'] as String, style: const TextStyle(fontSize: 26)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          v['name'] as String,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13.5,
                                            color: isSelected ? const Color(0xFF064E3B) : null,
                                          ),
                                        ),
                                        Text(
                                          '${v['model']} • ${v['capacity']}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₹${(v['rate'] as double).toInt()}/d',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: const Color(0xFF064E3B),
                                        ),
                                      ),
                                      Text(
                                        'All fuel & tolls incl.',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9.5,
                                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                    color: isSelected ? const Color(0xFF059669) : Colors.grey,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    // ── 2. Curated Inclusions & Upgrades ──
                    _buildSectionHeader('2. Tour Enhancements & Inclusions', '✨', isDark),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          _buildSwitchRow(
                            title: 'Certified Pune Historian / Trek Guide',
                            subtitle: 'Storyteller guide fluent in Marathi & English (+₹1,200/day)',
                            icon: '🧭',
                            value: _includeGuide,
                            onChanged: (val) => setState(() => _includeGuide = val),
                            isDark: isDark,
                          ),
                          Divider(height: 1, color: borderColor),
                          _buildSwitchRow(
                            title: 'Fast-Track Fort & Museum Permits',
                            subtitle: 'Skip the queues at Shaniwar Wada, Kelkar Museum (+₹250/pax)',
                            icon: '🎟️',
                            value: _includePermits,
                            onChanged: (val) => setState(() => _includePermits = val),
                            isDark: isDark,
                          ),
                          Divider(height: 1, color: borderColor),
                          _buildSwitchRow(
                            title: 'Authentic Maharashtrian Meal Plan',
                            subtitle: 'Fresh Misal breakfast & Special Peth Thali lunch (+₹350/pax/day)',
                            icon: '🍲',
                            value: _includeMeals,
                            onChanged: (val) => setState(() => _includeMeals = val),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── 3. Date, Pickup & Travelers ──
                    _buildSectionHeader('3. Dates, Logistics & Travelers', '📍', isDark),
                    const SizedBox(height: 8),

                    // Date & Duration Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          // Date Picker Row
                          Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded, size: 20, color: Color(0xFF064E3B)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Departure Date',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                      ),
                                    ),
                                    Text(
                                      DateFormat('EEE, MMM dd, yyyy').format(_startDate),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _startDate,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(const Duration(days: 180)),
                                  );
                                  if (picked != null) setState(() => _startDate = picked);
                                },
                                child: const Text('Change Date'),
                              ),
                            ],
                          ),
                          const Divider(height: 16),

                          // Pickup Point Dropdown
                          Row(
                            children: [
                              const Icon(Icons.my_location_rounded, size: 20, color: Color(0xFFEA580C)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedPickupPoint,
                                    isExpanded: true,
                                    dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                    items: _pickupLocations.map((loc) {
                                      return DropdownMenuItem(value: loc, child: Text(loc));
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedPickupPoint = val);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),

                          // Traveler Counter Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Number of Travelers',
                                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                  Text(
                                    'Includes children and seniors',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline_rounded),
                                    onPressed: _travelersCount > 1
                                        ? () => setState(() => _travelersCount--)
                                        : null,
                                    color: const Color(0xFF064E3B),
                                  ),
                                  Text(
                                    '$_travelersCount',
                                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline_rounded),
                                    onPressed: _travelersCount < 15
                                        ? () => setState(() => _travelersCount++)
                                        : null,
                                    color: const Color(0xFF064E3B),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── 4. Traveler Contact Details ──
                    _buildSectionHeader('4. Contact & Pickup Details', '👤', isDark),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Lead Traveler Full Name',
                              prefixIcon: Icon(Icons.person_outline_rounded, size: 18),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'Mobile Number',
                                    prefixIcon: Icon(Icons.phone_outlined, size: 18),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Email Address',
                                    prefixIcon: Icon(Icons.mail_outline_rounded, size: 18),
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── 5. Promo Code ──
                    _buildSectionHeader('5. Apply Promo Code', '🏷️', isDark),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _couponController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: 'Try "PUNEPASS20"',
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _applyCoupon,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF064E3B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                    if (_couponMessage != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _couponMessage!,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: _isCouponApplied ? const Color(0xFF059669) : Colors.red,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // ── 6. Transparent Price Breakdown ──
                    _buildSectionHeader('6. Guaranteed Price Summary', '🧾', isDark),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          _buildPriceLine('Private Vehicle (${_vehicles[_selectedVehicleIndex]['name']})', '₹${_vehicleTotal.toInt()}', isDark),
                          if (_includeGuide)
                            _buildPriceLine('Certified Historian Guide ($_durationDays Days)', '₹${_guideTotal.toInt()}', isDark),
                          if (_includePermits)
                            _buildPriceLine('Fort & Museum Passes ($_travelersCount Travelers)', '₹${_permitsTotal.toInt()}', isDark),
                          if (_includeMeals)
                            _buildPriceLine('Maharashtrian Meals ($_travelersCount Travelers, $_durationDays Days)', '₹${_mealsTotal.toInt()}', isDark),
                          if (_isCouponApplied)
                            _buildPriceLine('Promo Code Discount', '-₹${_discount.toInt()}', isDark, isDiscount: true),
                          _buildPriceLine('GST (5% Tourism Cess)', '₹${_gst.toInt()}', isDark),
                          _buildPriceLine('Platform Booking Fee', '₹${_platformFee.toInt()}', isDark),
                          const Divider(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Total Amount Payable:',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '₹${_grandTotal.toInt()}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: const Color(0xFF064E3B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Guarantee Callout
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF064E3B).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Text('🛡️', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Free cancellation up to 24 hrs prior to departure. Instant digital booking pass with QR code.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF064E3B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Bottom Sticky Confirmation CTA
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: Border(top: BorderSide(color: borderColor)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -3)),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Grand Total',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            '₹${_grandTotal.toInt()}',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: const Color(0xFF064E3B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _handleConfirmBooking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEA580C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Confirm & Reserve Trip', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                                      SizedBox(width: 6),
                                      Icon(Icons.arrow_forward_rounded, size: 16),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, String emoji, bool isDark) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required String icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: const Color(0xFF064E3B),
            onChanged: (val) {
              HapticFeedback.lightImpact();
              onChanged(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceLine(String label, String value, bool isDark, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: isDiscount ? const Color(0xFF059669) : null,
            ),
          ),
        ],
      ),
    );
  }
}
