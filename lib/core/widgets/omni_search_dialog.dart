import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../providers/app_providers.dart';
import '../../data/models/destination.dart';
import '../../data/models/tour_package.dart';
import '../../data/models/heritage_walk.dart';
import '../responsive/breakpoints.dart';
import 'app_network_image.dart';

class OmniSearchDialog extends ConsumerStatefulWidget {
  const OmniSearchDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => const OmniSearchDialog(),
    );
  }

  @override
  ConsumerState<OmniSearchDialog> createState() => _OmniSearchDialogState();
}

class _OmniSearchDialogState extends ConsumerState<OmniSearchDialog> {
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _activeCategory = 'All';
  Timer? _debounce;
  String _query = '';

  static const List<Map<String, String>> _popularSearches = [
    {'icon': '🏰', 'query': 'Sinhagad Fort', 'tag': 'Fort Trek'},
    {'icon': '🛕', 'query': 'Dagdusheth Ganpati', 'tag': 'VIP Darshan'},
    {'icon': '⛺', 'query': 'Pawna Lake Camping', 'tag': 'Night Camp'},
    {'icon': '🌧️', 'query': 'Lonavala & Khandala', 'tag': 'Ghats & Falls'},
    {'icon': '🍲', 'query': 'KataKirr Misal', 'tag': 'Puneri Food'},
    {'icon': '👑', 'query': 'Shaniwar Wada', 'tag': 'Peshwa Heritage'},
    {'icon': '🚌', 'query': 'Pune Darshan Bus', 'tag': 'Daily AC Tour'},
    {'icon': '🏞️', 'query': 'Tamhini Ghat', 'tag': 'Monsoon Scenic'},
  ];

  final List<Map<String, dynamic>> _quickShortcuts = [
    {
      'icon': '🚌',
      'title': 'Official Pune Darshan Bus',
      'subtitle': 'Daily AC Coach with live guide & temple passes',
      'route': '/darshan',
      'color': AppColors.emerald,
    },
    {
      'icon': '🧭',
      'title': 'Multi-Day Itinerary Planner',
      'subtitle': 'Build custom schedules with draggable stops',
      'route': '/itinerary',
      'color': AppColors.saffron,
    },
    {
      'icon': '💰',
      'title': 'Smart Trip Budget Calculator',
      'subtitle': 'Estimate fuel, dining, stay & ticket costs',
      'route': '/budget',
      'color': const Color(0xFFD97706),
    },
    {
      'icon': '🛣️',
      'title': 'Sahyadri Heritage Circuits',
      'subtitle': 'Curated 1-day & weekend road trips',
      'route': '/routes',
      'color': const Color(0xFF0D9488),
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _query = val.trim());
    });
  }

  void _applySearchQuery(String text) {
    _queryController.text = text;
    _queryController.selection = TextSelection.fromPosition(TextPosition(offset: text.length));
    setState(() => _query = text.trim());
  }

  bool _matchesQuery(String source, String query) {
    if (query.isEmpty) return true;
    final cleanSource = source.toLowerCase();
    final tokens = query.toLowerCase().split(' ').where((t) => t.isNotEmpty);
    return tokens.every((token) => cleanSource.contains(token));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final destinations = ref.watch(destinationsAsyncProvider).value ?? [];
    final packages = ref.watch(tourPackagesAsyncProvider).value ?? [];
    final walks = ref.watch(heritageWalksAsyncProvider).value ?? [];
    final recentSearches = ref.watch(recentSearchesProvider);

    // Enhanced Multi-Field Search Matching
    final filteredDestinations = destinations.where((d) {
      final combined = '${d.name} ${d.city} ${d.description} ${d.longDescription} ${d.famousFor} ${d.category.label} ${d.bestTime}';
      final matchesQuery = _matchesQuery(combined, _query);
      final matchesCat = _activeCategory == 'All' ||
          d.category.label.toLowerCase().contains(_activeCategory.toLowerCase()) ||
          (_activeCategory == 'Forts' && d.category.label.contains('Fort')) ||
          (_activeCategory == 'Temples' && (d.category.label.contains('Spiritual') || d.category.label.contains('Temple'))) ||
          (_activeCategory == 'Nature' && (d.category.label.contains('Lakes') || d.category.label.contains('Ghats') || d.category.label.contains('Hill')));
      return matchesQuery && matchesCat;
    }).toList();

    final filteredPackages = packages.where((p) {
      final combined = '${p.title} ${p.subtitle} ${p.category} ${p.highlights.join(" ")} ${p.inclusions.join(" ")}';
      final matchesQuery = _matchesQuery(combined, _query);
      final matchesCat = _activeCategory == 'All' || _activeCategory == 'Tours';
      return matchesQuery && matchesCat;
    }).toList();

    final filteredWalks = walks.where((w) {
      final combined = '${w.title} ${w.marathiTitle} ${w.subtitle} ${w.description} ${w.category.label} ${w.highlights.join(" ")} ${w.stops.map((s) => s.name).join(" ")}';
      final matchesQuery = _matchesQuery(combined, _query);
      final matchesCat = _activeCategory == 'All' || _activeCategory == 'Walks';
      return matchesQuery && matchesCat;
    }).toList();

    final totalResults = filteredDestinations.length + filteredPackages.length + filteredWalks.length;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: Breakpoints.isSmallPhone(context) ? 10 : 16,
        vertical: 24,
      ),
      child: Center(
        child: Container(
          width: 720,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.88,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.22),
                blurRadius: 36,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search Input Header with Integrated Clear & Close Actions (No ESC badge)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.search_rounded, color: AppColors.emerald, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _queryController,
                        focusNode: _focusNode,
                        onChanged: _onQueryChanged,
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            ref.read(recentSearchesProvider.notifier).add(val.trim());
                            if (filteredDestinations.isNotEmpty) {
                              Navigator.of(context).pop();
                              context.push('/destination/${filteredDestinations.first.id}');
                            } else if (filteredPackages.isNotEmpty) {
                              Navigator.of(context).pop();
                              context.push('/booking/${filteredPackages.first.id}');
                            }
                          }
                        },
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search forts, temples, lakes, tours, thalis, routes...',
                          hintStyle: TextStyle(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 6),
                        ),
                      ),
                    ),
                    if (_queryController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.cancel_rounded, size: 20, color: Colors.grey),
                        tooltip: 'Clear search',
                        onPressed: () {
                          _queryController.clear();
                          _onQueryChanged('');
                        },
                      ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close_rounded, size: 18, color: isDark ? Colors.white70 : Colors.black87),
                      ),
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Filter Category Chips Strip
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant.withValues(alpha: 0.3) : AppColors.lightSurfaceVariant.withValues(alpha: 0.4),
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1,
                    ),
                  ),
                ),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('All', isDark, null),
                    _buildFilterChip('Forts', isDark, '🏰'),
                    _buildFilterChip('Temples', isDark, '🛕'),
                    _buildFilterChip('Nature', isDark, '⛺'),
                    _buildFilterChip('Tours', isDark, '🚌'),
                    _buildFilterChip('Walks', isDark, '🏛️'),
                  ],
                ),
              ),

              // Main Content: Discovery Panel vs Filtered Search Results
              Flexible(
                child: _query.isEmpty
                    ? _buildDiscoveryView(recentSearches, isDark, theme)
                    : _buildSearchResults(
                        filteredDestinations,
                        filteredPackages,
                        filteredWalks,
                        totalResults,
                        isDark,
                        theme,
                      ),
              ),

              // Bottom Stats & Branding Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5) : AppColors.lightSurfaceVariant,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _query.isEmpty
                          ? '🌟 Explore Pune & Sahyadri Heritage'
                          : '$totalResults results matching "$_query"',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _query.isNotEmpty ? AppColors.emerald : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.bolt_rounded, size: 14, color: AppColors.saffron),
                        const SizedBox(width: 4),
                        Text(
                          'PuneExplorer OmniSearch',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
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

  Widget _buildFilterChip(String label, bool isDark, String? icon) {
    final isSelected = _activeCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        avatar: icon != null ? Text(icon, style: const TextStyle(fontSize: 12)) : null,
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: isSelected,
        onSelected: (_) {
          HapticFeedback.selectionClick();
          setState(() => _activeCategory = label);
        },
        selectedColor: AppColors.emerald.withValues(alpha: 0.2),
        backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
        side: BorderSide(
          color: isSelected ? AppColors.emerald : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isSelected ? 1.4 : 1,
        ),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.emerald : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
    );
  }

  Widget _buildDiscoveryView(List<String> recent, bool isDark, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      children: [
        // Recent Searches Strip (if any)
        if (recent.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.history_rounded, size: 16, color: AppColors.emerald),
                  SizedBox(width: 6),
                  Text('Recent Searches', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.grey)),
                ],
              ),
              TextButton(
                onPressed: () => ref.read(recentSearchesProvider.notifier).clear(),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                child: const Text('Clear All', style: TextStyle(fontSize: 11.5, color: AppColors.error, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recent.map((term) {
              return ActionChip(
                avatar: const Icon(Icons.north_west_rounded, size: 12, color: AppColors.emerald),
                label: Text(term, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onPressed: () => _applySearchQuery(term),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
        ],

        // Trending in Pune
        const Row(
          children: [
            Text('🔥', style: TextStyle(fontSize: 15)),
            SizedBox(width: 6),
            Text('Trending in Pune & Sahyadri', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularSearches.map((item) {
            return InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                _applySearchQuery(item['query']!);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item['icon']!, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      item['query']!,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item['tag']!,
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.emerald),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 18),
        const Divider(height: 1),
        const SizedBox(height: 16),

        // Quick Travel Shortcuts
        const Row(
          children: [
            Icon(Icons.near_me_rounded, size: 16, color: AppColors.saffron),
            SizedBox(width: 6),
            Text('Quick Travel Hub Shortcuts', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 440;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isCompact ? 1 : 2,
                mainAxisExtent: isCompact ? 60 : 68,
                crossAxisSpacing: 10,
                mainAxisSpacing: 8,
              ),
              itemCount: _quickShortcuts.length,
              itemBuilder: (context, idx) {
                final s = _quickShortcuts[idx];
                return InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push(s['route'] as String);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: (s['color'] as Color).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(s['icon'] as String, style: const TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                s['title'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                s['subtitle'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchResults(
    List<Destination> destinations,
    List<TourPackage> packages,
    List<HeritageWalk> walks,
    int totalCount,
    bool isDark,
    ThemeData theme,
  ) {
    if (totalCount == 0) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.saffron.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Text('🔍', style: TextStyle(fontSize: 36)),
            ),
            const SizedBox(height: 14),
            Text('No results matching "$_query"', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 6),
            const Text('Try searching by category, fort name, or Puneri food items.', style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ActionChip(
                  label: const Text('Sinhagad Fort'),
                  onPressed: () => _applySearchQuery('Sinhagad'),
                ),
                ActionChip(
                  label: const Text('Pune Darshan Bus'),
                  onPressed: () => _applySearchQuery('Darshan'),
                ),
                ActionChip(
                  label: const Text('Pawna Camping'),
                  onPressed: () => _applySearchQuery('Pawna'),
                ),
                ActionChip(
                  label: const Text('Lonavala Ghats'),
                  onPressed: () => _applySearchQuery('Lonavala'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      shrinkWrap: true,
      children: [
        // Landmarks Section
        if (destinations.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LANDMARKS & DESTINATIONS (${destinations.length})',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.emerald, letterSpacing: 0.6),
                ),
              ],
            ),
          ),
          ...destinations.map((dest) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AppCardImage(
                  imageUrl: dest.primaryImage,
                  width: 52,
                  height: 52,
                  categoryIcon: dest.category.icon,
                  categoryLabel: dest.category.label,
                  title: dest.name,
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      dest.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.amber, size: 13),
                        const SizedBox(width: 2),
                        Text(dest.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.emerald)),
                      ],
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Text(
                  '${dest.category.icon} ${dest.category.label} • ${dest.distanceFromPuneKm.toInt()} km from Pune • ${dest.entryFeeIndian > 0 ? "Entry ₹${dest.entryFeeIndian.toInt()}" : "Free Entry"}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
              onTap: () {
                ref.read(recentSearchesProvider.notifier).add(dest.name);
                Navigator.of(context).pop();
                context.push('/destination/${dest.id}');
              },
            );
          }),
        ],

        // Tour Packages Section
        if (packages.isNotEmpty) ...[
          const Divider(height: 18),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: Text(
              'GUIDED TOUR PACKAGES (${packages.length})',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.saffron, letterSpacing: 0.6),
            ),
          ),
          ...packages.map((pkg) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AppCardImage(
                  imageUrl: pkg.primaryImage,
                  width: 52,
                  height: 52,
                  categoryIcon: '🚌',
                  categoryLabel: pkg.category,
                  title: pkg.title,
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      pkg.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.saffron.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '₹${pkg.price.toInt()}',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: AppColors.saffron),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Text(
                  '🚌 ${pkg.duration} • Pickup: ${pkg.pickupPoints.firstOrNull ?? "Swargate"}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
              onTap: () {
                ref.read(recentSearchesProvider.notifier).add(pkg.title);
                Navigator.of(context).pop();
                context.push('/booking/${pkg.id}');
              },
            );
          }),
        ],

        // Heritage Walks Section
        if (walks.isNotEmpty) ...[
          const Divider(height: 18),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: Text(
              'HERITAGE WALKS & CULTURAL TRAILS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.saffron, letterSpacing: 0.6),
            ),
          ),
          ...walks.map((walk) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: walk.category.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(walk.category.icon, style: const TextStyle(fontSize: 24)),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      walk.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                  if (walk.isFree)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('FREE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.emerald)),
                    ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Text(
                  '${walk.marathiTitle.isNotEmpty ? "${walk.marathiTitle} • " : ""}${walk.durationFormatted} • ${walk.distanceKm} km • ${walk.stopsCount} stops',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
              onTap: () {
                ref.read(recentSearchesProvider.notifier).add(walk.title);
                Navigator.of(context).pop();
                context.push('/walk/${walk.id}');
              },
            );
          }),
        ],
      ],
    );
  }
}
