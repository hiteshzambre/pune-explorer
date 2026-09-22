import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';

/// Indicates if code is executing inside an automated Flutter test runner.
bool get _isTestEnv =>
    WidgetsBinding.instance.runtimeType.toString().contains('Test') ||
    const bool.fromEnvironment('FLUTTER_TEST');

/// 1. Floating 3D Altitude & Live Weather Badge
/// Renders a glassmorphic micro-capsule hovering over the hero photo with 3D tilt.
class Floating3DWeatherAltitudeBadge extends StatefulWidget {
  final String altitude;
  final String weather;
  final String weatherIcon;

  const Floating3DWeatherAltitudeBadge({
    super.key,
    this.altitude = '1,312m Alt',
    this.weather = '24°C Sunny',
    this.weatherIcon = '☀️',
  });

  @override
  State<Floating3DWeatherAltitudeBadge> createState() =>
      _Floating3DWeatherAltitudeBadgeState();
}

class _Floating3DWeatherAltitudeBadgeState
    extends State<Floating3DWeatherAltitudeBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );
    if (!_isTestEnv) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final floatOffset = math.sin(_controller.value * math.pi) * 5.0;

        return Transform.translate(
          offset: Offset(0, -floatOffset),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0014)
              ..rotateX(0.08)
              ..rotateY(-0.06),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.65),
                        const Color(0xFF0F172A).withValues(alpha: 0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.weatherIcon,
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        widget.weather,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 7),
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Icon(Icons.terrain_rounded,
                          color: Color(0xFF34D399), size: 13),
                      const SizedBox(width: 4),
                      Text(
                        widget.altitude,
                        style: const TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 2. Reusable 3D Beveled Card Container
/// Provides dual-layer specular highlights and soft obsidian shadows.
class RoyalSahyadriBevelCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool isDark;
  final bool isHighlighted;
  final double borderRadius;

  const RoyalSahyadriBevelCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.isDark = true,
    this.isHighlighted = false,
    this.borderRadius = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? const EdgeInsets.all(14.0);

    final card = Container(
      margin: margin,
      padding: effectivePadding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isHighlighted
              ? [
                  const Color(0xFF2E1065).withValues(alpha: isDark ? 0.9 : 0.08),
                  const Color(0xFF78350F).withValues(alpha: isDark ? 0.8 : 0.06),
                ]
              : (isDark
                  ? [
                      const Color(0xFF1E293B),
                      const Color(0xFF0F172A),
                    ]
                  : [
                      Colors.white,
                      AppColors.creamBg,
                    ]),
        ),
        border: Border.all(
          color: isHighlighted
              ? AppColors.goldAccent
              : (isDark
                  ? const Color(0xFF334155).withValues(alpha: 0.8)
                  : AppColors.teal.withValues(alpha: 0.18)),
          width: isHighlighted ? 1.6 : 1.0,
        ),
        boxShadow: [
          // Specular top highlight
          BoxShadow(
            color: isHighlighted
                ? const Color(0xFFF59E0B).withValues(alpha: 0.25)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03)),
            blurRadius: 4,
            offset: const Offset(-1, -1),
          ),
          // Deep drop shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap!();
          },
          borderRadius: BorderRadius.circular(borderRadius),
          child: card,
        ),
      );
    }

    return card;
  }
}

/// 3. Interactive 3D Image Thumbnail
class Floating3DImageThumbnail extends StatelessWidget {
  final String imageUrl;
  final bool isSelected;
  final VoidCallback onTap;
  final String categoryIcon;
  final String categoryLabel;

  const Floating3DImageThumbnail({
    super.key,
    required this.imageUrl,
    required this.isSelected,
    required this.onTap,
    this.categoryIcon = '📍',
    this.categoryLabel = '',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(right: 10),
        width: isSelected ? 56 : 48,
        height: isSelected ? 56 : 48,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..scaleByDouble(isSelected ? 1.05 : 0.95, isSelected ? 1.05 : 0.95, 1.0, 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFF59E0B) : Colors.white.withValues(alpha: 0.6),
            width: isSelected ? 2.5 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.65),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AppCardImage(
            imageUrl: imageUrl,
            width: double.infinity,
            height: double.infinity,
            categoryIcon: categoryIcon,
            categoryLabel: categoryLabel,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

/// 4. Royal 3D Rating Gauge with Star Distribution Bars
class Royal3DRatingGauge extends StatelessWidget {
  final double rating;
  final int totalReviews;
  final bool isDark;

  const Royal3DRatingGauge({
    super.key,
    required this.rating,
    required this.totalReviews,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return RoyalSahyadriBevelCard(
      isDark: isDark,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Left 3D Golden Score Plaque
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF59E0B),
                  Color(0xFFD97706),
                  Color(0xFFB45309),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star_rounded, color: Colors.white, size: 24),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'EXCELLENT',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Right Star Distribution Bars
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBar(5, 0.82, isDark),
                const SizedBox(height: 4),
                _buildBar(4, 0.12, isDark),
                const SizedBox(height: 4),
                _buildBar(3, 0.04, isDark),
                const SizedBox(height: 4),
                _buildBar(2, 0.01, isDark),
                const SizedBox(height: 4),
                _buildBar(1, 0.01, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(int stars, double pct, bool isDark) {
    return Row(
      children: [
        SizedBox(
          width: 22,
          child: Text(
            '$stars★',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 6,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: pct,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFF10B981)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 5. Royal Maratha Heritage Crest Chip
class RoyalMarathaCrestBadge extends StatelessWidget {
  final String label;
  final String icon;
  final Color accentColor;

  const RoyalMarathaCrestBadge({
    super.key,
    required this.label,
    this.icon = '👑',
    this.accentColor = const Color(0xFFF59E0B),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: accentColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// 6. Heritage Decorative Watermark Badge ("History Breathes Here")
class HeritageWatermarkBadge extends StatelessWidget {
  final bool isDark;

  const HeritageWatermarkBadge({super.key, this.isDark = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.goldAccent.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 1,
            color: AppColors.goldAccent.withValues(alpha: 0.8),
            margin: const EdgeInsets.only(bottom: 5),
          ),
          Text(
            'History\nBreathes\nHere',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              color: AppColors.goldAccent,
              height: 1.15,
              letterSpacing: 0.8,
            ),
          ),
          Container(
            width: 24,
            height: 1,
            color: AppColors.goldAccent.withValues(alpha: 0.8),
            margin: const EdgeInsets.only(top: 5),
          ),
        ],
      ),
    );
  }
}

/// 7. Destination Photo Lightbox Dialog
class DestinationLightboxDialog extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String title;

  const DestinationLightboxDialog({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.title,
  });

  @override
  State<DestinationLightboxDialog> createState() => _DestinationLightboxDialogState();
}

class _DestinationLightboxDialogState extends State<DestinationLightboxDialog> {
  late int _currentIndex;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMultiple = widget.images.length > 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dark backdrop blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              color: Colors.black.withValues(alpha: 0.85),
            ),
          ),

          // Main image container
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800, maxHeight: 560),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.images.length,
                  onPageChanged: (idx) => setState(() => _currentIndex = idx),
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      child: AppCardImage(
                        imageUrl: widget.images[index],
                        fit: BoxFit.contain,
                        title: widget.title,
                        categoryIcon: '📸',
                        categoryLabel: 'Gallery',
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Top Bar with Title, Counter and Close
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Photo ${_currentIndex + 1} of ${widget.images.length}',
                        style: const TextStyle(
                          color: AppColors.goldAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Desktop / Tablet navigation arrows
          if (hasMultiple) ...[
            Positioned(
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 28),
                onPressed: _currentIndex > 0
                    ? () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
              ),
            ),
            Positioned(
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 28),
                onPressed: _currentIndex < widget.images.length - 1
                    ? () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

