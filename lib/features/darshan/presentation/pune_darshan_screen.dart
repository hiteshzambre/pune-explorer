import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_boundary.dart';
import '../../../data/models/tour_package.dart';

class PuneDarshanScreen extends ConsumerStatefulWidget {
  const PuneDarshanScreen({super.key});

  @override
  ConsumerState<PuneDarshanScreen> createState() => _PuneDarshanScreenState();
}

class _PuneDarshanScreenState extends ConsumerState<PuneDarshanScreen> {
  String _selectedCategory = 'All Tours';

  static const List<String> _filterCategories = [
    'All Tours',
    'Official Darshan',
    'Heritage & Forts',
    'Hill Station',
    'Adventure',
  ];

  final ScrollController _stopsScrollController = ScrollController();
  bool _canScrollStopsLeft = false;
  bool _canScrollStopsRight = true;

  @override
  void initState() {
    super.initState();
    _stopsScrollController.addListener(_updateStopsScrollButtons);
  }

  @override
  void dispose() {
    _stopsScrollController.removeListener(_updateStopsScrollButtons);
    _stopsScrollController.dispose();
    super.dispose();
  }

  void _updateStopsScrollButtons() {
    if (!_stopsScrollController.hasClients) return;
    final max = _stopsScrollController.position.maxScrollExtent;
    final offset = _stopsScrollController.offset;
    final canLeft = offset > 10;
    final canRight = offset < max - 10;
    if (canLeft != _canScrollStopsLeft || canRight != _canScrollStopsRight) {
      setState(() {
        _canScrollStopsLeft = canLeft;
        _canScrollStopsRight = canRight;
      });
    }
  }

  void _scrollStopsLeft() {
    HapticFeedback.selectionClick();
    if (_stopsScrollController.hasClients) {
      _stopsScrollController.animateTo(
        (_stopsScrollController.offset - 240).clamp(0.0, _stopsScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _scrollStopsRight() {
    HapticFeedback.selectionClick();
    if (_stopsScrollController.hasClients) {
      _stopsScrollController.animateTo(
        (_stopsScrollController.offset + 240).clamp(0.0, _stopsScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tourPackagesAsync = ref.watch(tourPackagesAsyncProvider);
    final isSmallPhone = Breakpoints.isSmallPhone(context);
    final double horizontalPadding = isSmallPhone ? 12.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pune Darshan Bus Tours'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Tour Information & FAQs',
            onPressed: () => _scrollToFaq(),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Tour Details',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pune Darshan tour details link copied!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: MaxWidthWrapper(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Premium Hero Banner
              _buildHeroBanner(isDark, theme, isSmallPhone),
              const SizedBox(height: 20),

              // 2. Official 7-Stop Heritage Circuit
              _buildHeritageStopsSection(isDark, theme, isSmallPhone),
              const SizedBox(height: 22),

              // 3. Tour Packages Filter & Header
              _buildPackagesHeader(theme),
              const SizedBox(height: 10),
              _buildCategoryFilters(isDark, theme),
              const SizedBox(height: 14),

              // 4. Tour Packages List / Grid
              tourPackagesAsync.when(
                data: (packages) {
                  final filteredPackages = packages.where((p) => _matchesCategory(p, _selectedCategory)).toList();
                  if (filteredPackages.isEmpty) {
                    return const EmptyStateView(
                      icon: '🚌',
                      title: 'No Tours in this Category',
                      description: 'Try selecting "All Tours" or another category to view scheduled departures.',
                    );
                  }
                  return _buildPackagesLayout(filteredPackages, isDark, theme, context);
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => ErrorBoundaryWidget(
                  errorMessage: 'Unable to load tour packages: $err',
                  onRetry: () => ref.refresh(tourPackagesAsyncProvider),
                ),
              ),
              const SizedBox(height: 24),

              // 5. Boarding Points & Morning Timetable
              _buildBoardingPointsCard(isDark, theme, isSmallPhone),
              const SizedBox(height: 22),

              // 6. Amenities & Tour Features Grid
              _buildAmenitiesGrid(isDark, theme),
              const SizedBox(height: 22),

              // 7. Interactive FAQs Section
              _buildFaqSection(isDark, theme),
              const SizedBox(height: 22),

              // 8. Support & Booking Helpline Banner
              _buildHelplineCard(isDark, theme, isSmallPhone),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── 1. Hero Banner ────────────────────────────────────────────────────────
  Widget _buildHeroBanner(bool isDark, ThemeData theme, bool isSmallPhone) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF064E3B), const Color(0xFF0F172A)]
              : [const Color(0xFF047857), const Color(0xFF064E3B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background subtle bus graphic
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.directions_bus_filled_rounded,
              size: 160,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isSmallPhone ? 14 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.saffron,
                        borderRadius: BorderRadius.circular(7),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'PMPML & MTDC OFFICIAL',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule_rounded, color: Color(0xFF6EE7B7), size: 12),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Daily 8 AM Departures',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Pune Darshan Sightseeing Tours',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallPhone ? 19 : 23,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Explore Peshwa palaces, sacred Ganpati shrines, royal museums, and freedom memorials in comfort aboard a luxury AC Volvo with live historian commentary.',
                  style: TextStyle(
                    color: Color(0xFFD1FAE5),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                const Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    _FeaturePill(icon: Icons.airline_seat_recline_extra_rounded, label: 'Pushback AC Volvo'),
                    _FeaturePill(icon: Icons.stars_rounded, label: 'VIP Dagdusheth Entry'),
                    _FeaturePill(icon: Icons.record_voice_over_rounded, label: 'Certified Guide'),
                    _FeaturePill(icon: Icons.confirmation_number_rounded, label: 'Monument Passes'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. Official 7-Stop Heritage Route Circuit ──────────────────────────────
  Widget _buildHeritageStopsSection(bool isDark, ThemeData theme, bool isSmallPhone) {
    return Semantics(
      container: true,
      label: 'Official 7-Stop Circuit with 7 key sightseeing destinations in Pune',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Official 7-Stop Circuit',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Complete city route from 8:00 AM to 7:00 PM',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // 7 Stops Badge + Desktop Navigation Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '7 Key Stops',
                      style: TextStyle(color: AppColors.emerald, fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Explicit Controls: [ ← ] [ → ]
                  Semantics(
                    button: true,
                    label: 'Previous stops',
                    child: IconButton(
                      onPressed: _canScrollStopsLeft ? _scrollStopsLeft : null,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 13),
                      tooltip: 'Previous stops',
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? AppColors.darkSurface : const Color(0xFFEEF2F0),
                        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                        disabledBackgroundColor: Colors.transparent,
                        disabledForegroundColor: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Semantics(
                    button: true,
                    label: 'Next stops',
                    child: IconButton(
                      onPressed: _canScrollStopsRight ? _scrollStopsRight : null,
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 13),
                      tooltip: 'Next stops',
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? AppColors.darkSurface : const Color(0xFFEEF2F0),
                        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                        disabledBackgroundColor: Colors.transparent,
                        disabledForegroundColor: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Horizontal Carousel of stops
          SizedBox(
            height: 136,
            child: ListView.separated(
              controller: _stopsScrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _officialDarshanStops.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final stop = _officialDarshanStops[index];
              return Container(
                width: 220,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.emerald, Color(0xFF047857)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            stop.stopNumber,
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            stop.time,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.saffron,
                            ),
                          ),
                        ),
                        Icon(stop.icon, size: 16, color: AppColors.amber),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stop.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        stop.highlight,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.3,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
    );
  }

  // ── 3. Filter Categories ──────────────────────────────────────────────────
  Widget _buildPackagesHeader(ThemeData theme) {
    return Text(
      'Select Tour Package',
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    );
  }

  Widget _buildCategoryFilters(bool isDark, ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filterCategories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                cat,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12.5,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.emerald,
              backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              side: BorderSide(
                color: isSelected
                    ? AppColors.emerald
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              onSelected: (selected) {
                if (selected) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedCategory = cat);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _matchesCategory(TourPackage pkg, String category) {
    switch (category) {
      case 'Official Darshan':
        return pkg.id.startsWith('PNE-DAR') ||
            pkg.id.contains('darshan') ||
            pkg.title.toLowerCase().contains('darshan') ||
            pkg.badge.toLowerCase().contains('official');
      case 'Heritage & Forts':
        return pkg.category.toLowerCase().contains('history') ||
            pkg.category.toLowerCase().contains('historical') ||
            pkg.title.toLowerCase().contains('fort') ||
            pkg.title.toLowerCase().contains('darshan');
      case 'Hill Station':
        return pkg.category.toLowerCase().contains('hill') ||
            pkg.title.toLowerCase().contains('lonavala') ||
            pkg.title.toLowerCase().contains('khandala');
      case 'Adventure':
        return pkg.category.toLowerCase().contains('adventure') ||
            pkg.title.toLowerCase().contains('trek') ||
            pkg.title.toLowerCase().contains('lake');
      default:
        return true;
    }
  }

  // ── 4. Packages Layout (Responsive Grid / Column) ─────────────────────────
  Widget _buildPackagesLayout(
    List<TourPackage> packages,
    bool isDark,
    ThemeData theme,
    BuildContext context,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        // Desktop / Wide displays: 3 Cards per row
        if (width >= 880) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: packages.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 512,
            ),
            itemBuilder: (context, index) {
              return _buildDarshanCard(packages[index], isDark, theme, context, isGrid: true);
            },
          );
        }

        // Foldable & Tablets: 2 Cards per row
        if (width >= 580) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: packages.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 512,
            ),
            itemBuilder: (context, index) {
              return _buildDarshanCard(packages[index], isDark, theme, context, isGrid: true);
            },
          );
        }

        // Mobile Single Column (natural height, zero blank space)
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: packages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildDarshanCard(packages[index], isDark, theme, context, isGrid: false);
          },
        );
      },
    );
  }

  // ── 4a. Redesigned Darshan Tour Card ───────────────────────────────────────
  Widget _buildDarshanCard(
    TourPackage pkg,
    bool isDark,
    ThemeData theme,
    BuildContext context, {
    bool isGrid = false,
  }) {
    final double discount = pkg.originalPrice > pkg.price ? (pkg.originalPrice - pkg.price) : 0;
    final int discountPct = pkg.originalPrice > 0 ? (((pkg.originalPrice - pkg.price) / pkg.originalPrice) * 100).round() : 0;
    final bool isDarshan = pkg.id.startsWith('PNE-DAR') || pkg.id.contains('darshan');

    final Widget cardBody = Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: LayoutBuilder(
        builder: (context, cardConstraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Rating Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      pkg.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                        height: 1.22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.amber, size: 15),
                        const SizedBox(width: 2),
                        Text(
                          '${pkg.rating}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                        Text(
                          ' (${pkg.reviewCount})',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),

              // Subtitle description
              Text(
                pkg.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.3,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),

              // Key Inclusions Tags
              Wrap(
                spacing: 6,
                runSpacing: 5,
                children: pkg.inclusions.take(cardConstraints.maxWidth < 340 ? 2 : 3).map((inc) {
                  return Container(
                    constraints: BoxConstraints(maxWidth: cardConstraints.maxWidth - 10),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 11, color: AppColors.emerald),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            inc,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),

              // Pickup Points Summary Strip
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 13, color: AppColors.saffron),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Pickups: ${pkg.pickupPoints.take(3).join(', ')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // View Itinerary Action Button
              InkWell(
                onTap: () => _showItineraryModal(context, pkg, isDark, theme),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant.withValues(alpha: 0.6) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month_rounded, size: 14, color: AppColors.emerald),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'View Full Day Itinerary & Stops',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.emerald,
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.emerald),
                    ],
                  ),
                ),
              ),
              if (isGrid) const Spacer() else const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Price and Booking CTA
              _buildCardPriceAndCta(pkg, discount, cardConstraints.maxWidth, context),
            ],
          );
        },
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarshan
              ? AppColors.emerald.withValues(alpha: 0.6)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isDarshan ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarshan
                ? AppColors.emerald.withValues(alpha: isDark ? 0.18 : 0.08)
                : Colors.black.withValues(alpha: isDark ? 0.22 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Header with Badges
          Stack(
            children: [
              AppCardImage(
                imageUrl: pkg.primaryImage,
                height: 155,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                categoryIcon: '🚌',
                categoryLabel: pkg.category,
                title: pkg.title,
                fit: BoxFit.cover,
              ),
              // Top Left Badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.saffron, Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.white, size: 13),
                      const SizedBox(width: 3),
                      Text(
                        pkg.badge,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
              // Top Right Discount Badge
              if (discountPct > 0)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.emerald,
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 4, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Text(
                      '$discountPct% OFF',
                      style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              // Bottom Right Duration Pill
              Positioned(
                bottom: 10,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timelapse_rounded, color: Color(0xFF6EE7B7), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        pkg.duration,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Card Body
          if (isGrid) Expanded(child: cardBody) else cardBody,
        ],
      ),
    );
  }

  Widget _buildCardPriceAndCta(TourPackage pkg, double discount, double cardWidth, BuildContext context) {
    final shouldStack = Breakpoints.shouldStackCard(cardWidth);

    if (shouldStack) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 8,
            runSpacing: 4,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Per Passenger', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹${pkg.price.toInt()}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.emerald,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '₹${pkg.originalPrice.toInt()}',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (discount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Save ₹${discount.toInt()}',
                    style: const TextStyle(
                      color: AppColors.emerald,
                      fontWeight: FontWeight.w800,
                      fontSize: 10.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          CustomButton(
            text: 'Select Seats & Book',
            icon: const Icon(Icons.event_seat_rounded, size: 15),
            variant: ButtonVariant.primary,
            isFullWidth: true,
            height: 42,
            onPressed: () => context.push('/booking/${pkg.id}'),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Per Passenger', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  Text(
                    '₹${pkg.price.toInt()}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.emerald,
                    ),
                  ),
                  Text(
                    '₹${pkg.originalPrice.toInt()}',
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  if (discount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Save ₹${discount.toInt()}',
                        style: const TextStyle(
                          color: AppColors.emerald,
                          fontWeight: FontWeight.w800,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        CustomButton(
          text: 'Select Seats & Book',
          icon: const Icon(Icons.event_seat_rounded, size: 15),
          variant: ButtonVariant.primary,
          height: 42,
          onPressed: () => context.push('/booking/${pkg.id}'),
        ),
      ],
    );
  }

  // ── 5. Boarding Points & Morning Timings Card ─────────────────────────────
  Widget _buildBoardingPointsCard(bool isDark, ThemeData theme, bool isSmallPhone) {
    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 16 : 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.saffron.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bus_alert_rounded, color: AppColors.saffron, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Boarding Points & Morning Timings',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bus arrives 10 minutes prior to scheduled departure',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 460;
              final points = [
                const _BoardingPointItem(title: 'Wakad Bridge', time: '07:30 AM', note: 'Near Ginger Hotel Highway'),
                const _BoardingPointItem(title: 'Pune Railway Station', time: '08:00 AM', note: 'Opposite Main Exit Gate'),
                const _BoardingPointItem(title: 'Swargate Bus Stand', time: '08:20 AM', note: 'Platform 1 MTDC Counter'),
                const _BoardingPointItem(title: 'Deccan Gymkhana', time: '08:35 AM', note: 'Goodluck Chowk Stop'),
              ];

              if (isNarrow) {
                return Column(
                  children: points.map((p) => Padding(padding: const EdgeInsets.only(bottom: 10), child: p)).toList(),
                );
              }

              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: points,
              );
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.emerald.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.hotel_rounded, size: 16, color: AppColors.emerald),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Doorstep Hotel Pickup available for groups of 4+ across central Pune.',
                    style: TextStyle(fontSize: 11.5, color: AppColors.emerald, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 6. Amenities Grid ─────────────────────────────────────────────────────
  Widget _buildAmenitiesGrid(bool isDark, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Onboard Luxury Amenities',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 500;
            return GridView.count(
              crossAxisCount: isCompact ? 2 : 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: isCompact ? 1.6 : 1.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: const [
                _AmenityCard(icon: Icons.airline_seat_recline_extra_rounded, title: 'Pushback Seats', subtitle: 'Ergonomic luxury'),
                _AmenityCard(icon: Icons.ac_unit_rounded, title: 'Powerful AC', subtitle: 'Climate controlled'),
                _AmenityCard(icon: Icons.battery_charging_full_rounded, title: 'USB Chargers', subtitle: 'Every seat row'),
                _AmenityCard(icon: Icons.sanitizer_rounded, title: 'Sanitized Daily', subtitle: 'Safe & hygienic'),
              ],
            );
          },
        ),
      ],
    );
  }

  // ── 7. Interactive FAQs ───────────────────────────────────────────────────
  Widget _buildFaqSection(bool isDark, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Essential information for tourists and pilgrims',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
        const SizedBox(height: 14),
        ..._darshanFaqs.map((faq) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  iconColor: AppColors.emerald,
                  collapsedIconColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  title: Text(
                    faq.question,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      child: Text(
                        faq.answer,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── 8. Helpline & Support Card ────────────────────────────────────────────
  Widget _buildHelplineCard(bool isDark, ThemeData theme, bool isSmallPhone) {
    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 14 : 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFF0FDF4), const Color(0xFFE2E8F0)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.emerald.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.support_agent_rounded, color: AppColors.emerald, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Need Help Booking or Special Assistance?',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(
                  'Daily Helpline: 1800-PUNE-DARSHAN (7 AM – 9 PM)',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Show Hour-by-Hour Itinerary Modal ─────────────────────────────────────
  void _showItineraryModal(BuildContext context, TourPackage pkg, bool isDark, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.82,
          minChildSize: 0.5,
          maxChildSize: 0.94,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Column(
                children: [
                  // Drag Handle & Title
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 6, 12, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pkg.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '⏱️ ${pkg.duration} • ⭐️ ${pkg.rating} Rating',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Scrollable Itinerary Body
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(18),
                      children: [
                        // Itinerary Schedule
                        const Text(
                          'Hour-by-Hour Schedule',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                        ),
                        const SizedBox(height: 12),
                        if (pkg.itinerary.isEmpty)
                          const Text('Detailed schedule will be confirmed by tour leader upon departure.')
                        else
                          ...pkg.itinerary.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                                    decoration: BoxDecoration(
                                      color: AppColors.emerald.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.time,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.emerald,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.desc,
                                          style: TextStyle(
                                            fontSize: 12,
                                            height: 1.35,
                                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),

                        // Inclusions
                        const Text('What is Included', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        const SizedBox(height: 8),
                        ...pkg.inclusions.map((inc) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(inc, style: const TextStyle(fontSize: 12.5))),
                                ],
                              ),
                            )),

                        // Exclusions
                        if (pkg.exclusions.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Text('Not Included', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          const SizedBox(height: 8),
                          ...pkg.exclusions.map((exc) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(exc, style: const TextStyle(fontSize: 12.5))),
                                  ],
                                ),
                              )),
                        ],
                      ],
                    ),
                  ),

                  // Bottom Action Bar
                  Container(
                    padding: EdgeInsets.fromLTRB(18, 12, 18, 12 + MediaQuery.paddingOf(context).bottom),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total per seat', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text(
                              '₹${pkg.price.toInt()}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.emerald,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomButton(
                            text: 'Select Seats & Book',
                            icon: const Icon(Icons.event_seat_rounded, size: 16),
                            variant: ButtonVariant.primary,
                            height: 48,
                            onPressed: () {
                              Navigator.pop(context);
                              context.push('/booking/${pkg.id}');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _scrollToFaq() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scroll down to read our detailed FAQs and Helpline info.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// ── Helper Subwidgets ───────────────────────────────────────────────────────
class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.amber, size: 14),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _BoardingPointItem extends StatelessWidget {
  final String title;
  final String time;
  final String note;

  const _BoardingPointItem({required this.title, required this.time, required this.note});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.saffron.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.saffron,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmenityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AmenityCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.emerald),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Route Stops Model & Data ────────────────────────────────────────────────
class _DarshanStop {
  final String stopNumber;
  final String time;
  final String title;
  final String highlight;
  final IconData icon;

  const _DarshanStop({
    required this.stopNumber,
    required this.time,
    required this.title,
    required this.highlight,
    required this.icon,
  });
}

const List<_DarshanStop> _officialDarshanStops = [
  _DarshanStop(
    stopNumber: '01',
    time: '08:45 AM',
    title: 'Shaniwar Wada',
    highlight: 'Iconic 1732 AD seat of the Peshwas & monumental Dilli Darwaza.',
    icon: Icons.castle_rounded,
  ),
  _DarshanStop(
    stopNumber: '02',
    time: '09:45 AM',
    title: 'Lal Mahal',
    highlight: 'Historic red palace where Chhatrapati Shivaji Maharaj spent childhood.',
    icon: Icons.fort_rounded,
  ),
  _DarshanStop(
    stopNumber: '03',
    time: '10:30 AM',
    title: 'Dagdusheth Ganpati',
    highlight: 'Express VIP group entry to seek blessings at the golden idol.',
    icon: Icons.temple_hindu_rounded,
  ),
  _DarshanStop(
    stopNumber: '04',
    time: '12:00 PM',
    title: 'Raja Kelkar Museum',
    highlight: '20,000+ rare Maratha artifacts, musical instruments & royal arms.',
    icon: Icons.museum_rounded,
  ),
  _DarshanStop(
    stopNumber: '05',
    time: '01:30 PM',
    title: 'Sarasbaug & Lake',
    highlight: 'Scenic Ganesh temple nestled in lotus pond & authentic lunch break.',
    icon: Icons.park_rounded,
  ),
  _DarshanStop(
    stopNumber: '06',
    time: '03:15 PM',
    title: 'Aga Khan Palace',
    highlight: 'Majestic Italian arches & Father of Nation Mahatma Gandhi memorial.',
    icon: Icons.account_balance_rounded,
  ),
  _DarshanStop(
    stopNumber: '07',
    time: '05:30 PM',
    title: 'Return via Swargate',
    highlight: 'Comfortable drop-off at Deccan, Swargate, and Pune Station.',
    icon: Icons.directions_bus_rounded,
  ),
];

// ── FAQs Model & Data ───────────────────────────────────────────────────────
class _DarshanFaq {
  final String question;
  final String answer;

  const _DarshanFaq({required this.question, required this.answer});
}

const List<_DarshanFaq> _darshanFaqs = [
  _DarshanFaq(
    question: 'What are the daily tour timings and duration?',
    answer:
        'The official Pune Darshan tour runs daily from 08:00 AM to 07:00 PM. Morning pickups start at 07:30 AM at Wakad and 08:00 AM at Pune Railway Station, returning by 07:00 PM.',
  ),
  _DarshanFaq(
    question: 'How does the VIP Dagdusheth Ganpati Darshan work?',
    answer:
        'Every Pune Darshan passenger receives an authorized express group pass. Our tour guide leads the group directly through the VIP darshan channel without waiting in general public lines.',
  ),
  _DarshanFaq(
    question: 'Are monument entry fees and tickets included?',
    answer:
        'Yes! Entry permits for Shaniwar Wada, Aga Khan Palace, and Raja Dinkar Kelkar Museum are fully covered in your ticket. You do not need to wait in ticket queues.',
  ),
  _DarshanFaq(
    question: 'Is lunch provided during the tour?',
    answer:
        'A complimentary morning breakfast snack box and mineral water are provided on the bus. For lunch, the bus halts for 1 hour at Sarasbaug where passengers can choose from traditional Maharashtrian thalis and hygienic food courts.',
  ),
  _DarshanFaq(
    question: 'Can I cancel or reschedule my booking?',
    answer:
        'Yes. Cancellations made more than 24 hours prior to departure receive an instant 90% refund. Rescheduling to another date is completely free up to 12 hours before departure.',
  ),
];
