import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../data/models/heritage_walk.dart';
import '../theme/heritage_walk_typography.dart';

/// Variant modes for HeritageWalkCard presentation
enum HeritageWalkCardVariant {
  full,    // Full editorial card for dedicated screens & grids
  compact, // Space-efficient card for carousels & previews
}

/// Premium, Content-Driven Card for discovering Pune Heritage Walks.
/// Naturally hugs its content with zero forced empty height or awkward blank margins.
class HeritageWalkCard extends ConsumerStatefulWidget {
  final HeritageWalk walk;
  final HeritageWalkCardVariant variant;

  const HeritageWalkCard({
    super.key,
    required this.walk,
    this.variant = HeritageWalkCardVariant.full,
  });

  @override
  ConsumerState<HeritageWalkCard> createState() => _HeritageWalkCardState();
}

class _HeritageWalkCardState extends ConsumerState<HeritageWalkCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final walk = widget.walk;
    final isCompact = widget.variant == HeritageWalkCardVariant.compact;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFav = ref.watch(favoritesProvider.select((set) => set.contains(walk.id)));

    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    final imageHeight = isCompact ? 118.0 : 148.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: walk.isFeatured
              ? const Color(0xFFF59E0B).withValues(alpha: 0.35)
              : borderColor,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : (_isHovered ? 0.09 : 0.04)),
            blurRadius: _isHovered ? 18 : 10,
            offset: Offset(0, _isHovered ? 6 : 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            context.push('/walk/${walk.id}');
          },
          onHover: (hovering) {
            if (_isHovered != hovering) {
              setState(() => _isHovered = hovering);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. High-Res Heritage Image with De-cluttered Badges
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: AppCardImage(
                      imageUrl: walk.coverImage,
                      height: imageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      categoryIcon: walk.category.icon,
                      categoryLabel: walk.category.label,
                      title: walk.title,
                    ),
                  ),

                  // Top Vignette for Badge Legibility
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 55,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.55),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Top-Left Badges: Category Capsule & ★ Featured
                  Positioned(
                    top: 9,
                    left: 9,
                    right: 52,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Category Capsule
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            '${walk.category.icon} ${walk.category.label}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        // Subtle ★ Featured Capsule (Only when featured)
                        if (walk.isFeatured) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '★',
                                  style: TextStyle(
                                    color: Color(0xFFB45309),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'Featured',
                                  style: TextStyle(
                                    color: Color(0xFF92400E),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Top-Right Favorite Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.42),
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          ref.read(favoritesProvider.notifier).toggle(walk.id);
                        },
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(6.5),
                          child: AnimatedScale(
                            scale: isFav ? 1.15 : 1.0,
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutBack,
                            child: Icon(
                              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isFav ? const Color(0xFFEF4444) : Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // 2. Card Content Body
              Padding(
                padding: EdgeInsets.fromLTRB(isCompact ? 11 : 14, isCompact ? 8 : 10, isCompact ? 11 : 14, isCompact ? 8 : 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Rating Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                walk.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: HeritageWalkTypography.cardTitle(
                                  color: textColor,
                                  fontSize: isCompact ? 14.5 : 16,
                                ),
                              ),
                              if (walk.marathiTitle.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  walk.marathiTitle,
                                  maxLines: isCompact ? 1 : 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: HeritageWalkTypography.marathiSubtitle(
                                    color: isDark ? const Color(0xFFFDBA74) : const Color(0xFFB45309),
                                    fontSize: isCompact ? 11 : 11.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (walk.rating > 0) ...[
                          const SizedBox(width: 8),
                          // Rating Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, size: 13, color: Color(0xFFD97706)),
                                const SizedBox(width: 2.5),
                                Text(
                                  walk.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (walk.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      // Travel Narrative Hook / Teaser
                      Text(
                        walk.subtitle,
                        maxLines: isCompact ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                        style: HeritageWalkTypography.cardDescription(
                          color: secondaryTextColor,
                          fontSize: isCompact ? 11.5 : 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 7),

                    // 4-Point Metadata Row (Below Image)
                    Wrap(
                      spacing: 6,
                      runSpacing: 5,
                      children: [
                        if (walk.durationMinutes > 0)
                          _buildMetaChip(
                            icon: Icons.timer_outlined,
                            label: walk.durationFormatted,
                            isDark: isDark,
                          ),
                        if (walk.distanceKm > 0)
                          _buildMetaChip(
                            icon: Icons.directions_walk_rounded,
                            label: '${walk.distanceKm} km',
                            isDark: isDark,
                          ),
                        _buildMetaChip(
                          icon: Icons.speed_rounded,
                          label: walk.difficulty.label,
                          isDark: isDark,
                          accentColor: walk.difficulty.color,
                        ),
                        if (walk.stopsCount > 0)
                          _buildMetaChip(
                            icon: Icons.location_on_outlined,
                            label: '${walk.stopsCount} stops',
                            isDark: isDark,
                          ),
                      ],
                    ),

                    const SizedBox(height: 9),

                    // Subtle Divider
                    Divider(height: 1, color: borderColor),
                    const SizedBox(height: 8),

                    // Bottom Bar: Price & CTA
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        // Price Column
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              walk.isFree ? 'FREE' : '₹${walk.price.toInt()} / person',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: HeritageWalkTypography.price(
                                color: walk.isFree ? AppColors.emerald : const Color(0xFFD97706),
                                fontSize: isCompact ? 14 : 15,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              walk.isFree ? 'Free • Self-guided' : 'Historian-led',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: HeritageWalkTypography.priceLabel(
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),

                        // Explore Button
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: isCompact ? 9 : 11, vertical: isCompact ? 5.5 : 6.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD97706).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFD97706).withValues(alpha: 0.28),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Explore Walk',
                                style: HeritageWalkTypography.button(
                                  color: const Color(0xFFD97706),
                                  fontSize: isCompact ? 11.5 : 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 13,
                                color: Color(0xFFD97706),
                              ),
                            ],
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

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
    required bool isDark,
    Color? accentColor,
  }) {
    final chipBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final iconColor = accentColor ?? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));
    final labelColor = accentColor ?? (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}
