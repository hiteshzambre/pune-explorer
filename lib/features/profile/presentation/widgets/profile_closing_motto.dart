import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Bottom brand motto matching reference media_1789362379350.jpg
class ProfileClosingMotto extends StatelessWidget {
  final bool isDark;
  final bool isMobile;

  const ProfileClosingMotto({
    super.key,
    required this.isDark,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Same Trails. New Stories.',
                style: TextStyle(
                  fontFamily: 'Caveat',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF4A5568),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 44,
                height: 2.5,
                decoration: BoxDecoration(
                  color: AppColors.saffron,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(height: 12),
              // Mobile Pune Heritage Skyline Panorama
              Opacity(
                opacity: isDark ? 0.65 : 0.90,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      const Color(0xFF0F172A).withValues(alpha: isDark ? 0.35 : 0.0),
                      BlendMode.darken,
                    ),
                    child: Image.asset(
                      'assets/images/pune_heritage_skyline.png',
                      height: 48,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Opacity(
        opacity: isDark ? 0.70 : 0.95,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              const Color(0xFF0F172A).withValues(alpha: isDark ? 0.35 : 0.0),
              BlendMode.darken,
            ),
            child: Image.asset(
              'assets/images/pune_heritage_skyline.png',
              height: 85,
              width: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}
