import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';

/// 'Pune Awaits' scenic discovery card matching reference media_1789362379350.jpg
class PuneAwaitsCard extends StatelessWidget {
  final bool isDark;
  final bool isMobile;
  final VoidCallback onPlanTrip;

  const PuneAwaitsCard({
    super.key,
    required this.isDark,
    this.isMobile = false,
    required this.onPlanTrip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: isMobile ? 160 : 200),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // Fallback Gradient (for offline or widget test environment)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF134E4A),
                    Color(0xFF065F46),
                    Color(0xFF854D0E),
                  ],
                ),
              ),
            ),
          ),

          // High-Res Scenic Image with Hiker & Fort
          Positioned.fill(
            child: Image.asset(
              'assets/images/pune_awaits_hiker_hd.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/pune_awaits_banner.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                );
              },
            ),
          ),

          // Vignette Overlay for Text Readability (Leaves hiker on right fully illuminated)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.74),
                    Colors.black.withValues(alpha: 0.32),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.46, 0.82],
                ),
              ),
            ),
          ),

          // Card Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 18.0 : 22.0,
              vertical: isMobile ? 18.0 : 22.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pune Awaits',
                  style: TextStyle(
                    fontSize: isMobile ? 22 : 25,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.3,
                    shadows: const [
                      Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 1)),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Forts • Food • Culture • Nature',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.saffronLight,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: isMobile ? 220 : 260,
                  child: Text(
                    'Discover timeless stories in every corner of Pune.',
                    style: TextStyle(
                      fontSize: isMobile ? 11.5 : 12.5,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onPlanTrip();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316), // Vivid Orange pill
                      foregroundColor: Colors.white,
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Plan Your Next Trip',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.arrow_forward_rounded, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
