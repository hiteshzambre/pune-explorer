import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/responsive/responsive_builder.dart';

class BudgetCalculatorScreen extends StatefulWidget {
  const BudgetCalculatorScreen({super.key});

  @override
  State<BudgetCalculatorScreen> createState() => _BudgetCalculatorScreenState();
}

class _BudgetCalculatorScreenState extends State<BudgetCalculatorScreen> {
  int _travelers = 2;
  int _days = 2;
  String _selectedTripType = 'Leisure';
  String _activePreset = '';

  // Transport options
  int _transportCostPerDayPerPerson = 400; // Shared Cab / Bus
  String _transportModeName = 'Shared Cab / Bus (₹400/day)';

  // Stay options
  int _stayCostPerNightPerPerson = 1100; // Comfort Hotel
  String _stayTypeName = 'Comfort Hotel / Homestay (₹1,100/night)';

  // Food options
  int _foodCostPerDayPerPerson = 500; // Mid-range
  String _foodTypeName = 'Authentic Thali & Cafes (₹500/day)';

  // Activity options
  int _activityCostPerDayPerPerson = 300; // Fort entries + guide
  String _activityTypeName = 'Fort Treks & Sightseeing (₹300/day)';

  void _applyPreset(String name) {
    setState(() {
      _activePreset = name;
      if (name == 'student') {
        _travelers = 3;
        _days = 1;
        _selectedTripType = 'Solo';
        _transportCostPerDayPerPerson = 120;
        _transportModeName = 'Local Train / PMPML Bus (₹120/day)';
        _stayCostPerNightPerPerson = 0;
        _stayTypeName = 'No Stay (Day Trip)';
        _foodCostPerDayPerPerson = 250;
        _foodTypeName = 'Street Food & Misal (₹250/day)';
        _activityCostPerDayPerPerson = 100;
        _activityTypeName = 'Fort Entry & Snack (₹100/day)';
      } else if (name == 'family') {
        _travelers = 4;
        _days = 2;
        _selectedTripType = 'Family';
        _transportCostPerDayPerPerson = 600;
        _transportModeName = 'Private AC Cab (₹600/day)';
        _stayCostPerNightPerPerson = 1400;
        _stayTypeName = 'Family Resort / Hotel (₹1,400/night)';
        _foodCostPerDayPerPerson = 650;
        _foodTypeName = 'Maharashtrian Thali & Dining (₹650/day)';
        _activityCostPerDayPerPerson = 500;
        _activityTypeName = 'Pune Darshan Bus & VIP Passes (₹500/day)';
      } else if (name == 'glamping') {
        _travelers = 2;
        _days = 2;
        _selectedTripType = 'Leisure';
        _transportCostPerDayPerPerson = 500;
        _transportModeName = 'Drive / Cab to Pawna (₹500/day)';
        _stayCostPerNightPerPerson = 1800;
        _stayTypeName = 'Waterfront Dome Glamping (₹1,800/night)';
        _foodCostPerDayPerPerson = 400;
        _foodTypeName = 'Campfire BBQ & Buffet (₹400/day)';
        _activityCostPerDayPerPerson = 600;
        _activityTypeName = 'Kayaking & Watersports (₹600/day)';
      }
    });
  }

  void _resetToDefaults() {
    setState(() {
      _travelers = 2;
      _days = 2;
      _selectedTripType = 'Leisure';
      _activePreset = '';
      _transportCostPerDayPerPerson = 400;
      _transportModeName = 'Shared Cab / Bus (₹400/day)';
      _stayCostPerNightPerPerson = 1100;
      _stayTypeName = 'Comfort Hotel / Homestay (₹1,100/night)';
      _foodCostPerDayPerPerson = 500;
      _foodTypeName = 'Authentic Thali & Cafes (₹500/day)';
      _activityCostPerDayPerPerson = 300;
      _activityTypeName = 'Fort Treks & Sightseeing (₹300/day)';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reset to default 2-day Pune trip configuration.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  static final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  String _formatRupees(int amount) => _currencyFormat.format(amount);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final totalTransport = _transportCostPerDayPerPerson * _days * _travelers;
    final totalStay = _stayCostPerNightPerPerson * (_days > 1 ? _days - 1 : 0) * _travelers;
    final totalFood = _foodCostPerDayPerPerson * _days * _travelers;
    final totalActivities = _activityCostPerDayPerPerson * _days * _travelers;
    final grandTotal = totalTransport + totalStay + totalFood + totalActivities;
    final perPersonCost = _travelers > 0 ? (grandTotal / _travelers).round() : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Planner'),
        elevation: 0,
      ),
      body: MaxWidthWrapper(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Row with Hero Artwork
              _buildHeaderSection(isDark),
              const SizedBox(height: 18),

              // Emerald Budget Hero Card
              _buildEmeraldHeroCard(
                isDark: isDark,
                grandTotal: grandTotal,
                perPersonCost: perPersonCost,
                totalTransport: totalTransport,
                totalStay: totalStay,
                totalFood: totalFood,
                totalActivities: totalActivities,
              ),
              const SizedBox(height: 24),

              // Responsive Body: Two columns on wide desktop (>= 1050), stacked on mobile/tablet
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 1050;

                  if (isDesktop) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column (Controls & 4-Column Grid)
                        Expanded(
                          flex: 68,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPresetsSection(theme, isDark),
                              const SizedBox(height: 22),
                              _buildTripDetailsCard(isDark),
                              const SizedBox(height: 22),
                              _buildCustomizationGrid(isDark, constraints.maxWidth * 0.68),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Right Column (Sidebar Summary, Tips & CTA)
                        Expanded(
                          flex: 32,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSummaryCard(
                                isDark: isDark,
                                grandTotal: grandTotal,
                                perPersonCost: perPersonCost,
                                totalTransport: totalTransport,
                                totalStay: totalStay,
                                totalFood: totalFood,
                                totalActivities: totalActivities,
                              ),
                              const SizedBox(height: 20),
                              _buildTipsCard(isDark),
                              const SizedBox(height: 20),
                              _buildTravelSmartBanner(isDark),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  // Mobile & Tablet Single-Column Flow
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPresetsSection(theme, isDark),
                      const SizedBox(height: 20),
                      _buildTripDetailsCard(isDark),
                      const SizedBox(height: 20),
                      _buildCustomizationGrid(isDark, constraints.maxWidth),
                      const SizedBox(height: 24),
                      _buildSummaryCard(
                        isDark: isDark,
                        grandTotal: grandTotal,
                        perPersonCost: perPersonCost,
                        totalTransport: totalTransport,
                        totalStay: totalStay,
                        totalFood: totalFood,
                        totalActivities: totalActivities,
                      ),
                      const SizedBox(height: 20),
                      _buildTipsCard(isDark),
                      const SizedBox(height: 20),
                      _buildTravelSmartBanner(isDark),
                    ],
                  );
                },
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER SECTION & HERO ARTWORK
  // ---------------------------------------------------------------------------
  Widget _buildHeaderSection(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showRightHero = constraints.maxWidth >= 840;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Home',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 15,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Budget Planner',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.emeraldLight : AppColors.emerald,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pune Travel Budget Planner',
                    style: TextStyle(
                      fontSize: constraints.maxWidth < 400 ? 22 : 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Plan your perfect Pune trip with live estimated costs for transport, stay, dining and Sahyadri activities.',
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Informational Trust Badges (Containers, NOT ActionChips)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTrustBadge('✓ Smart Estimates', AppColors.emerald, isDark),
                      _buildTrustBadge('🏛️ Local Insights', AppColors.saffron, isDark),
                      _buildTrustBadge('⚙️ Custom Styles', AppColors.skyBlue, isDark),
                      _buildTrustBadge('🆓 Free & Unlimited', AppColors.amber, isDark),
                    ],
                  ),
                ],
              ),
            ),
            if (showRightHero) ...[
              const SizedBox(width: 24),
              Container(
                width: 280,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/budget_hero_fort_hd.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF064E3B), Color(0xFF047857)],
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.terrain_rounded, color: Colors.white60, size: 40),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.black.withValues(alpha: 0.75),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on, size: 12, color: AppColors.saffron),
                              SizedBox(width: 4),
                              Text(
                                'Sinhagad Fort',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: 12,
                        left: 14,
                        right: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explore More • Spend Smarter',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Authentic Sahyadri Getaways',
                              style: TextStyle(
                                color: Color(0xFFD1FAE5),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTrustBadge(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.4 : 0.25),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: isDark ? color.withValues(alpha: 0.95) : color,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EMERALD BUDGET HERO CARD
  // ---------------------------------------------------------------------------
  Widget _buildEmeraldHeroCard({
    required bool isDark,
    required int grandTotal,
    required int perPersonCost,
    required int totalTransport,
    required int totalStay,
    required int totalFood,
    required int totalActivities,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF064E3B), const Color(0xFF0F172A)]
              : [const Color(0xFF064E3B), const Color(0xFF047857)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064E3B).withValues(alpha: isDark ? 0.5 : 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 620;

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroMainNumbers(grandTotal, perPersonCost),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 14),
                // 2x2 Category Breakdown Pills
                Row(
                  children: [
                    Expanded(child: _buildHeroTotalPill('🚗 Transport', _formatRupees(totalTransport))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildHeroTotalPill('🏨 Stay', _formatRupees(totalStay))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildHeroTotalPill('🍲 Food', _formatRupees(totalFood))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildHeroTotalPill('🎟️ Activities', _formatRupees(totalActivities))),
                  ],
                ),
              ],
            );
          }

          // Wide / Desktop Hero Layout
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildHeroMainNumbers(grandTotal, perPersonCost)),
                  const SizedBox(width: 20),
                  // Per Traveler Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Per Traveler',
                          style: TextStyle(
                            color: Color(0xFFD1FAE5),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatRupees(perPersonCost),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 14),
              // 4 Category Breakdown Pills in a single row
              Row(
                children: [
                  Expanded(child: _buildHeroTotalPill('🚗 Transport', _formatRupees(totalTransport))),
                  const SizedBox(width: 10),
                  Expanded(child: _buildHeroTotalPill('🏨 Stay', _formatRupees(totalStay))),
                  const SizedBox(width: 10),
                  Expanded(child: _buildHeroTotalPill('🍲 Food', _formatRupees(totalFood))),
                  const SizedBox(width: 10),
                  Expanded(child: _buildHeroTotalPill('🎟️ Activities', _formatRupees(totalActivities))),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroMainNumbers(int grandTotal, int perPersonCost) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFA7F3D0), size: 16),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Estimated Total Budget',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFFD1FAE5),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'for $_travelers travelers • $_days days',
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _formatRupees(grandTotal),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '"Great trips aren\'t expensive, they are well planned."',
          style: TextStyle(
            color: Color(0xFFE2E8F0),
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroTotalPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 11.5),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1-CLICK BUDGET PRESETS (Must contain exactly 3 ActionChip widgets for test)
  // ---------------------------------------------------------------------------
  Widget _buildPresetsSection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '1-Click Budget Presets',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Popular Itineraries',
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.emerald,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Instant curated presets calibrated for popular Pune travel styles.',
          style: TextStyle(
            fontSize: 12.5,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPresetActionChip(
                keyName: 'student',
                avatarEmoji: '🎒',
                label: 'Student Trekker (₹470/day)',
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _buildPresetActionChip(
                keyName: 'family',
                avatarEmoji: '👨‍👩‍👧',
                label: 'Family Pune Darshan (₹2,500/day)',
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _buildPresetActionChip(
                keyName: 'glamping',
                avatarEmoji: '🏕️',
                label: 'Pawna Lake Glamping (₹3,300/day)',
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresetActionChip({
    required String keyName,
    required String avatarEmoji,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _activePreset == keyName;

    return Semantics(
      label: '$label budget preset',
      selected: isSelected,
      button: true,
      child: ActionChip(
        avatar: Text(avatarEmoji, style: const TextStyle(fontSize: 15)),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? (isDark ? Colors.white : AppColors.emeraldDark)
                : (isDark ? Colors.white70 : const Color(0xFF334155)),
          ),
        ),
        backgroundColor: isSelected
            ? AppColors.emerald.withValues(alpha: isDark ? 0.35 : 0.15)
            : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
        side: BorderSide(
          color: isSelected
              ? AppColors.emerald
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isSelected ? 1.5 : 1.0,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        onPressed: () => _applyPreset(keyName),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TRIP DETAILS (STEPPERS & SEGMENTED TRIP TYPE)
  // ---------------------------------------------------------------------------
  Widget _buildTripDetailsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, size: 18, color: AppColors.emerald),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Trip Details',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
              TextButton.icon(
                onPressed: _resetToDefaults,
                icon: const Icon(Icons.refresh_rounded, size: 14, color: AppColors.emerald),
                label: const Text(
                  'Reset',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.emerald),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Steppers Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 520;

              if (isCompact) {
                return Column(
                  children: [
                    _buildStepperRow(
                      label: 'Travelers',
                      subtitle: '$_travelers Passenger${_travelers > 1 ? 's' : ''}',
                      icon: Icons.people_alt_outlined,
                      value: _travelers,
                      minValue: 1,
                      maxValue: 12,
                      onDecrement: () {
                        if (_travelers > 1) setState(() => _travelers--);
                      },
                      onIncrement: () {
                        if (_travelers < 12) setState(() => _travelers++);
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildStepperRow(
                      label: 'Duration',
                      subtitle: '$_days Day${_days > 1 ? 's' : ''}',
                      icon: Icons.calendar_today_outlined,
                      value: _days,
                      minValue: 1,
                      maxValue: 14,
                      onDecrement: () {
                        if (_days > 1) setState(() => _days--);
                      },
                      onIncrement: () {
                        if (_days < 14) setState(() => _days++);
                      },
                      isDark: isDark,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildStepperRow(
                      label: 'Travelers',
                      subtitle: '$_travelers Passenger${_travelers > 1 ? 's' : ''}',
                      icon: Icons.people_alt_outlined,
                      value: _travelers,
                      minValue: 1,
                      maxValue: 12,
                      onDecrement: () {
                        if (_travelers > 1) setState(() => _travelers--);
                      },
                      onIncrement: () {
                        if (_travelers < 12) setState(() => _travelers++);
                      },
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildStepperRow(
                      label: 'Duration',
                      subtitle: '$_days Day${_days > 1 ? 's' : ''}',
                      icon: Icons.calendar_today_outlined,
                      value: _days,
                      minValue: 1,
                      maxValue: 14,
                      onDecrement: () {
                        if (_days > 1) setState(() => _days--);
                      },
                      onIncrement: () {
                        if (_days < 14) setState(() => _days++);
                      },
                      isDark: isDark,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Trip Type Segmented Control
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Trip Type',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Leisure', 'Business', 'Family', 'Solo'].map((type) {
                  final isSelected = _selectedTripType == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    selectedColor: AppColors.emerald.withValues(alpha: isDark ? 0.35 : 0.15),
                    backgroundColor: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? (isDark ? Colors.white : AppColors.emeraldDark)
                          : (isDark ? Colors.white70 : const Color(0xFF475569)),
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.emerald
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedTripType = type);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperRow({
    required String label,
    required String subtitle,
    required IconData icon,
    required int value,
    required int minValue,
    required int maxValue,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required bool isDark,
  }) {
    final canDecrement = value > minValue;
    final canIncrement = value < maxValue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.emerald),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.emerald,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 15),
                onPressed: canDecrement ? onDecrement : null,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                padding: EdgeInsets.zero,
                splashRadius: 14,
                tooltip: 'Decrease $label',
                style: IconButton.styleFrom(
                  backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                  foregroundColor: canDecrement
                      ? (isDark ? Colors.white : Colors.black87)
                      : (isDark ? Colors.white24 : Colors.black26),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  '$value',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 15),
                onPressed: canIncrement ? onIncrement : null,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                padding: EdgeInsets.zero,
                splashRadius: 14,
                tooltip: 'Increase $label',
                style: IconButton.styleFrom(
                  backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                  foregroundColor: canIncrement
                      ? (isDark ? Colors.white : Colors.black87)
                      : (isDark ? Colors.white24 : Colors.black26),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4-COLUMN CUSTOMIZE YOUR BUDGET GRID
  // ---------------------------------------------------------------------------
  Widget _buildCustomizationGrid(bool isDark, double availableWidth) {
    final transportItems = [
      {'name': 'Local Train / PMPML Bus (₹120/day)', 'cost': 120, 'desc': 'Budget eco-friendly'},
      {'name': 'Shared Cab / Bus (₹400/day)', 'cost': 400, 'desc': 'Most balanced'},
      {'name': 'Private AC Cab / Sedan (₹600/day)', 'cost': 600, 'desc': 'Door-to-door comfort'},
      {'name': 'Self Drive / SUV Rental (₹1,000/day)', 'cost': 1000, 'desc': 'Sahyadri ghat ready'},
    ];

    final stayItems = [
      {'name': 'No Stay (Day Trip)', 'cost': 0, 'desc': 'Same day return'},
      {'name': 'Budget Dorm / Homestay (₹500/night)', 'cost': 500, 'desc': 'Backpacker friendly'},
      {'name': 'Comfort Hotel / Homestay (₹1,100/night)', 'cost': 1100, 'desc': 'Clean AC room'},
      {'name': 'Waterfront Dome Glamping (₹1,800/night)', 'cost': 1800, 'desc': 'Pawna lakeside'},
      {'name': '5-Star Luxury Resort (₹4,500/night)', 'cost': 4500, 'desc': 'Premium valley views'},
    ];

    final foodItems = [
      {'name': 'Street Food & Misal (₹250/day)', 'cost': 250, 'desc': 'Kattas & bakeries'},
      {'name': 'Authentic Thali & Cafes (₹500/day)', 'cost': 500, 'desc': 'Puneri thali & tea'},
      {'name': 'Puneri Non-Veg & Special (₹700/day)', 'cost': 700, 'desc': 'Mutton rassa & surmai'},
      {'name': 'Fine Dining & Buffets (₹1,200/day)', 'cost': 1200, 'desc': 'Rooftop dining'},
    ];

    final activityItems = [
      {'name': 'Fort Entry & Snack (₹100/day)', 'cost': 100, 'desc': 'Sinhagad & Torna'},
      {'name': 'Fort Treks & Sightseeing (₹300/day)', 'cost': 300, 'desc': 'Guide + monuments'},
      {'name': 'Pune Darshan Bus & VIP Passes (₹500/day)', 'cost': 500, 'desc': '14 city spots pass'},
      {'name': 'Kayaking & Watersports (₹600/day)', 'cost': 600, 'desc': 'Pawna & Panshet'},
      {'name': 'Heritage Museums & Audio (₹250/day)', 'cost': 250, 'desc': 'Raja Dinkar Kelkar'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customize Your Budget',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          'Fine-tune transport, lodging, meals and sightseeing to calculate exact costs.',
          style: TextStyle(
            fontSize: 12.5,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 16),

        // Responsive Multi-Column Grid
        LayoutBuilder(
          builder: (context, constraints) {
            // >= 950: 4 columns
            // 550 - 949: 2x2 grid
            // < 550: 1 column
            if (constraints.maxWidth >= 950) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildOptionSelector(
                      title: '🚗 Transport Mode',
                      currentName: _transportModeName,
                      isDark: isDark,
                      items: transportItems,
                      onSelected: (name, cost) => setState(() {
                        _transportModeName = name;
                        _transportCostPerDayPerPerson = cost;
                        _activePreset = '';
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOptionSelector(
                      title: '🏨 Accommodation Type',
                      currentName: _stayTypeName,
                      isDark: isDark,
                      items: stayItems,
                      onSelected: (name, cost) => setState(() {
                        _stayTypeName = name;
                        _stayCostPerNightPerPerson = cost;
                        _activePreset = '';
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOptionSelector(
                      title: '🍲 Food & Dining Style',
                      currentName: _foodTypeName,
                      isDark: isDark,
                      items: foodItems,
                      onSelected: (name, cost) => setState(() {
                        _foodTypeName = name;
                        _foodCostPerDayPerPerson = cost;
                        _activePreset = '';
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOptionSelector(
                      title: '🎟️ Sightseeing & Activities',
                      currentName: _activityTypeName,
                      isDark: isDark,
                      items: activityItems,
                      onSelected: (name, cost) => setState(() {
                        _activityTypeName = name;
                        _activityCostPerDayPerPerson = cost;
                        _activePreset = '';
                      }),
                    ),
                  ),
                ],
              );
            } else if (constraints.maxWidth >= 550) {
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildOptionSelector(
                          title: '🚗 Transport Mode',
                          currentName: _transportModeName,
                          isDark: isDark,
                          items: transportItems,
                          onSelected: (name, cost) => setState(() {
                            _transportModeName = name;
                            _transportCostPerDayPerPerson = cost;
                            _activePreset = '';
                          }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOptionSelector(
                          title: '🏨 Accommodation Type',
                          currentName: _stayTypeName,
                          isDark: isDark,
                          items: stayItems,
                          onSelected: (name, cost) => setState(() {
                            _stayTypeName = name;
                            _stayCostPerNightPerPerson = cost;
                            _activePreset = '';
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildOptionSelector(
                          title: '🍲 Food & Dining Style',
                          currentName: _foodTypeName,
                          isDark: isDark,
                          items: foodItems,
                          onSelected: (name, cost) => setState(() {
                            _foodTypeName = name;
                            _foodCostPerDayPerPerson = cost;
                            _activePreset = '';
                          }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOptionSelector(
                          title: '🎟️ Sightseeing & Activities',
                          currentName: _activityTypeName,
                          isDark: isDark,
                          items: activityItems,
                          onSelected: (name, cost) => setState(() {
                            _activityTypeName = name;
                            _activityCostPerDayPerPerson = cost;
                            _activePreset = '';
                          }),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            // Mobile Single Column
            return Column(
              children: [
                _buildOptionSelector(
                  title: '🚗 Transport Mode',
                  currentName: _transportModeName,
                  isDark: isDark,
                  items: transportItems,
                  onSelected: (name, cost) => setState(() {
                    _transportModeName = name;
                    _transportCostPerDayPerPerson = cost;
                    _activePreset = '';
                  }),
                ),
                const SizedBox(height: 12),
                _buildOptionSelector(
                  title: '🏨 Accommodation Type',
                  currentName: _stayTypeName,
                  isDark: isDark,
                  items: stayItems,
                  onSelected: (name, cost) => setState(() {
                    _stayTypeName = name;
                    _stayCostPerNightPerPerson = cost;
                    _activePreset = '';
                  }),
                ),
                const SizedBox(height: 12),
                _buildOptionSelector(
                  title: '🍲 Food & Dining Style',
                  currentName: _foodTypeName,
                  isDark: isDark,
                  items: foodItems,
                  onSelected: (name, cost) => setState(() {
                    _foodTypeName = name;
                    _foodCostPerDayPerPerson = cost;
                    _activePreset = '';
                  }),
                ),
                const SizedBox(height: 12),
                _buildOptionSelector(
                  title: '🎟️ Sightseeing & Activities',
                  currentName: _activityTypeName,
                  isDark: isDark,
                  items: activityItems,
                  onSelected: (name, cost) => setState(() {
                    _activityTypeName = name;
                    _activityCostPerDayPerPerson = cost;
                    _activePreset = '';
                  }),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildOptionSelector({
    required String title,
    required String currentName,
    required bool isDark,
    required List<Map<String, dynamic>> items,
    required Function(String name, int cost) onSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          ),
          const SizedBox(height: 10),
          ...items.map((item) {
            final name = item['name'] as String;
            final cost = item['cost'] as int;
            final desc = item['desc'] as String?;
            final isCurrent = name == currentName;

            return InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onSelected(name, cost),
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6.5),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppColors.emerald.withValues(alpha: isDark ? 0.22 : 0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent
                        ? AppColors.emerald.withValues(alpha: 0.6)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      isCurrent ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isCurrent ? AppColors.emerald : Colors.grey,
                      size: 17,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                              color: isCurrent
                                  ? (isDark ? Colors.white : AppColors.emeraldDark)
                                  : (isDark ? Colors.white70 : const Color(0xFF334155)),
                            ),
                          ),
                          if (desc != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              desc,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUDGET SUMMARY SIDEBAR CARD
  // ---------------------------------------------------------------------------
  Widget _buildSummaryCard({
    required bool isDark,
    required int grandTotal,
    required int perPersonCost,
    required int totalTransport,
    required int totalStay,
    required int totalFood,
    required int totalActivities,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget Summary',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              Icon(Icons.receipt_long_rounded, color: AppColors.emerald, size: 20),
            ],
          ),
          const SizedBox(height: 14),

          // Distinct row labels so widget tests expecting 1 widget do not conflict
          _buildSummaryLineItem('Transport Cost', _formatRupees(totalTransport), isDark),
          const SizedBox(height: 8),
          _buildSummaryLineItem('Stay & Lodging', _formatRupees(totalStay), isDark),
          const SizedBox(height: 8),
          _buildSummaryLineItem('Food & Dining', _formatRupees(totalFood), isDark),
          const SizedBox(height: 8),
          _buildSummaryLineItem('Sightseeing & Activities', _formatRupees(totalActivities), isDark),
          const SizedBox(height: 8),
          _buildSummaryLineItem('Platform & Taxes', '₹0 (Included)', isDark, isHighlight: true),

          const SizedBox(height: 14),
          Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, height: 1),
          const SizedBox(height: 14),

          // Grand Total & Per Traveler
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Total Estimated',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatRupees(grandTotal),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: AppColors.emerald,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Per Traveler (${_travelers}p)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatRupees(perPersonCost),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Actions: Save Plan, Share, Download
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Budget Plan of ${_formatRupees(grandTotal)} saved to your PuneExplorer profile!'),
                    backgroundColor: AppColors.emerald,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.bookmark_add_outlined, size: 18),
              label: const Text('Save Budget Plan', style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: 'Pune Trip Budget: ${_formatRupees(grandTotal)} for $_travelers travelers (${_formatRupees(perPersonCost)}/person) for $_days days via PuneExplorer.',
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Budget summary copied to clipboard!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share_outlined, size: 15),
                  label: const Text('Share', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Generating and downloading PDF budget report...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_outlined, size: 15),
                  label: const Text('PDF Report', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLineItem(String title, String cost, bool isDark, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              color: isHighlight
                  ? AppColors.emerald
                  : (isDark ? Colors.white70 : const Color(0xFF475569)),
            ),
          ),
        ),
        Text(
          cost,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isHighlight
                ? AppColors.emerald
                : (isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SMART BUDGET TIPS CARD
  // ---------------------------------------------------------------------------
  Widget _buildTipsCard(bool isDark) {
    final tips = [
      'PMPML Day Pass: Get unlimited bus travel across Pune & PCMC for just ₹50/day.',
      'Sinhagad Fort Trek: Visit before 7:30 AM for misty sunrise views and free entry.',
      'Heritage Walk: Shaniwar Wada, Lal Mahal & Nana Wada are walkable in 1 morning.',
      'Group Stays: 4+ travelers save up to 35% by booking family villas or resorts.',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: AppColors.amber, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Smart Pune Budget Tips',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...tips.map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡 ', style: TextStyle(fontSize: 10)),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.35,
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TRAVEL SMART CTA BANNER
  // ---------------------------------------------------------------------------
  Widget _buildTravelSmartBanner(bool isDark) {
    return Container(
      constraints: const BoxConstraints(minHeight: 135),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/budget_travel_smart_cta_hd.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF064E3B)],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.85),
                      Colors.black.withValues(alpha: 0.35),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.saffron,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PUNEPASS20 AVAILABLE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Travel Smart. Explore More.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Curated weekend Sahyadri group tours with instant passes.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFFD1FAE5),
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
