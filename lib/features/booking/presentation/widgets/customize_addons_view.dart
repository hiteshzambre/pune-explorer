import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/utils/booking_cutoff_validator.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../data/models/tour_customization.dart';
import '../../../../data/models/tour_package.dart';
import 'booking_stepper.dart';

class CustomizeAddonsView extends StatefulWidget {
  final TourPackage tour;
  final DateTime selectedDate;
  final int travelersCount;
  final TourCustomization customization;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<int> onTravelersChanged;
  final ValueChanged<TourCustomization> onCustomizationChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const CustomizeAddonsView({
    super.key,
    required this.tour,
    required this.selectedDate,
    required this.travelersCount,
    required this.customization,
    required this.onDateChanged,
    required this.onTravelersChanged,
    required this.onCustomizationChanged,
    required this.onBack,
    required this.onContinue,
  });

  @override
  State<CustomizeAddonsView> createState() => _CustomizeAddonsViewState();
}

class _CustomizeAddonsViewState extends State<CustomizeAddonsView> {
  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final earliest = BookingCutoffValidator.getEarliestSelectableDate(widget.tour, currentTime: now);
    final effectiveInitial = (!BookingCutoffValidator.isDateSelectable(widget.selectedDate, widget.tour, currentTime: now))
        ? earliest
        : widget.selectedDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: effectiveInitial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
      selectableDayPredicate: (date) => BookingCutoffValidator.isDateSelectable(date, widget.tour, currentTime: now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.emerald,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      widget.onDateChanged(picked);
    }
  }

  void _handleContinue() {
    final validationError = BookingCutoffValidator.validateBookingDate(date: widget.selectedDate, tour: widget.tour);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.red.shade800,
        ),
      );
      return;
    }
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ResponsiveBuilder(
      mobile: _buildMobile(isDark, theme),
      tablet: _buildDesktop(isDark, theme),
      desktop: _buildDesktop(isDark, theme),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DESKTOP LAYOUT
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDesktop(bool isDark, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Back Button
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: widget.onBack,
                tooltip: 'Back to Tour Details',
              ),
              const SizedBox(width: 8),
              Text(
                'Complete Tour Booking',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stepper: Step 1 active
          const BookingStepper(currentStep: 1, isMobile: false),
          const SizedBox(height: 12),

          // Selected Tour Compact Card
          _buildTourSummaryCard(isDark, theme),
          const SizedBox(height: 20),

          // Travel Date & Travelers Selector Card
          _buildDateAndTravelersCard(isDark, theme),
          const SizedBox(height: 24),

          // Tour Customizer & Add-ons
          _buildAddonsSection(isDark, theme),
          const SizedBox(height: 32),

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
                text: 'Continue to Traveler Details →',
                variant: ButtonVariant.saffron,
                height: 48,
                onPressed: _handleContinue,
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Compact Stepper
                const BookingStepper(currentStep: 1, isMobile: true),
                const SizedBox(height: 12),

                // Tour Mini Card
                _buildTourSummaryCard(isDark, theme),
                const SizedBox(height: 16),

                // Date & Travelers
                _buildDateAndTravelersCard(isDark, theme),
                const SizedBox(height: 20),

                // Add-ons
                _buildAddonsSection(isDark, theme),
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
                  text: 'Continue →',
                  variant: ButtonVariant.saffron,
                  height: 48,
                  isFullWidth: true,
                  onPressed: _handleContinue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 1. SELECTED TOUR COMPACT CARD ──────────────────────────────────────────
  Widget _buildTourSummaryCard(bool isDark, ThemeData theme) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 70,
              height: 70,
              child: AppCardImage(
                imageUrl: widget.tour.primaryImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.tour.title,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${currencyFormatter.format(widget.tour.price)} per traveler • ${widget.tour.duration}',
                  style: const TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w700, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. DATE & TRAVELERS CARD ───────────────────────────────────────────────
  Widget _buildDateAndTravelersCard(bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Travel Date & Travelers',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),

          // Date Selector
          InkWell(
            onTap: () => _pickDate(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8FAFC),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: AppColors.emerald, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            DateFormat('EEE, dd MMM yyyy').format(widget.selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.edit_calendar_rounded, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Number of Travelers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Number of Travelers', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                    const SizedBox(height: 2),
                    Text('Max 10 per booking', style: TextStyle(fontSize: 11.5, color: isDark ? Colors.white54 : Colors.black45)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      color: widget.travelersCount > 1 ? AppColors.emerald : Colors.grey,
                      onPressed: widget.travelersCount > 1 ? () => widget.onTravelersChanged(widget.travelersCount - 1) : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '${widget.travelersCount}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      color: widget.travelersCount < 10 ? AppColors.emerald : Colors.grey,
                      onPressed: widget.travelersCount < 10 ? () => widget.onTravelersChanged(widget.travelersCount + 1) : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 3. TOUR CUSTOMIZER & ADD-ONS ───────────────────────────────────────────
  Widget _buildAddonsSection(bool isDark, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('⚡', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tour Customizer & Add-ons',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Upgrade your experience and make it memorable!',
          style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
        ),
        const SizedBox(height: 16),

        // Category 1: Transport Upgrade
        _buildCategoryTitle('🚗 Transport Upgrade', theme),
        const SizedBox(height: 10),
        _buildAddonOptionCard(
          title: 'AC Volvo Coach',
          subtitle: 'Included in standard tour package',
          price: 0,
          badgeText: 'Included',
          icon: Icons.directions_bus_rounded,
          isSelected: widget.customization.transportCostPerPerson == 0,
          isDark: isDark,
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onCustomizationChanged(widget.customization.copyWith(
              transportMode: 'AC Volvo Coach',
              transportCostPerPerson: 0,
            ));
          },
        ),
        const SizedBox(height: 8),
        _buildAddonOptionCard(
          title: 'Innova Crysta SUV',
          subtitle: 'Spacious 6-seater private luxury ride',
          price: 600,
          badgeText: '+₹600',
          icon: Icons.airport_shuttle_rounded,
          isSelected: widget.customization.transportCostPerPerson == 600,
          isDark: isDark,
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onCustomizationChanged(widget.customization.copyWith(
              transportMode: 'Innova Crysta SUV',
              transportCostPerPerson: 600,
            ));
          },
        ),
        const SizedBox(height: 8),
        _buildAddonOptionCard(
          title: 'Chauffeur-Driven Private Sedan',
          subtitle: 'Dedicated AC sedan for your party',
          price: 1000,
          badgeText: '+₹1,000',
          icon: Icons.directions_car_rounded,
          isSelected: widget.customization.transportCostPerPerson == 1000,
          isDark: isDark,
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onCustomizationChanged(widget.customization.copyWith(
              transportMode: 'Chauffeur-Driven Private Sedan',
              transportCostPerPerson: 1000,
            ));
          },
        ),
        const SizedBox(height: 20),

        // Category 2: Authentic Puneri Dining
        _buildCategoryTitle('🍛 Authentic Puneri Dining', theme),
        const SizedBox(height: 10),
        _buildAddonOptionCard(
          title: 'Standard Maharashtrian Lunch',
          subtitle: 'Fresh Bhakri, Pithla, Thecha & Rice',
          price: 0,
          badgeText: 'Included',
          icon: Icons.restaurant_rounded,
          isSelected: widget.customization.mealCostPerPerson == 0,
          isDark: isDark,
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onCustomizationChanged(widget.customization.copyWith(
              mealOption: 'Standard Maharashtrian Lunch',
              mealCostPerPerson: 0,
            ));
          },
        ),
        const SizedBox(height: 8),
        _buildAddonOptionCard(
          title: 'Royal Puneri Thali + Sujata Mastani',
          subtitle: 'Premium heritage thali & dessert',
          price: 350,
          badgeText: '+₹350',
          icon: Icons.soup_kitchen_rounded,
          isSelected: widget.customization.mealCostPerPerson == 350,
          isDark: isDark,
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onCustomizationChanged(widget.customization.copyWith(
              mealOption: 'Royal Puneri Thali + Sujata Mastani',
              mealCostPerPerson: 350,
            ));
          },
        ),
        const SizedBox(height: 20),

        // Category 3: Stay / Overnight Tier
        _buildCategoryTitle('🏨 Stay / Overnight Tier', theme),
        const SizedBox(height: 10),
        _buildAddonOptionCard(
          title: 'Day Trip',
          subtitle: 'Return to Pune on the same evening',
          price: 0,
          badgeText: 'Included',
          icon: Icons.wb_sunny_outlined,
          isSelected: widget.customization.accommodationCostPerPerson == 0,
          isDark: isDark,
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onCustomizationChanged(widget.customization.copyWith(
              accommodationTier: 'Day Trip',
              accommodationCostPerPerson: 0,
            ));
          },
        ),
        const SizedBox(height: 8),
        _buildAddonOptionCard(
          title: 'Heritage Homestay / Comfort Lodge',
          subtitle: 'Private room with mountain view & breakfast',
          price: 1100,
          badgeText: '+₹1,100',
          icon: Icons.cottage_rounded,
          isSelected: widget.customization.accommodationCostPerPerson == 1100,
          isDark: isDark,
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onCustomizationChanged(widget.customization.copyWith(
              accommodationTier: 'Heritage Homestay / Comfort Lodge',
              accommodationCostPerPerson: 1100,
            ));
          },
        ),
        const SizedBox(height: 8),
        _buildAddonOptionCard(
          title: 'Lakeside Dome Glamping + Campfire',
          subtitle: 'Luxury waterfront tent at Pawna with BBQ',
          price: 1800,
          badgeText: '+₹1,800',
          icon: Icons.holiday_village_rounded,
          isSelected: widget.customization.accommodationCostPerPerson == 1800,
          isDark: isDark,
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onCustomizationChanged(widget.customization.copyWith(
              accommodationTier: 'Lakeside Dome Glamping + Campfire',
              accommodationCostPerPerson: 1800,
            ));
          },
        ),
      ],
    );
  }

  Widget _buildCategoryTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
    );
  }

  Widget _buildAddonOptionCard({
    required String title,
    required String subtitle,
    required double price,
    required String badgeText,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final bgColor = isSelected
        ? (isDark ? const Color(0xFF132E24) : const Color(0xFFF0FDF4))
        : (isDark ? AppColors.darkSurface : Colors.white);
    final borderColor = isSelected
        ? AppColors.emerald
        : (isDark ? AppColors.darkBorder : AppColors.lightBorder);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.emerald.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Radio Indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.emerald : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? AppColors.emerald : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.circle, size: 8, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 14),

            // Icon Avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.emerald.withValues(alpha: 0.15)
                    : (isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: isSelected ? AppColors.emerald : Colors.grey),
            ),
            const SizedBox(width: 12),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 13.5,
                      color: isSelected ? AppColors.emerald : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Badge Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: price == 0
                    ? AppColors.emerald.withValues(alpha: 0.12)
                    : AppColors.saffron.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  color: price == 0 ? AppColors.emerald : AppColors.saffron,
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
