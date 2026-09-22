import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/models/heritage_walk.dart';

class HeritageWalkFilterSheet extends ConsumerStatefulWidget {
  const HeritageWalkFilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const HeritageWalkFilterSheet(),
    );
  }

  @override
  ConsumerState<HeritageWalkFilterSheet> createState() => _HeritageWalkFilterSheetState();
}

class _HeritageWalkFilterSheetState extends ConsumerState<HeritageWalkFilterSheet> {
  late HeritageWalkCategory? _category;
  late WalkDifficulty? _difficulty;
  late int? _maxDurationMinutes;
  late WalkTimeOfDay? _timeOfDay;
  late bool? _isFreeOnly;
  late String _sortBy;

  @override
  void initState() {
    super.initState();
    final current = ref.read(heritageWalkFilterProvider);
    _category = current.category;
    _difficulty = current.difficulty;
    _maxDurationMinutes = current.maxDurationMinutes;
    _timeOfDay = current.timeOfDay;
    _isFreeOnly = current.isFreeOnly;
    _sortBy = current.sortBy;
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() {
      _category = null;
      _difficulty = null;
      _maxDurationMinutes = null;
      _timeOfDay = null;
      _isFreeOnly = null;
      _sortBy = 'popular';
    });
  }

  void _apply() {
    HapticFeedback.mediumImpact();
    final notifier = ref.read(heritageWalkFilterProvider.notifier);
    final current = ref.read(heritageWalkFilterProvider);

    // Apply all
    if (current.category != _category) notifier.setCategory(_category);
    if (current.difficulty != _difficulty) notifier.setDifficulty(_difficulty);
    if (current.maxDurationMinutes != _maxDurationMinutes) notifier.setMaxDuration(_maxDurationMinutes);
    if (current.timeOfDay != _timeOfDay) notifier.setTimeOfDay(_timeOfDay);
    if (current.isFreeOnly != _isFreeOnly) {
      if (_isFreeOnly == true) {
        notifier.toggleFreeOnly();
      } else if (current.isFreeOnly == true) {
        notifier.toggleFreeOnly();
      }
    }
    if (current.sortBy != _sortBy) notifier.setSortBy(_sortBy);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.saffron.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('🧭', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filter Heritage Walks',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          'Custom walking paces, categories & durations',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _reset,
                    child: const Text('Reset All', style: TextStyle(color: AppColors.saffron, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),

            // Scrollable Options
            Flexible(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  // 1. Categories
                  _buildSectionTitle('WALK THEMES & CATEGORIES', isDark),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(
                        label: 'All Themes',
                        isSelected: _category == null,
                        onTap: () => setState(() => _category = null),
                        isDark: isDark,
                      ),
                      ...HeritageWalkCategory.values.map((cat) {
                        final isSelected = _category == cat;
                        return _buildChip(
                          label: '${cat.icon} ${cat.label}',
                          isSelected: isSelected,
                          onTap: () => setState(() => _category = isSelected ? null : cat),
                          isDark: isDark,
                          selectedColor: cat.accentColor,
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // 2. Walk Difficulty
                  _buildSectionTitle('WALKING PACE & TERRAIN', isDark),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(
                        label: 'Any Difficulty',
                        isSelected: _difficulty == null,
                        onTap: () => setState(() => _difficulty = null),
                        isDark: isDark,
                      ),
                      ...WalkDifficulty.values.map((diff) {
                        final isSelected = _difficulty == diff;
                        return _buildChip(
                          label: diff.label,
                          isSelected: isSelected,
                          onTap: () => setState(() => _difficulty = isSelected ? null : diff),
                          isDark: isDark,
                          selectedColor: diff.color,
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // 3. Max Duration
                  _buildSectionTitle('MAXIMUM DURATION', isDark),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(
                        label: 'Any Duration',
                        isSelected: _maxDurationMinutes == null,
                        onTap: () => setState(() => _maxDurationMinutes = null),
                        isDark: isDark,
                      ),
                      _buildChip(
                        label: '⚡ Under 1.5 hrs (90m)',
                        isSelected: _maxDurationMinutes == 90,
                        onTap: () => setState(() => _maxDurationMinutes = _maxDurationMinutes == 90 ? null : 90),
                        isDark: isDark,
                      ),
                      _buildChip(
                        label: '⏳ Under 2 hrs (120m)',
                        isSelected: _maxDurationMinutes == 120,
                        onTap: () => setState(() => _maxDurationMinutes = _maxDurationMinutes == 120 ? null : 120),
                        isDark: isDark,
                      ),
                      _buildChip(
                        label: '🏛️ Under 2.5 hrs (150m)',
                        isSelected: _maxDurationMinutes == 150,
                        onTap: () => setState(() => _maxDurationMinutes = _maxDurationMinutes == 150 ? null : 150),
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // 4. Time of Day
                  _buildSectionTitle('PREFERRED TIME OF DAY', isDark),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(
                        label: 'Anytime',
                        isSelected: _timeOfDay == null,
                        onTap: () => setState(() => _timeOfDay = null),
                        isDark: isDark,
                      ),
                      _buildChip(
                        label: '🌅 Morning (6:30–9:30 AM)',
                        isSelected: _timeOfDay == WalkTimeOfDay.morning,
                        onTap: () => setState(() => _timeOfDay = _timeOfDay == WalkTimeOfDay.morning ? null : WalkTimeOfDay.morning),
                        isDark: isDark,
                        selectedColor: AppColors.saffron,
                      ),
                      _buildChip(
                        label: '🌇 Evening (4:30–7:30 PM)',
                        isSelected: _timeOfDay == WalkTimeOfDay.evening,
                        onTap: () => setState(() => _timeOfDay = _timeOfDay == WalkTimeOfDay.evening ? null : WalkTimeOfDay.evening),
                        isDark: isDark,
                        selectedColor: const Color(0xFF8B5CF6),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // 5. Access Type (Free vs Paid Guide)
                  _buildSectionTitle('PRICE & TOUR FORMAT', isDark),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(
                        label: 'All Walks (Free & Historian Led)',
                        isSelected: _isFreeOnly == null,
                        onTap: () => setState(() => _isFreeOnly = null),
                        isDark: isDark,
                      ),
                      _buildChip(
                        label: '🎁 Free Self-Guided Only',
                        isSelected: _isFreeOnly == true,
                        onTap: () => setState(() => _isFreeOnly = _isFreeOnly == true ? null : true),
                        isDark: isDark,
                        selectedColor: AppColors.emerald,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Bottom CTA
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.saffron,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.8,
        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    Color? selectedColor,
  }) {
    final activeColor = selectedColor ?? AppColors.saffron;

    return Material(
      color: isSelected
          ? activeColor.withValues(alpha: 0.18)
          : isDark
              ? AppColors.darkSurfaceVariant
              : AppColors.lightSurfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? activeColor : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? activeColor
                  : isDark
                      ? Colors.white
                      : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
