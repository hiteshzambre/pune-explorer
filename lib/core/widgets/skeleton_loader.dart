import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Shimmer Skeleton loading component
class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final ShapeBorder? shape;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.shape,
  });

  const SkeletonLoader.circular({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = 999,
        shape = const CircleBorder();

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;

    return Semantics(
      label: 'Loading content',
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: ShapeDecoration(
              color: baseColor.withValues(alpha: _animation.value),
              shape: widget.shape ??
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
            ),
          );
        },
      ),
    );
  }
}

/// Destination Card Skeleton for Explore & Home grids
class DestinationCardSkeleton extends StatelessWidget {
  const DestinationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(height: 180, borderRadius: 16),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(height: 16, width: 140),
                SizedBox(height: 8),
                SkeletonLoader(height: 12, width: 220),
                SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonLoader(height: 14, width: 80),
                    SkeletonLoader(height: 16, width: 60),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Heritage Walk Card Skeleton matching HeritageWalkCard dimensions
class HeritageWalkCardSkeleton extends StatelessWidget {
  const HeritageWalkCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(height: 138, borderRadius: 18),
          Padding(
            padding: EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(height: 16, width: 180),
                SizedBox(height: 6),
                SkeletonLoader(height: 12, width: 120),
                SizedBox(height: 8),
                SkeletonLoader(height: 12, width: 240),
                SizedBox(height: 12),
                Row(
                  children: [
                    SkeletonLoader(height: 18, width: 65, borderRadius: 12),
                    SizedBox(width: 6),
                    SkeletonLoader(height: 18, width: 55, borderRadius: 12),
                    SizedBox(width: 6),
                    SkeletonLoader(height: 18, width: 70, borderRadius: 12),
                  ],
                ),
                SizedBox(height: 12),
                Divider(height: 1),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonLoader(height: 16, width: 70),
                    SkeletonLoader(height: 28, width: 100, borderRadius: 10),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tour Package Card Skeleton
class TourCardSkeleton extends StatelessWidget {
  const TourCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(height: 160, borderRadius: 16),
          Padding(
            padding: EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(height: 16, width: 160),
                SizedBox(height: 8),
                SkeletonLoader(height: 12, width: 200),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonLoader(height: 14, width: 90),
                    SkeletonLoader(height: 16, width: 70),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
