import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/widgets/error_boundary.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../data/models/heritage_walk.dart';
import 'theme/heritage_walk_typography.dart';
import 'widgets/heritage_walk_card.dart';
import 'widgets/heritage_walk_filter_sheet.dart';

class HeritageWalksScreen extends ConsumerStatefulWidget {
  const HeritageWalksScreen({super.key});

  @override
  ConsumerState<HeritageWalksScreen> createState() => _HeritageWalksScreenState();
}

class _HeritageWalksScreenState extends ConsumerState<HeritageWalksScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        ref.read(heritageWalkFilterProvider.notifier).setSearchQuery(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final walksAsync = ref.watch(filteredHeritageWalksProvider);
    final filterState = ref.watch(heritageWalkFilterProvider);

    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '🏛️ Heritage Walks of Pune',
          style: HeritageWalkTypography.pageTitle(color: textColor, fontSize: 18),
        ),
      ),
      body: MaxWidthWrapper(
        padding: EdgeInsets.zero,
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(heritageWalksAsyncProvider),
          color: const Color(0xFFD97706),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. Premium Hero Banner & Discovery Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Architectural Emerald Hero Container
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF064E3B), // Deep Emerald
                              Color(0xFF022C22), // Forest Night
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF064E3B).withValues(alpha: 0.22),
                              blurRadius: 16,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Marathi Badge & Subtitle
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFFFDE68A).withValues(alpha: 0.35),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('🏛️ ', style: TextStyle(fontSize: 11)),
                                        Text(
                                          'पुणे वारसा पदभ्रमण',
                                          style: HeritageWalkTypography.marathiBadge(
                                            color: const Color(0xFFFDE68A),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Text(
                                  'Curated Walking Tours',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Hero Headline
                            Text(
                              'Walk Through 400 Years of History',
                              style: HeritageWalkTypography.heroTitle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 5),

                            // Hero Subtitle
                            Text(
                              'Explore Maratha wadas, copper craft lanes, freedom fighters, and historic food pitstops with GPS walking trails.',
                              style: HeritageWalkTypography.cardDescription(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Search Input & Filter Button
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: HeritageWalkTypography.meta(color: textColor, fontSize: 13),
                              onChanged: _onSearchChanged,
                              decoration: InputDecoration(
                                hintText: 'Search walks, wadas, peths, or foods...',
                                hintStyle: HeritageWalkTypography.meta(
                                  color: secondaryColor,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: Icon(Icons.search_rounded, size: 20, color: secondaryColor),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.clear_rounded, size: 18, color: secondaryColor),
                                        onPressed: () {
                                          _debounceTimer?.cancel();
                                          _searchController.clear();
                                          ref.read(heritageWalkFilterProvider.notifier).setSearchQuery('');
                                        },
                                      )
                                    : null,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFFD97706), width: 1.5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Semantics(
                            button: true,
                            label: 'Filter heritage walks',
                            child: Tooltip(
                              message: 'Filter heritage walks',
                              child: Material(
                                color: filterState.hasActiveFilters
                                    ? const Color(0xFFD97706)
                                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC)),
                                borderRadius: BorderRadius.circular(14),
                                child: InkWell(
                                  onTap: () => HeritageWalkFilterSheet.show(context),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: filterState.hasActiveFilters
                                            ? const Color(0xFFD97706)
                                            : borderColor,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.tune_rounded,
                                      color: filterState.hasActiveFilters
                                          ? Colors.white
                                          : secondaryColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Category Horizontal Selector
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildCategoryChip(
                              label: 'All Walks',
                              icon: '🏛️',
                              isSelected: filterState.category == null,
                              onTap: () {
                                ref.read(heritageWalkFilterProvider.notifier).setCategory(null);
                              },
                              isDark: isDark,
                              borderColor: borderColor,
                            ),
                            const SizedBox(width: 8),
                            ...HeritageWalkCategory.values.map((cat) {
                              final isSelected = filterState.category == cat;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: _buildCategoryChip(
                                  label: cat.label,
                                  icon: cat.icon,
                                  isSelected: isSelected,
                                  onTap: () {
                                    ref.read(heritageWalkFilterProvider.notifier).setCategory(cat);
                                  },
                                  isDark: isDark,
                                  selectedColor: cat.accentColor,
                                  borderColor: borderColor,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      SizedBox(height: screenWidth < 360 ? 18 : 24),

                      // Sort Bar & Active Count
                      walksAsync.when(
                        data: (walks) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Explore ${walks.length} curated heritage walks',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: HeritageWalkTypography.meta(
                                  color: secondaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<String>(
                              value: filterState.sortBy,
                              underline: const SizedBox.shrink(),
                              isDense: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                              items: const [
                                DropdownMenuItem(value: 'popular', child: Text('Most Popular')),
                                DropdownMenuItem(value: 'shortest', child: Text('Shortest Distance')),
                                DropdownMenuItem(value: 'longest', child: Text('Longest Distance')),
                                DropdownMenuItem(value: 'rating', child: Text('Highest Rated')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  ref.read(heritageWalkFilterProvider.notifier).setSortBy(val);
                                }
                              },
                            ),
                          ],
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      SizedBox(height: screenWidth < 360 ? 10 : 16),
                    ],
                  ),
                ),
              ),

              // 2. Main Walks Grid / List
              // On Mobile: Content-driven SliverList to ensure ZERO forced height and NO blank space.
              // On Tablet/Desktop: 2-3 Column SliverGrid calibrated to content height.
              walksAsync.when(
                data: (walks) {
                  if (walks.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyStateView(
                        icon: '🚶‍♂️',
                        title: 'No Heritage Walks Found',
                        description: 'Try loosening your search filters or resetting duration and category choices.',
                        actionText: 'Reset Filters',
                        onAction: () {
                          _searchController.clear();
                          ref.read(heritageWalkFilterProvider.notifier).resetFilters();
                        },
                      ),
                    );
                  }

                  final columns = Breakpoints.getGridColumnCount(
                    context,
                    mobile: 1,
                    tablet: 2,
                    desktop: 3,
                  );

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: columns,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childCount: walks.length,
                      itemBuilder: (context, index) {
                        return HeritageWalkCard(
                          walk: walks[index],
                          variant: HeritageWalkCardVariant.full,
                        );
                      },
                    ),
                  );
                },
                loading: () {
                  final columns = Breakpoints.getGridColumnCount(
                    context,
                    mobile: 1,
                    tablet: 2,
                    desktop: 3,
                  );
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: columns,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childCount: 6,
                      itemBuilder: (_, __) => const HeritageWalkCardSkeleton(),
                    ),
                  );
                },
                error: (e, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorBoundaryWidget(errorMessage: e.toString()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color borderColor,
    Color? selectedColor,
  }) {
    final activeColor = selectedColor ?? const Color(0xFFD97706);

    return Material(
      color: isSelected
          ? activeColor
          : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC)),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : borderColor,
              width: 0.9,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 12.5)),
              const SizedBox(width: 5),
              Text(
                label,
                style: HeritageWalkTypography.chip(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                  isSelected: isSelected,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
