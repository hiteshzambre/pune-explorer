import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../data/models/destination.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../explore/presentation/widgets/destination_card.dart';

/// Available view modes for destination presentation on the Home Screen
enum DestinationViewMode {
  grid,     // Responsive Visual Card Grid
  detailed, // Expansive Multi-Detail Cards with Highlights & Specs
  compact,  // Dense Quick Glance List for Rapid Browsing
}

/// Production-Grade Multi-View Destination Section for the PuneExplorer Home Screen
class DestinationMultiViewSection extends ConsumerStatefulWidget {
  final List<Destination> destinations;
  final int totalCount;
  final String title;
  final String subtitle;

  const DestinationMultiViewSection({
    super.key,
    required this.destinations,
    required this.totalCount,
    this.title = 'Trending Pune Getaways',
    this.subtitle = 'Top rated forts, lakes & temples this week',
  });

  @override
  ConsumerState<DestinationMultiViewSection> createState() =>
      _DestinationMultiViewSectionState();
}

class _DestinationMultiViewSectionState
    extends ConsumerState<DestinationMultiViewSection> {
  DestinationViewMode _viewMode = DestinationViewMode.grid;
  DestinationCategory _selectedCategory = DestinationCategory.all;

  List<Destination> get _filteredDestinations {
    if (_selectedCategory == DestinationCategory.all) {
      return widget.destinations;
    }
    return widget.destinations
        .where((d) => d.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final destinations = _filteredDestinations;
    final displayDestinations =
        destinations.length > 8 ? destinations.take(8).toList() : destinations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header with Title, "See All", and View Mode Switcher
        _buildHeader(theme, isDark),
        const SizedBox(height: 10),

        // 2. Category Filter Chips Strip
        _buildCategoryFilterBar(isDark),
        const SizedBox(height: 14),

        // 3. Dynamic Animated Multi-View Content
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _buildViewContent(
            context,
            displayDestinations,
            theme,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _buildSectionTitle(widget.title, widget.subtitle, theme),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                context.go('/explore');
              },
              child: Text('See All (${widget.totalCount})'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Multi-View Mode Segmented Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Active Items Count / Info Tag
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _viewMode == DestinationViewMode.grid
                          ? Icons.grid_view_rounded
                          : _viewMode == DestinationViewMode.detailed
                              ? Icons.view_agenda_rounded
                              : Icons.view_headline_rounded,
                      size: 13,
                      color: AppColors.emerald,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${_filteredDestinations.length} Places',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Right: View Mode Toggle Buttons
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildViewModeButton(
                    mode: DestinationViewMode.grid,
                    icon: Icons.grid_view_rounded,
                    tooltip: 'Grid',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 2),
                  _buildViewModeButton(
                    mode: DestinationViewMode.detailed,
                    icon: Icons.view_agenda_rounded,
                    tooltip: 'Detailed',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 2),
                  _buildViewModeButton(
                    mode: DestinationViewMode.compact,
                    icon: Icons.view_headline_rounded,
                    tooltip: 'Compact',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewModeButton({
    required DestinationViewMode mode,
    required IconData icon,
    required String tooltip,
    required bool isDark,
  }) {
    final isSelected = _viewMode == mode;
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$tooltip view mode',
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (_viewMode != mode) {
                HapticFeedback.lightImpact();
                setState(() {
                  _viewMode = mode;
                });
              }
            },
            borderRadius: BorderRadius.circular(10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.emerald
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.emerald.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.darkTextPrimary : const Color(0xFF475569)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilterBar(bool isDark) {
    final categories = [
      DestinationCategory.all,
      DestinationCategory.forts,
      DestinationCategory.hillStation,
      DestinationCategory.lakesNature,
      DestinationCategory.spiritual,
      DestinationCategory.city,
    ];

    return SizedBox(
      height: MediaQuery.textScalerOf(context).scale(34).clamp(34.0, 48.0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedCategory = cat;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.emerald.withValues(alpha: 0.15)
                      : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.emerald
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    width: isSelected ? 1.4 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cat.icon, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      cat.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? AppColors.emerald
                            : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildViewContent(
    BuildContext context,
    List<Destination> destinations,
    ThemeData theme,
    bool isDark,
  ) {
    if (destinations.isEmpty) {
      return Container(
        key: const ValueKey('empty_view'),
        padding: const EdgeInsets.all(28),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Text('🏔️', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 10),
            Text(
              'No destinations found in this category.',
              style: TextStyle(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () {
                setState(() => _selectedCategory = DestinationCategory.all);
              },
              child: const Text('Show All Destinations'),
            ),
          ],
        ),
      );
    }

    switch (_viewMode) {
      case DestinationViewMode.grid:
        return MasonryGridView.count(
          key: const ValueKey('grid_view'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: Breakpoints.getGridColumnCount(
            context,
            mobile: 1,
            tablet: 2,
            desktop: 3,
          ),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          itemCount: destinations.length,
          itemBuilder: (context, index) {
            final dest = destinations[index];
            return DestinationCard(destination: dest, index: index);
          },
        );

      case DestinationViewMode.detailed:
        return ListView.separated(
          key: const ValueKey('detailed_view'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: destinations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final dest = destinations[index];
            return _DetailedDestinationCard(
              destination: dest,
              onQuickView: () => _showDestinationQuickViewSheet(context, dest),
            );
          },
        );

      case DestinationViewMode.compact:
        return ListView.separated(
          key: const ValueKey('compact_view'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: destinations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final dest = destinations[index];
            return _CompactDestinationCard(
              destination: dest,
              onQuickView: () => _showDestinationQuickViewSheet(context, dest),
            );
          },
        );
    }
  }

  Widget _buildSectionTitle(String title, String subtitle, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3.5,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.saffron,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5),
        ),
      ],
    );
  }

  /// Interactive Multi-Tab Quick-View Bottom Sheet for in-depth destination inspection
  void _showDestinationQuickViewSheet(BuildContext context, Destination dest) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DestinationQuickViewModal(destination: dest),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Detailed View Mode Destination Card
/// ---------------------------------------------------------------------------
class _DetailedDestinationCard extends ConsumerWidget {
  final Destination destination;
  final VoidCallback onQuickView;

  const _DetailedDestinationCard({
    required this.destination,
    required this.onQuickView,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isFav = ref.watch(
      favoritesProvider.select((set) => set.contains(destination.id)),
    );

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
        boxShadow: AppColors.cardShadow(isDark),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            context.push('/destination/${destination.id}');
          },
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Full Bleed Image Header
              Stack(
                children: [
                  AppCardImage(
                    imageUrl: destination.primaryImage,
                    aspectRatio: 16 / 9,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                    heroTag: 'dest_detailed_${destination.id}',
                    categoryIcon: destination.category.icon,
                    categoryLabel: destination.category.label,
                    title: destination.name,
                  ),

                  // Category Gradient Badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: destination.category.gradient,
                        borderRadius: BorderRadius.circular(7),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(destination.category.icon, style: const TextStyle(fontSize: 11)),
                          const SizedBox(width: 4),
                          Text(
                            destination.category.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Heart Favorite Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          ref.read(favoritesProvider.notifier).toggle(destination.id);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? Colors.redAccent : Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Distance & Duration Chips on Image Bottom
                  Positioned(
                    bottom: 8,
                    left: 10,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.72),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.near_me_rounded, color: AppColors.emeraldLight, size: 10),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    destination.distanceFromPuneKm == 0
                                        ? 'In City'
                                        : '${destination.distanceFromPuneKm.toInt()} km',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.72),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.schedule_rounded, color: AppColors.saffron, size: 10),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    destination.recommendedDuration,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 2. Comprehensive Details Body
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & City
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                destination.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${destination.city} • ${destination.state}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Rating Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.amber.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.amber.withValues(alpha: 0.4), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: AppColors.amber, size: 14),
                              const SizedBox(width: 3),
                              Text(
                                destination.rating.toStringAsFixed(1),
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      destination.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        fontSize: 11.5,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 3-Column Quick-Specs Detail Grid
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF131D1B) : const Color(0xFFF4F7F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSpecItem(
                              icon: Icons.confirmation_number_outlined,
                              label: 'Entry Fee',
                              value: destination.entryFeeIndian == 0
                                  ? 'Free'
                                  : '₹${destination.entryFeeIndian.toInt()}',
                              isEmerald: destination.entryFeeIndian == 0,
                              isDark: isDark,
                            ),
                          ),
                          Container(width: 1, height: 24, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          Expanded(
                            child: _buildSpecItem(
                              icon: Icons.access_time_filled_rounded,
                              label: 'Timings',
                              value: destination.openingHours,
                              isDark: isDark,
                            ),
                          ),
                          Container(width: 1, height: 24, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          Expanded(
                            child: _buildSpecItem(
                              icon: Icons.wb_sunny_rounded,
                              label: 'Best Time',
                              value: destination.bestTime,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Famous For Highlight Pill
                    if (destination.famousFor.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.saffron.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: AppColors.saffron.withValues(alpha: 0.3), width: 0.8),
                        ),
                        child: Row(
                          children: [
                            const Text('✨', style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'Famous for: ${destination.famousFor}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.saffron,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Action Buttons Row (Quick Peek + View Details)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onQuickView,
                            icon: const Icon(Icons.remove_red_eye_outlined, size: 15),
                            label: const Text('Quick Preview', maxLines: 1, overflow: TextOverflow.ellipsis),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.emerald,
                              side: const BorderSide(color: AppColors.emerald, width: 1.1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              context.push('/destination/${destination.id}');
                            },
                            icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                            label: const Text('View Details', maxLines: 1, overflow: TextOverflow.ellipsis),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emerald,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                            ),
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
      ),
    );
  }

  Widget _buildSpecItem({
    required IconData icon,
    required String label,
    required String value,
    bool isEmerald = false,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 11, color: isEmerald ? AppColors.emerald : AppColors.saffron),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: isEmerald ? AppColors.emerald : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Compact View Mode Destination Card (Dense Quick List)
/// ---------------------------------------------------------------------------
class _CompactDestinationCard extends ConsumerWidget {
  final Destination destination;
  final VoidCallback onQuickView;

  const _CompactDestinationCard({
    required this.destination,
    required this.onQuickView,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isFav = ref.watch(
      favoritesProvider.select((set) => set.contains(destination.id)),
    );

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.1,
        ),
        boxShadow: AppColors.cardShadow(isDark),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            context.push('/destination/${destination.id}');
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                // Thumbnail Image
                AppCardImage(
                  imageUrl: destination.primaryImage,
                  width: 78,
                  height: 78,
                  borderRadius: BorderRadius.circular(12),
                  heroTag: 'dest_compact_${destination.id}',
                  categoryIcon: destination.category.icon,
                  categoryLabel: destination.category.label,
                  title: destination.name,
                ),
                const SizedBox(width: 10),

                // Center Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: destination.category.gradient,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                destination.category.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              destination.distanceFromPuneKm == 0
                                  ? 'In City'
                                  : '${destination.distanceFromPuneKm.toInt()} km',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        destination.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            destination.rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            destination.entryFeeIndian == 0 ? 'Free' : '₹${destination.entryFeeIndian.toInt()}',
                            style: TextStyle(
                              color: destination.entryFeeIndian == 0 ? AppColors.emerald : AppColors.gold,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Trailing Action Buttons
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFav ? Colors.redAccent : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                        size: 19,
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        ref.read(favoritesProvider.notifier).toggle(destination.id);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      tooltip: isFav ? 'Remove Favorite' : 'Save Favorite',
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_red_eye_outlined, size: 19, color: AppColors.emerald),
                      onPressed: onQuickView,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      tooltip: 'Quick Preview',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Interactive Multi-Tab Quick-View Bottom Sheet Modal
/// ---------------------------------------------------------------------------
class _DestinationQuickViewModal extends StatefulWidget {
  final Destination destination;

  const _DestinationQuickViewModal({required this.destination});

  @override
  State<_DestinationQuickViewModal> createState() =>
      _DestinationQuickViewModalState();
}

class _DestinationQuickViewModalState extends State<_DestinationQuickViewModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dest = widget.destination;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 1. Grab Handle & Top Navigation Bar
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 6),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black26,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(dest.category.icon, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                dest.category.label,
                                style: const TextStyle(
                                  color: AppColors.emerald,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            dest.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Segmented Multi-View Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppColors.emerald,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Timings & Fees'),
                Tab(text: 'Highlights & Tips'),
              ],
            ),
          ),

          // 3. Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: OVERVIEW
                _buildOverviewTab(dest, isDark),
                // TAB 2: TIMINGS & FEES
                _buildTimingsTab(dest, isDark),
                // TAB 3: HIGHLIGHTS & TIPS
                _buildHighlightsTab(dest, isDark),
              ],
            ),
          ),

          // 4. Bottom CTA Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 1)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push('/destination/${dest.id}');
                      },
                      icon: const Icon(Icons.travel_explore_rounded, size: 18),
                      label: const Text('Open Full Destination Guide'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
  }

  Widget _buildOverviewTab(Destination dest, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCardImage(
            imageUrl: dest.primaryImage,
            aspectRatio: 16 / 9,
            borderRadius: BorderRadius.circular(18),
            categoryIcon: dest.category.icon,
            categoryLabel: dest.category.label,
            title: dest.name,
          ),
          const SizedBox(height: 16),
          if (dest.famousFor.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.saffron.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.saffron.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  const Text('👑', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PRIMARY CLAIM TO FAME',
                          style: TextStyle(color: AppColors.saffron, fontSize: 10.5, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          dest.famousFor,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          const Text(
            'Historical Narrative & Significance',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            dest.longDescription.isNotEmpty ? dest.longDescription : dest.description,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingsTab(Destination dest, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoRowCard(
            icon: Icons.access_time_filled_rounded,
            title: 'Visiting Hours',
            value: dest.openingHours,
            subtitle: 'Open 7 days a week (Check local alerts during heavy rains)',
            color: AppColors.emerald,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildInfoRowCard(
            icon: Icons.confirmation_number_rounded,
            title: 'Entry Fee Structure',
            value: dest.entryFeeIndian == 0
                ? 'Free Entry for All Visitors'
                : '₹${dest.entryFeeIndian.toInt()} (Indian Nationals) • ₹${dest.entryFeeForeign.toInt()} (Foreigners)',
            subtitle: 'Statutory ASI / PMC ticket rules apply at entrance gates',
            color: AppColors.saffron,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildInfoRowCard(
            icon: Icons.calendar_month_rounded,
            title: 'Recommended Season',
            value: dest.bestTime,
            subtitle: 'Ideal weather conditions for scenic views & photography',
            color: const Color(0xFF0284C7),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildInfoRowCard(
            icon: Icons.timer_rounded,
            title: 'Suggested Tour Duration',
            value: dest.recommendedDuration,
            subtitle: 'Adequate time to cover main ramparts, trails & exhibitions',
            color: const Color(0xFF7C3AED),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsTab(Destination dest, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notable Attractions & Key Spots',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          const SizedBox(height: 8),
          if (dest.attractions.isNotEmpty)
            ...dest.attractions.map(
              (att) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.place_rounded, color: AppColors.emerald, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(att.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                          if (att.description.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              att.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Text(
              'Highlights information available on full destination guide.',
              style: TextStyle(color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
            ),
          const SizedBox(height: 16),
          const Text(
            'Smart Traveler Tips',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          const SizedBox(height: 8),
          if (dest.travelTips.isNotEmpty)
            ...dest.travelTips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡 ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            const Text(
              '💡 Wear comfortable trekking or walking footwear.\n💡 Carry a reusable water bottle and sun protection.',
              style: TextStyle(fontSize: 12.5, height: 1.4),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRowCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
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
}
