import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Inspirational Travel Quote card matching reference media_1789362379350.jpg
class TravelQuoteCard extends StatelessWidget {
  final bool isDark;

  const TravelQuoteCard({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFEFE8DA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background subtle architectural monument watermark (Properly visible)
          Positioned(
            right: -10,
            bottom: -15,
            child: Opacity(
              opacity: isDark ? 0.18 : 0.22,
              child: Icon(
                Icons.account_balance,
                size: 130,
                color: isDark ? Colors.white70 : const Color(0xFFC07D3E),
              ),
            ),
          ),

          // Quote Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Large Opening Quote Mark
              const Text(
                '“',
                style: TextStyle(
                  fontSize: 48,
                  height: 0.8,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFC07D3E),
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 6),

              // Quote Body
              Text(
                'Travel\nfar enough,\nyou meet a\nbetter you.',
                style: TextStyle(
                  fontSize: 20,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.white.withValues(alpha: 0.95) : const Color(0xFF2C1810),
                  fontFamily: 'Playfair Display',
                ),
              ),
              const SizedBox(height: 4),

              // Closing Quote
              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '”',
                      style: TextStyle(
                        fontSize: 40,
                        height: 0.8,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFC07D3E),
                        fontFamily: 'serif',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '— PuneExplorer',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8C7A6B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
