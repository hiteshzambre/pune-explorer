import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/widgets/omni_search_dialog.dart';

class HomeSearchBar extends ConsumerStatefulWidget {
  const HomeSearchBar({super.key});

  @override
  ConsumerState<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends ConsumerState<HomeSearchBar> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, String>> _popularQueries = [
    {'icon': '🏰', 'text': 'Sinhagad Fort'},
    {'icon': '⛺', 'text': 'Pawna Lake Camping'},
    {'icon': '🕉️', 'text': 'Dagdusheth Ganpati'},
    {'icon': '🌧️', 'text': 'Lonavala & Khandala'},
    {'icon': '🍲', 'text': 'KataKirr Misal'},
    {'icon': '👑', 'text': 'Shaniwar Wada'},
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    final clean = query.trim();
    if (clean.isEmpty) return;
    HapticFeedback.lightImpact();
    ref.read(exploreFilterProvider.notifier).setSearchQuery(clean);
    context.go('/explore');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input Box
        Semantics(
          label: 'Search destinations, forts, and landmarks',
          button: true,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              OmniSearchDialog.show(context);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1.2,
                ),
                boxShadow: AppColors.cardShadow(isDark),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppColors.emerald, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Search forts, lakes, thalis, Darshan...',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                  if (!Breakpoints.isMobile(context))
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.keyboard_command_key_rounded, size: 12, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                          const SizedBox(width: 2),
                          Text('K', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.tune_rounded, size: 16, color: AppColors.emerald),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Quick Suggestion Chips
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _popularQueries.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = _popularQueries[index];
              return InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _controller.text = item['text']!;
                  _submitSearch(item['text']!);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(item['icon']!, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 5),
                      Text(
                        item['text']!,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
