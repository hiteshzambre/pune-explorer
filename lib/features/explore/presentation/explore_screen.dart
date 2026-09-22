import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/widgets/empty_state_view.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'widgets/destination_card.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = Breakpoints.isDesktop(context);
    final filter = ref.watch(exploreFilterProvider);
    final filteredList = ref.watch(filteredDestinationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Pune Destinations'),
        actions: [
          IconButton(
            icon: Icon(filter.isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
            tooltip: filter.isGridView ? 'Switch to List View' : 'Switch to Grid View',
            onPressed: () => ref.read(exploreFilterProvider.notifier).toggleViewMode(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: MaxWidthWrapper(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Desktop Filter Sidebar
            if (isDesktop)
              Container(
                width: 280,
                margin: const EdgeInsets.only(right: 24, top: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: _buildFilterSidebar(context, ref, filter, isDark, theme),
              ),

            // Main Results Content
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Search & Mobile Filter Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Explore Banner with Heritage Gradient & Stats Pills
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                                    : [const Color(0xFF064E3B), const Color(0xFF047857), const Color(0xFF065F46)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.emerald.withValues(alpha: isDark ? 0.3 : 0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                      decoration: BoxDecoration(
                                        color: AppColors.saffron,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        '🚩 PUNE & SAHYADRI',
                                        style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${filteredList.length} Verified Landmarks',
                                        style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Discover Historic Forts, Ghats & Sacred Shrines',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Filter by region, experience, ticket price, or travel distance.',
                                  style: TextStyle(
                                    color: Color(0xFFD1FAE5),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 2. Search Box with Clean Glow & Clear Button
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: filter.searchQuery.isNotEmpty
                                    ? AppColors.emerald
                                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                width: filter.searchQuery.isNotEmpty ? 1.5 : 1.2,
                              ),
                              boxShadow: AppColors.subtleShadow(isDark),
                            ),
                            child: Semantics(
                              label: 'Search destinations',
                              child: _DebouncedSearchTextField(
                                initialQuery: filter.searchQuery,
                                onChanged: (val) => ref.read(exploreFilterProvider.notifier).setSearchQuery(val),
                                onClear: () => ref.read(exploreFilterProvider.notifier).setSearchQuery(''),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 3. Region Filter Chips (Mobile/Tablet)
                          if (!isDesktop) ...[
                            SizedBox(
                              height: MediaQuery.textScalerOf(context).scale(42).clamp(42.0, 56.0),
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: PuneRegion.values.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final region = PuneRegion.values[index];
                                  final isSelected = filter.region == region;

                                  return FilterChip(
                                    label: Text(region.label, style: const TextStyle(fontSize: 12)),
                                    selected: isSelected,
                                    onSelected: (_) {
                                      HapticFeedback.selectionClick();
                                      ref.read(exploreFilterProvider.notifier).setRegion(region);
                                    },
                                    backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                                    selectedColor: isDark ? AppColors.emerald.withValues(alpha: 0.25) : AppColors.emeraldSurface,
                                    checkmarkColor: AppColors.emerald,
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? AppColors.emerald
                                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: isSelected
                                            ? AppColors.emerald
                                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 10),

                            // 4. Category Filter Chips with Rich Gradients (Mobile/Tablet)
                            SizedBox(
                              height: MediaQuery.textScalerOf(context).scale(42).clamp(42.0, 56.0),
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: DestinationCategory.values.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final cat = DestinationCategory.values[index];
                                  final isSelected = filter.category == cat;

                                  return FilterChip(
                                    avatar: Text(cat.icon, style: const TextStyle(fontSize: 14)),
                                    label: Text(cat.label, style: const TextStyle(fontSize: 12)),
                                    selected: isSelected,
                                    onSelected: (_) {
                                      HapticFeedback.selectionClick();
                                      ref.read(exploreFilterProvider.notifier).setCategory(cat);
                                    },
                                    backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                                    selectedColor: cat.color.withValues(alpha: 0.18),
                                    checkmarkColor: cat.color,
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? (isDark ? Colors.white : cat.color)
                                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: isSelected
                                            ? cat.color
                                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],

                          // 5. Active Filters Pill Strip (Responsive Wrap with 1-Tap Dismiss & Clear All)
                          if (filter.region != PuneRegion.all ||
                              filter.category != DestinationCategory.all ||
                              filter.searchQuery.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                ),
                              ),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.filter_list_rounded, size: 14, color: AppColors.emerald),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Active Filters:',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (filter.region != PuneRegion.all)
                                    InputChip(
                                      label: Text(
                                        filter.region.label,
                                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.emerald),
                                      ),
                                      backgroundColor: isDark ? AppColors.emerald.withValues(alpha: 0.25) : AppColors.emeraldSurface,
                                      onDeleted: () {
                                        HapticFeedback.lightImpact();
                                        ref.read(exploreFilterProvider.notifier).setRegion(PuneRegion.all);
                                      },
                                      deleteIconColor: AppColors.emerald,
                                      deleteButtonTooltipMessage: 'Remove ${filter.region.label} filter',
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    ),
                                  if (filter.category != DestinationCategory.all)
                                    InputChip(
                                      avatar: Text(filter.category.icon, style: const TextStyle(fontSize: 12)),
                                      label: Text(
                                        filter.category.label,
                                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: filter.category.color),
                                      ),
                                      backgroundColor: filter.category.color.withValues(alpha: 0.18),
                                      onDeleted: () {
                                        HapticFeedback.lightImpact();
                                        ref.read(exploreFilterProvider.notifier).setCategory(DestinationCategory.all);
                                      },
                                      deleteIconColor: filter.category.color,
                                      deleteButtonTooltipMessage: 'Remove ${filter.category.label} filter',
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    ),
                                  if (filter.searchQuery.isNotEmpty)
                                    InputChip(
                                      label: Text(
                                        '"${filter.searchQuery}"',
                                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.skyBlue),
                                      ),
                                      backgroundColor: isDark ? AppColors.skyBlue.withValues(alpha: 0.25) : AppColors.skySurface,
                                      onDeleted: () {
                                        HapticFeedback.lightImpact();
                                        ref.read(exploreFilterProvider.notifier).setSearchQuery('');
                                      },
                                      deleteIconColor: AppColors.skyBlue,
                                      deleteButtonTooltipMessage: 'Clear search query',
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    ),
                                  TextButton.icon(
                                    onPressed: () {
                                      HapticFeedback.selectionClick();
                                      ref.read(exploreFilterProvider.notifier).resetFilters();
                                    },
                                    icon: const Icon(Icons.close_rounded, size: 14, color: AppColors.error),
                                    label: const Text(
                                      'Clear All',
                                      style: TextStyle(fontSize: 11.5, color: AppColors.error, fontWeight: FontWeight.w800),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      minimumSize: const Size(60, 32),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),

                          // 6. Results Count & Sort Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${filteredList.length} destinations matching criteria',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.royalSlate,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                ),
                                child: DropdownButton<String>(
                                  value: const ['recommended', 'rating', 'price_asc', 'distance'].contains(filter.sortBy) ? filter.sortBy : 'recommended',
                                  underline: const SizedBox.shrink(),
                                  icon: const Icon(Icons.sort_rounded, size: 18, color: AppColors.emerald),
                                  isDense: true,
                                  style: TextStyle(
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                                  items: const [
                                    DropdownMenuItem(value: 'recommended', child: Text('Recommended')),
                                    DropdownMenuItem(value: 'rating', child: Text('Highest Rated')),
                                    DropdownMenuItem(value: 'price_asc', child: Text('Lowest Price')),
                                    DropdownMenuItem(value: 'distance', child: Text('Nearest')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      HapticFeedback.selectionClick();
                                      ref.read(exploreFilterProvider.notifier).setSortBy(val);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Results Grid / List with Animated Staggered Cards
                  if (filteredList.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyStateView(
                        icon: '🔍',
                        title: 'No Destinations Found',
                        description: 'Try adjusting your search query, selecting "All Regions", or resetting your category filters.',
                        actionText: 'Reset All Filters',
                        onAction: () => ref.read(exploreFilterProvider.notifier).resetFilters(),
                      ),
                    )
                  else if (!filter.isGridView)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final dest = filteredList[index];
                          return DestinationCard(
                            destination: dest,
                            isListView: true,
                            index: index,
                          );
                        },
                        childCount: filteredList.length,
                      ),
                    )
                  else
                    SliverMasonryGrid.count(
                      crossAxisCount: Breakpoints.getGridColumnCount(context, mobile: 1, tablet: 2, desktop: 3),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final dest = filteredList[index];
                        return DestinationCard(
                          destination: dest,
                          isListView: false,
                          index: index,
                        );
                      },
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSidebar(
    BuildContext context,
    WidgetRef ref,
    ExploreFilterState filter,
    bool isDark,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Filters', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              ),
              TextButton(
                onPressed: () => ref.read(exploreFilterProvider.notifier).resetFilters(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Reset All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const Divider(height: 20),

          // Region Section
          Text('Region in Pune District', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...PuneRegion.values.map((region) {
            final isSelected = filter.region == region;
            return InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(exploreFilterProvider.notifier).setRegion(region);
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? AppColors.emerald : Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        region.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected ? AppColors.emerald : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const Divider(height: 24),

          // Categories Section
          Text('Category Experiences', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...DestinationCategory.values.map((cat) {
            final isSelected = filter.category == cat;
            return InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(exploreFilterProvider.notifier).setCategory(cat);
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? cat.color : Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(cat.icon, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cat.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected ? (isDark ? Colors.white : cat.color) : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        ),
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
}

/// Lightweight debounced search text field for smooth, stutter-free filtering
class _DebouncedSearchTextField extends StatefulWidget {
  final String initialQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _DebouncedSearchTextField({
    required this.initialQuery,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<_DebouncedSearchTextField> createState() => _DebouncedSearchTextFieldState();
}

class _DebouncedSearchTextFieldState extends State<_DebouncedSearchTextField> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void didUpdateWidget(covariant _DebouncedSearchTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialQuery != oldWidget.initialQuery && widget.initialQuery != _controller.text) {
      _controller.text = widget.initialQuery;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      widget.onChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onTextChanged,
      decoration: InputDecoration(
        hintText: 'Search Sinhagad, Lonavala, Misal, Dagdusheth...',
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.emerald, size: 22),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                onPressed: () {
                  _debounceTimer?.cancel();
                  _controller.clear();
                  widget.onClear();
                  setState(() {});
                },
              )
            : null,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
