import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../data/models/coupon.dart';
import '../../../../data/models/tour_package.dart';
import '../../../../services/booking_service.dart';
import '../seat_picker_screen.dart';
import 'booking_stepper.dart';

class TravelerDetailsView extends StatefulWidget {
  final TourPackage tour;
  final int travelersCount;
  final PricingBreakdown pricing;
  final List<Coupon> availableCoupons;
  final Coupon? appliedCoupon;
  final String? selectedPickupPoint;
  final List<String> selectedSeats;
  final TextEditingController primaryNameController;
  final TextEditingController primaryEmailController;
  final TextEditingController primaryPhoneController;
  final List<TextEditingController> passengerNameControllers;
  final List<TextEditingController> passengerAgeControllers;
  final ValueChanged<String> onPickupChanged;
  final Function(List<String> seats, double extraPrice) onSeatsChanged;
  final Function(String couponCode) onApplyCoupon;
  final VoidCallback onRemoveCoupon;
  final ValueChanged<int> onTravelersCountChanged;
  final VoidCallback onBack;
  final VoidCallback onProceedToPayment;
  final bool isProcessing;

  const TravelerDetailsView({
    super.key,
    required this.tour,
    required this.travelersCount,
    required this.pricing,
    required this.availableCoupons,
    required this.appliedCoupon,
    required this.selectedPickupPoint,
    required this.selectedSeats,
    required this.primaryNameController,
    required this.primaryEmailController,
    required this.primaryPhoneController,
    required this.passengerNameControllers,
    required this.passengerAgeControllers,
    required this.onPickupChanged,
    required this.onSeatsChanged,
    required this.onApplyCoupon,
    required this.onRemoveCoupon,
    required this.onTravelersCountChanged,
    required this.onBack,
    required this.onProceedToPayment,
    this.isProcessing = false,
  });

  @override
  State<TravelerDetailsView> createState() => _TravelerDetailsViewState();
}

class _TravelerDetailsViewState extends State<TravelerDetailsView> {
  final TextEditingController _couponInputController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _couponInputController.dispose();
    super.dispose();
  }

  Future<void> _openSeatPicker() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => SeatPickerScreen(
          requiredSeatsCount: widget.travelersCount,
          initialSelectedSeats: widget.selectedSeats,
          onConfirmed: (seats, extraPrice) {
            widget.onSeatsChanged(seats, extraPrice);
          },
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onProceedToPayment();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: ResponsiveBuilder(
        mobile: _buildMobile(isDark, theme),
        tablet: _buildDesktop(isDark, theme),
        desktop: _buildDesktop(isDark, theme),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DESKTOP LAYOUT
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDesktop(bool isDark, ThemeData theme) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: widget.onBack,
                tooltip: 'Back to Customize & Add-ons',
              ),
              const SizedBox(width: 8),
              Text(
                'Complete Tour Booking',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stepper: Step 2 active
          const BookingStepper(currentStep: 2, isMobile: false),
          const SizedBox(height: 12),

          // Primary Contact Card
          _buildPrimaryContactCard(isDark, theme),
          const SizedBox(height: 20),

          // Additional Travelers Card
          _buildAdditionalTravelersCard(isDark, theme),
          const SizedBox(height: 20),

          // Boarding & Seat Selection
          _buildBoardingAndSeatCard(isDark, theme),
          const SizedBox(height: 20),

          // Promo Code / Coupon Section
          _buildCouponCard(isDark, theme),
          const SizedBox(height: 20),

          // Fare & Payment Summary
          _buildFareSummaryCard(isDark, theme, currencyFormatter),
          const SizedBox(height: 28),

          // Bottom Navigation Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Back', style: TextStyle(fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              CustomButton(
                text: 'Proceed to Pay by UPI QR (${currencyFormatter.format(widget.pricing.totalAmount)})',
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                isLoading: widget.isProcessing,
                variant: ButtonVariant.saffron,
                height: 50,
                onPressed: _handleSubmit,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MOBILE LAYOUT
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMobile(bool isDark, ThemeData theme) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: widget.onBack,
        ),
        title: const Text('Complete Booking', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 95),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Compact Stepper
                const BookingStepper(currentStep: 2, isMobile: true),
                const SizedBox(height: 12),

                // Primary Contact Form
                _buildPrimaryContactCard(isDark, theme),
                const SizedBox(height: 16),

                // Additional Travelers
                _buildAdditionalTravelersCard(isDark, theme),
                const SizedBox(height: 16),

                // Boarding & Seat
                _buildBoardingAndSeatCard(isDark, theme),
                const SizedBox(height: 16),

                // Coupon
                _buildCouponCard(isDark, theme),
                const SizedBox(height: 16),

                // Fare Summary
                _buildFareSummaryCard(isDark, theme, currencyFormatter),
              ],
            ),
          ),

          // Sticky Bottom Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: CustomButton(
                  text: 'Continue to Payment (${currencyFormatter.format(widget.pricing.totalAmount)})',
                  variant: ButtonVariant.saffron,
                  height: 48,
                  isFullWidth: true,
                  isLoading: widget.isProcessing,
                  onPressed: _handleSubmit,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 1. PRIMARY CONTACT FORM ────────────────────────────────────────────────
  Widget _buildPrimaryContactCard(bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Primary Contact & Travelers',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),

          // Full Name
          TextFormField(
            controller: widget.primaryNameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'e.g. Rahul Patil',
              prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
          ),
          const SizedBox(height: 14),

          // Email Address
          TextFormField(
            controller: widget.primaryEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address (for Ticket PDF)',
              hintText: 'e.g. rahul.patil@example.com',
              prefixIcon: const Icon(Icons.email_outlined, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter your email address';
              if (!v.contains('@') || !v.contains('.')) return 'Please enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Mobile Phone
          TextFormField(
            controller: widget.primaryPhoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Mobile Phone',
              hintText: '+91 98220 12345',
              prefixIcon: const Icon(Icons.phone_outlined, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your mobile phone' : null,
          ),
        ],
      ),
    );
  }

  // ── 2. ADDITIONAL TRAVELERS ────────────────────────────────────────────────
  Widget _buildAdditionalTravelersCard(bool isDark, ThemeData theme) {
    final additionalCount = widget.travelersCount - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Additional Travelers ($additionalCount)',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (widget.travelersCount < 10)
                TextButton.icon(
                  onPressed: () => widget.onTravelersCountChanged(widget.travelersCount + 1),
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 16, color: AppColors.emerald),
                  label: const Text(
                    '+ Add Traveler',
                    style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w700, fontSize: 12.5),
                  ),
                ),
            ],
          ),
          if (additionalCount > 0) const SizedBox(height: 12),

          for (int i = 1; i < widget.travelersCount; i++) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Traveler ${i + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                        tooltip: 'Remove Traveler',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => widget.onTravelersCountChanged(widget.travelersCount - 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 7,
                        child: TextFormField(
                          controller: i < widget.passengerNameControllers.length
                              ? widget.passengerNameControllers[i]
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            hintText: 'Passenger Name',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: i < widget.passengerAgeControllers.length
                              ? widget.passengerAgeControllers[i]
                              : null,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Age',
                            hintText: '25',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          if (widget.travelersCount < 10) ...[
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: () => widget.onTravelersCountChanged(widget.travelersCount + 1),
              icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.emerald),
              label: const Text('Add Another Traveler', style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                side: const BorderSide(color: AppColors.emerald, style: BorderStyle.solid),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── 3. BOARDING & SEAT SELECTION ───────────────────────────────────────────
  Widget _buildBoardingAndSeatCard(bool isDark, ThemeData theme) {
    final pickupPoints = widget.tour.pickupPoints.isNotEmpty
        ? widget.tour.pickupPoints
        : [
            'Swargate Bus Stand (5:30 AM)',
            'Deccan Gymkhana (5:50 AM)',
            'Pune Station (5:15 AM)',
            'Shivajinagar Bus Terminal (5:40 AM)',
          ];

    final effectivePickup = (widget.selectedPickupPoint != null && pickupPoints.contains(widget.selectedPickupPoint))
        ? widget.selectedPickupPoint!
        : pickupPoints.first;

    final seatDisplayText = widget.selectedSeats.isNotEmpty
        ? widget.selectedSeats.join(', ')
        : 'Tap to choose ${widget.travelersCount} seat(s) →';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Boarding & Seat Selection',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),

          // Boarding Terminal Dropdown
          const Text('Pune Boarding Terminal', style: TextStyle(fontSize: 12.5, color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: effectivePickup,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.emerald),
                items: pickupPoints
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 18, color: AppColors.emerald),
                              const SizedBox(width: 10),
                              Flexible(child: Text(p, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) widget.onPickupChanged(val);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Bus Seat Preference Card
          InkWell(
            onTap: _openSeatPicker,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8FAFC),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.airline_seat_recline_extra_rounded, color: AppColors.emerald, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bus Seat Preference', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(
                          seatDisplayText,
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.selectedSeats.isNotEmpty ? AppColors.emerald : Colors.grey,
                            fontWeight: widget.selectedSeats.isNotEmpty ? FontWeight.w800 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. COUPON CODE SECTION ─────────────────────────────────────────────────
  Widget _buildCouponCard(bool isDark, ThemeData theme) {
    final isApplied = widget.appliedCoupon != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Promo Code / Coupons',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (isApplied)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${widget.appliedCoupon!.code} Active',
                    style: const TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w800, fontSize: 11),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponInputController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: isApplied ? widget.appliedCoupon!.code : 'Enter promo code (e.g. PUNEPASS20)',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (isApplied)
                OutlinedButton(
                  onPressed: widget.onRemoveCoupon,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  child: const Text('Remove', style: TextStyle(fontWeight: FontWeight.w700)),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    final code = _couponInputController.text.trim();
                    if (code.isNotEmpty) widget.onApplyCoupon(code);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 5. FARE & PAYMENT SUMMARY ──────────────────────────────────────────────
  Widget _buildFareSummaryCard(bool isDark, ThemeData theme, NumberFormat currencyFormatter) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fare & Payment Summary',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          _buildSummaryRow('Base Tour Fare', currencyFormatter.format(widget.pricing.basePrice)),
          if (widget.pricing.customizationCost > 0)
            _buildSummaryRow('Add-ons & Upgrades', '+${currencyFormatter.format(widget.pricing.customizationCost)}'),
          if (widget.pricing.seatExtraPrice > 0)
            _buildSummaryRow('Window / Front Seat Selection', '+${currencyFormatter.format(widget.pricing.seatExtraPrice)}'),
          if (widget.pricing.discountAmount > 0)
            _buildSummaryRow('Coupon Discount', '-${currencyFormatter.format(widget.pricing.discountAmount)}', isGreen: true),
          _buildSummaryRow('GST (5%)', currencyFormatter.format(widget.pricing.gstAmount)),
          _buildSummaryRow('Platform Fee', currencyFormatter.format(widget.pricing.platformFee)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Payable', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              Text(
                currencyFormatter.format(widget.pricing.totalAmount),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.emerald),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: isGreen ? AppColors.emerald : null,
            ),
          ),
        ],
      ),
    );
  }
}
