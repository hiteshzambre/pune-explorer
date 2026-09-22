import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../data/models/history_milestone.dart';

/// Sorting criteria for historical timeline milestones.
enum HistorySortOrder {
  oldestFirst,
  newestFirst,
}

/// A premium, content-driven History Timeline / Heritage Chronicles section
/// displaying Pune's rich 400-year history with authentic milestones,
/// high-definition imagery, period badges, quotes, tags, and interactive sorting.
class HistoryTimelineSection extends StatefulWidget {
  const HistoryTimelineSection({super.key});

  @override
  State<HistoryTimelineSection> createState() => _HistoryTimelineSectionState();
}

class _HistoryTimelineSectionState extends State<HistoryTimelineSection> {
  HistorySortOrder _sortOrder = HistorySortOrder.oldestFirst;

  List<HistoryMilestone> get _sortedMilestones {
    final list = List<HistoryMilestone>.from(HistoryMilestone.defaultMilestones);
    if (_sortOrder == HistorySortOrder.newestFirst) {
      list.sort((a, b) => b.startYear.compareTo(a.startYear));
    } else {
      list.sort((a, b) => a.startYear.compareTo(b.startYear));
    }
    return list;
  }

  void _showMilestoneDetails(BuildContext context, HistoryMilestone milestone) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _HistoryDetailsSheet(milestone: milestone, isDark: isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 640;
        final isTablet = screenWidth >= 640 && screenWidth < 1000;
        final isDesktop = screenWidth >= 1000;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Heritage Header
            _buildHeader(context, isDark, isDesktop),
            const SizedBox(height: 24),

            // 2. Timeline Track with Milestones
            _buildTimelineList(context, isDark, isMobile, isTablet, isDesktop),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, bool isDesktop) {
    final theme = Theme.of(context);

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.saffron.withValues(alpha: 0.2)
                : const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.saffron.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: const Text(
            '🚩 HERITAGE CHRONICLES',
            style: TextStyle(
              color: AppColors.saffron,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Section Title
        Text(
          'Four Centuries of Puneri Glory',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),

        // Subtitle
        Text(
          'A journey through the people, battles, movements and milestones that shaped modern Pune.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            height: 1.45,
          ),
        ),
      ],
    );

    final controlsBlock = Wrap(
      spacing: 12,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Skyline Calligraphy Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.emerald.withValues(alpha: 0.12)
                : const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.emerald.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/pune_heritage_skyline.png',
                width: 28,
                height: 18,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.location_city_rounded,
                  size: 16,
                  color: AppColors.emerald,
                ),
              ),
              const SizedBox(width: 6),
              const Flexible(
                child: Text(
                  'History Lives Here.',
                  style: TextStyle(
                    color: AppColors.emerald,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Sort Dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<HistorySortOrder>(
              value: _sortOrder,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
              elevation: 4,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(10),
              onChanged: (HistorySortOrder? newValue) {
                if (newValue != null) {
                  setState(() {
                    _sortOrder = newValue;
                  });
                }
              },
              items: const [
                DropdownMenuItem(
                  value: HistorySortOrder.oldestFirst,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sort_rounded, size: 14, color: AppColors.emerald),
                      SizedBox(width: 6),
                      Text('Oldest First'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: HistorySortOrder.newestFirst,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sort_rounded, size: 14, color: AppColors.saffron),
                      SizedBox(width: 6),
                      Text('Newest First'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (!isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleBlock,
          const SizedBox(height: 14),
          controlsBlock,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: titleBlock),
        const SizedBox(width: 20),
        controlsBlock,
      ],
    );
  }

  Widget _buildTimelineList(
    BuildContext context,
    bool isDark,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    final milestones = _sortedMilestones;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: milestones.length,
      itemBuilder: (context, index) {
        final milestone = milestones[index];
        final isLast = index == milestones.length - 1;

        if (isMobile) {
          return _buildMobileTimelineRow(
            context,
            milestone: milestone,
            isDark: isDark,
            isLast: isLast,
          );
        }

        return _buildDesktopTimelineRow(
          context,
          milestone: milestone,
          isDark: isDark,
          isTablet: isTablet,
          isDesktop: isDesktop,
          isLast: isLast,
        );
      },
    );
  }

  /// Mobile layout: Left continuous line, node dot, period pill & card stacked.
  Widget _buildMobileTimelineRow(
    BuildContext context, {
    required HistoryMilestone milestone,
    required bool isDark,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Continuous vertical line & node
          SizedBox(
            width: 28,
            child: Column(
              children: [
                const SizedBox(height: 6),
                // Colored Node Indicator
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: milestone.accentColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.darkBackground : Colors.white,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: milestone.accentColor.withValues(alpha: 0.45),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                // Connecting vertical line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isDark
                          ? AppColors.darkBorder
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Milestone Card Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Badge
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: milestone.accentColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: milestone.accentColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      milestone.period,
                      style: TextStyle(
                        color: milestone.accentColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                      ),
                    ),
                  ),

                  // Card
                  _buildMilestoneCard(
                    context,
                    milestone: milestone,
                    isDark: isDark,
                    isMobile: true,
                    isTablet: false,
                    isDesktop: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Desktop / Tablet layout: Period badge on left, vertical track, card on right.
  Widget _buildDesktopTimelineRow(
    BuildContext context, {
    required HistoryMilestone milestone,
    required bool isDark,
    required bool isTablet,
    required bool isDesktop,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Period Badge
          SizedBox(
            width: isDesktop ? 120 : 100,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: milestone.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: milestone.accentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    milestone.period,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: milestone.accentColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Central Timeline Track & Node
          SizedBox(
            width: 24,
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Circular Node
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: milestone.accentColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: milestone.accentColor.withValues(alpha: 0.45),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                // Continuous vertical line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isDark
                          ? AppColors.darkBorder
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Milestone Card (Content-driven dynamic height)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
              child: _buildMilestoneCard(
                context,
                milestone: milestone,
                isDark: isDark,
                isMobile: false,
                isTablet: isTablet,
                isDesktop: isDesktop,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Core milestone card with responsive 3-part layout (zero fixed heights).
  Widget _buildMilestoneCard(
    BuildContext context, {
    required HistoryMilestone milestone,
    required bool isDark,
    required bool isMobile,
    required bool isTablet,
    required bool isDesktop,
  }) {
    return InkWell(
      onTap: () => _showMilestoneDetails(context, milestone),
      borderRadius: BorderRadius.circular(16),
      hoverColor: milestone.accentColor.withValues(alpha: 0.03),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: isDesktop
            ? _buildDesktopCardContent(context, milestone, isDark)
            : isTablet
                ? _buildTabletCardContent(context, milestone, isDark)
                : _buildMobileCardContent(context, milestone, isDark),
      ),
    );
  }

  /// 3-part Desktop Card: [180px Image] + [Expanded Content] + [220px Quote Panel]
  Widget _buildDesktopCardContent(
    BuildContext context,
    HistoryMilestone milestone,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Left Visual Asset (180px)
          SizedBox(
            width: 180,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  milestone.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          milestone.accentColor.withValues(alpha: 0.25),
                          milestone.accentColor.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        milestone.iconData,
                        size: 36,
                        color: milestone.accentColor,
                      ),
                    ),
                  ),
                ),
                // Subtle gradient overlay for contrast
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.35),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Central Content Block
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title with Category Emoji
                  Row(
                    children: [
                      Text(
                        milestone.categoryEmoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          milestone.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Rich Description
                  Text(
                    milestone.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      height: 1.45,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tag Chips Row
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: milestone.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightSurfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // 3. Right Quote & Watermark Panel (220px)
          Container(
            width: 220,
            decoration: BoxDecoration(
              color: milestone.accentColor.withValues(alpha: isDark ? 0.06 : 0.035),
              border: Border(
                left: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Watermark Silhouette
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Icon(
                    milestone.watermarkIcon,
                    size: 84,
                    color: milestone.accentColor.withValues(
                      alpha: isDark ? 0.08 : 0.06,
                    ),
                  ),
                ),

                // Quote Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.format_quote_rounded,
                            size: 20,
                            color: milestone.accentColor,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            milestone.quote,
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                      // Chevron Button
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: milestone.accentColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: milestone.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tablet Card: Horizontal Image + Content with bottom integrated quote strip
  Widget _buildTabletCardContent(
    BuildContext context,
    HistoryMilestone milestone,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Image (140px)
            SizedBox(
              width: 140,
              height: 110,
              child: Image.asset(
                milestone.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: milestone.accentColor.withValues(alpha: 0.15),
                  child: Icon(milestone.iconData, color: milestone.accentColor),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(milestone.categoryEmoji, style: const TextStyle(fontSize: 15)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            milestone.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      milestone.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: milestone.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Bottom Quote Strip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: milestone.accentColor.withValues(alpha: isDark ? 0.08 : 0.04),
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              left: BorderSide(color: milestone.accentColor, width: 3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  milestone.quote,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: milestone.accentColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Mobile Card: Stacked card with top banner image & bottom quote banner
  Widget _buildMobileCardContent(
    BuildContext context,
    HistoryMilestone milestone,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top 16:9 Image
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                milestone.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: milestone.accentColor.withValues(alpha: 0.15),
                  child: Center(
                    child: Icon(milestone.iconData, size: 36, color: milestone.accentColor),
                  ),
                ),
              ),
              // Gradient for overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.4),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Text Content
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(milestone.categoryEmoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      milestone.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                milestone.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 10),

              // Tags
              Wrap(
                spacing: 5,
                runSpacing: 4,
                children: milestone.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        // Quote Pill Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: milestone.accentColor.withValues(alpha: isDark ? 0.09 : 0.05),
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              left: BorderSide(color: milestone.accentColor, width: 3.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  milestone.quote,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.5,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: milestone.accentColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Interactive modal sheet displaying in-depth chronicle details when a card is tapped.
class _HistoryDetailsSheet extends StatelessWidget {
  final HistoryMilestone milestone;
  final bool isDark;

  const _HistoryDetailsSheet({
    required this.milestone,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Scrollable Body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.asset(
                        milestone.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: milestone.accentColor.withValues(alpha: 0.15),
                          child: Icon(milestone.iconData, size: 48, color: milestone.accentColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Period & Category Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: milestone.accentColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          milestone.period,
                          style: TextStyle(
                            color: milestone.accentColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        milestone.categoryEmoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Title
                  Text(
                    milestone.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    milestone.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quote Callout
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: milestone.accentColor.withValues(alpha: isDark ? 0.1 : 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: milestone.accentColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.format_quote_rounded, color: milestone.accentColor, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            milestone.quote,
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: milestone.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      if (milestone.routePath != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              context.push(milestone.routePath!);
                            },
                            icon: const Icon(Icons.explore_rounded, size: 18),
                            label: const Text('Explore Destination'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: milestone.accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      if (milestone.routePath != null) const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
