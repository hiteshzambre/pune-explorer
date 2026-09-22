import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../data/models/destination.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/widgets/app_network_image.dart';

class DestinationCard extends ConsumerWidget {
  final Destination destination;
  final bool isListView;
  final int? index;

  const DestinationCard({
    super.key,
    required this.destination,
    this.isListView = false,
    this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isFav = ref.watch(favoritesProvider.select((set) => set.contains(destination.id)));

    Widget cardWidget = isListView
        ? _buildListViewCard(context, ref, isDark, theme, isFav)
        : _buildGridViewCard(context, ref, isDark, theme, isFav);

    if (index != null && index! < 12) {
      return TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 250 + (index! * 40)),
        curve: Curves.easeOutCubic,
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1.0 - value) * 16),
              child: child,
            ),
          );
        },
        child: RepaintBoundary(child: cardWidget),
      );
    }

    return RepaintBoundary(child: cardWidget);
  }

  Widget _buildGridViewCard(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    ThemeData theme,
    bool isFav,
  ) {
    final reviewDisplay = destination.reviewCount >= 1000
        ? '${(destination.reviewCount / 1000).toStringAsFixed(1)}k'
        : '${destination.reviewCount}';

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
      child: Semantics(
        label: 'View details for ${destination.name}',
        button: true,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            context.push('/destination/${destination.id}');
          },
          borderRadius: BorderRadius.circular(20),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Header with Badges & Hero
            Stack(
              children: [
                AppCardImage(
                  imageUrl: destination.primaryImage,
                  aspectRatio: 16 / 9,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                  heroTag: 'dest_grid_${destination.id}',
                  categoryIcon: destination.category.icon,
                  categoryLabel: destination.category.label,
                  title: destination.name,
                ),

                // Category Badge with Vibrant Gradient
                Positioned(
                  top: 8,
                  left: 8,
                  right: 48,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: destination.category.gradient,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(destination.category.icon, style: const TextStyle(fontSize: 11)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              destination.category.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Heart / Favorite Button
                Positioned(
                  top: 6,
                  right: 6,
                  child: Tooltip(
                    message: isFav ? 'Remove from favorites' : 'Add to favorites',
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
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? Colors.redAccent : Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Distance & Duration Pills
                Positioned(
                  bottom: 6,
                  left: 8,
                  right: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
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
                                      : '${destination.distanceFromPuneKm.toInt()} km away',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (destination.recommendedDuration.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              destination.recommendedDuration,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // 2. Card Body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    destination.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14.5,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Region & State
                  Text(
                    '${destination.city} • ${destination.state}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (destination.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    // Description snippet
                    Text(
                      destination.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        fontSize: 11.5,
                        height: 1.25,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  // Price, Rating & Action Row
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.amber, size: 15),
                          const SizedBox(width: 3),
                          Text(
                            destination.rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                          Text(
                            ' ($reviewDisplay)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: destination.entryFeeIndian == 0
                              ? AppColors.emerald.withValues(alpha: 0.12)
                              : AppColors.gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: destination.entryFeeIndian == 0
                                ? AppColors.emerald.withValues(alpha: 0.3)
                                : AppColors.gold.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          destination.entryFeeIndian == 0 ? 'Free Entry' : '₹${destination.entryFeeIndian.toInt()}',
                          style: TextStyle(
                            color: destination.entryFeeIndian == 0 ? AppColors.emerald : AppColors.gold,
                            fontWeight: FontWeight.w900,
                            fontSize: 11.5,
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

  Widget _buildListViewCard(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    ThemeData theme,
    bool isFav,
  ) {
    final reviewDisplay = destination.reviewCount >= 1000
        ? '${(destination.reviewCount / 1000).toStringAsFixed(1)}k'
        : '${destination.reviewCount}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
        boxShadow: AppColors.cardShadow(isDark),
      ),
      child: Semantics(
        label: 'View details for ${destination.name}',
        button: true,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            context.push('/destination/${destination.id}');
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCardImage(
                imageUrl: destination.primaryImage,
                width: MediaQuery.sizeOf(context).width < 360 ? 92 : 105,
                height: MediaQuery.sizeOf(context).width < 360 ? 92 : 105,
                borderRadius: BorderRadius.circular(14),
                heroTag: 'dest_list_${destination.id}',
                categoryIcon: destination.category.icon,
                categoryLabel: destination.category.label,
                title: destination.name,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: destination.category.gradient,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${destination.category.icon} ${destination.category.label}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          icon: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? Colors.redAccent : AppColors.lightTextMuted,
                            size: 20,
                          ),
                          tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            ref.read(favoritesProvider.notifier).toggle(destination.id);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      destination.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5),
                    ),
                    Text(
                      '${destination.distanceFromPuneKm == 0 ? "In City" : "${destination.distanceFromPuneKm.toInt()} km"} • ${destination.state}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      destination.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: AppColors.amber, size: 15),
                            const SizedBox(width: 2),
                            Text(
                              '${destination.rating.toStringAsFixed(1)} ($reviewDisplay)',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: destination.entryFeeIndian == 0
                                ? AppColors.emerald.withValues(alpha: 0.12)
                                : AppColors.gold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            destination.entryFeeIndian == 0 ? 'Free Entry' : '₹${destination.entryFeeIndian.toInt()}',
                            style: TextStyle(
                              color: destination.entryFeeIndian == 0 ? AppColors.emerald : AppColors.gold,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
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
      ),
    );
  }
}

