import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/image_optimizer.dart';

/// Resilient Image Widget for Cards, Banners, and Thumbnails.
/// Handles Web, Mobile, CORS failures, offline caching, and graceful fallbacks.
class AppCardImage extends StatelessWidget {
  final String imageUrl;
  final double? aspectRatio;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? heroTag;
  final String categoryIcon;
  final String categoryLabel;
  final String? title;

  const AppCardImage({
    super.key,
    required this.imageUrl,
    this.aspectRatio,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.heroTag,
    this.categoryIcon = '🏛️',
    this.categoryLabel = 'Pune Explorer',
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget imageContent;

    final trimmed = imageUrl.trim();
    if (trimmed.isEmpty) {
      imageContent = _buildFallback(isDark);
    } else if (trimmed.startsWith('assets/')) {
      imageContent = Image.asset(
        trimmed,
        width: width ?? double.infinity,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(isDark),
      );
    } else {
      final optimizedUrl = AppImageOptimizer.optimize(
        trimmed,
        width: width != null && width! < 2000 ? (width! * 1.5).round() : null,
      );

      imageContent = CachedNetworkImage(
        imageUrl: optimizedUrl,
        width: width ?? double.infinity,
        height: height,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 250),
        fadeOutDuration: const Duration(milliseconds: 150),
        // Disable memCache on Web to avoid CanvasKit image decode/CORS issues
        memCacheWidth: kIsWeb ? null : 640,
        memCacheHeight: kIsWeb ? null : 360,
        maxWidthDiskCache: kIsWeb ? null : 800,
        placeholder: (context, url) => _buildPlaceholder(isDark),
        errorWidget: (context, url, error) => _buildFallback(isDark),
      );
    }

    if (heroTag != null && heroTag!.isNotEmpty) {
      imageContent = Hero(
        tag: heroTag!,
        child: imageContent,
      );
    }

    if (aspectRatio != null && height == null) {
      imageContent = AspectRatio(
        aspectRatio: aspectRatio!,
        child: imageContent,
      );
    }

    if (borderRadius != null) {
      imageContent = ClipRRect(
        borderRadius: borderRadius!,
        child: imageContent,
      );
    }

    imageContent = Semantics(
      image: true,
      label: title ?? categoryLabel,
      child: imageContent,
    );

    return imageContent;
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: 0.5,
          child: Text(
            categoryIcon,
            style: const TextStyle(fontSize: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildFallback(bool isDark) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF064E3B), const Color(0xFF0F172A)]
              : [const Color(0xFF059669), const Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Opacity(
              opacity: 0.15,
              child: Text(
                categoryIcon,
                style: const TextStyle(fontSize: 90),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(categoryIcon, style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 2),
                    Text(
                      title ?? categoryLabel,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
