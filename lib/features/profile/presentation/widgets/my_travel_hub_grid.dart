import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';

/// 'My Travel Hub' section with 8 navigation cards matching reference media_1789362379350.jpg
class MyTravelHubGrid extends StatelessWidget {
  final bool isDark;
  final bool isMobile;
  final VoidCallback onMyTrips;
  final VoidCallback onSavedPlaces;
  final VoidCallback onItineraries;
  final VoidCallback onRewardsWallet;
  final VoidCallback onTravelPreferences;
  final VoidCallback onAppSettings;
  final VoidCallback onHelpSupport;
  final VoidCallback onPunekarAi;

  const MyTravelHubGrid({
    super.key,
    required this.isDark,
    this.isMobile = false,
    required this.onMyTrips,
    required this.onSavedPlaces,
    required this.onItineraries,
    required this.onRewardsWallet,
    required this.onTravelPreferences,
    required this.onAppSettings,
    required this.onHelpSupport,
    required this.onPunekarAi,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Travel Hub',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Manage your journeys, preferences and more',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                ),
              ),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'My Travel Hub',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Manage your journeys, preferences and more',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 14),

        // Grid of 8 Cards
        if (isMobile) _buildMobileLayout() else _buildDesktopLayout(),
      ],
    );
  }

  // Desktop: 4 columns x 2 rows
  Widget _buildDesktopLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildHubCard(
                icon: Icons.confirmation_number_outlined,
                iconColor: const Color(0xFF10B981),
                iconBg: const Color(0xFFE8FDF3),
                title: 'My Trips',
                subtitle: 'View & manage bookings',
                onTap: onMyTrips,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildHubCard(
                icon: Icons.favorite_rounded,
                iconColor: const Color(0xFFEC4899),
                iconBg: const Color(0xFFFDF2F8),
                title: 'Saved Places',
                subtitle: 'Your favourite destinations',
                onTap: onSavedPlaces,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildHubCard(
                icon: Icons.map_outlined,
                iconColor: const Color(0xFF0284C7),
                iconBg: const Color(0xFFF0F9FF),
                title: 'My Itineraries',
                subtitle: 'Custom travel plans',
                onTap: onItineraries,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildHubCard(
                icon: Icons.monetization_on_rounded,
                iconColor: const Color(0xFFF59E0B),
                iconBg: const Color(0xFFFEF3C7),
                title: 'Rewards Wallet',
                subtitle: 'Coins, offers & vouchers',
                onTap: onRewardsWallet,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildHubCard(
                icon: Icons.tune_rounded,
                iconColor: const Color(0xFF14B8A6),
                iconBg: const Color(0xFFF0FDFA),
                title: 'Travel Preferences',
                subtitle: 'Food, transport, travel style',
                onTap: onTravelPreferences,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildHubCard(
                icon: Icons.settings_outlined,
                iconColor: const Color(0xFF10B981),
                iconBg: const Color(0xFFECFDF5),
                title: 'App Settings',
                subtitle: 'Theme, language, notifications',
                onTap: onAppSettings,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildHubCard(
                icon: Icons.headset_mic_outlined,
                iconColor: const Color(0xFFF43F5E),
                iconBg: const Color(0xFFFFF1F2),
                title: 'Help & Support',
                subtitle: 'FAQs, safety & contact',
                onTap: onHelpSupport,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildHubCard(
                icon: Icons.smart_toy_outlined,
                iconColor: const Color(0xFF3B82F6),
                iconBg: const Color(0xFFEFF6FF),
                title: 'PunekarBot AI',
                subtitle: 'Ask. Plan. Explore. Your buddy',
                onTap: onPunekarAi,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Mobile: 3 columns for top rows, 2 columns for bottom row (matching reference phone screenshot)
  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Row 1: 3 cards
        Row(
          children: [
            Expanded(
              child: _buildCompactCard(
                icon: Icons.confirmation_number_outlined,
                iconColor: const Color(0xFF10B981),
                iconBg: const Color(0xFFE8FDF3),
                title: 'My Trips',
                onTap: onMyTrips,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCompactCard(
                icon: Icons.favorite_rounded,
                iconColor: const Color(0xFFEC4899),
                iconBg: const Color(0xFFFDF2F8),
                title: 'Saved Places',
                onTap: onSavedPlaces,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCompactCard(
                icon: Icons.map_outlined,
                iconColor: const Color(0xFF0284C7),
                iconBg: const Color(0xFFF0F9FF),
                title: 'Itineraries',
                onTap: onItineraries,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Row 2: 3 cards
        Row(
          children: [
            Expanded(
              child: _buildCompactCard(
                icon: Icons.monetization_on_rounded,
                iconColor: const Color(0xFFF59E0B),
                iconBg: const Color(0xFFFEF3C7),
                title: 'Rewards',
                onTap: onRewardsWallet,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCompactCard(
                icon: Icons.tune_rounded,
                iconColor: const Color(0xFF14B8A6),
                iconBg: const Color(0xFFF0FDFA),
                title: 'Preferences',
                onTap: onTravelPreferences,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCompactCard(
                icon: Icons.settings_outlined,
                iconColor: const Color(0xFF10B981),
                iconBg: const Color(0xFFECFDF5),
                title: 'Settings',
                onTap: onAppSettings,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Row 3: 2 cards
        Row(
          children: [
            Expanded(
              child: _buildCompactCard(
                icon: Icons.headset_mic_outlined,
                iconColor: const Color(0xFFF43F5E),
                iconBg: const Color(0xFFFFF1F2),
                title: 'Help & Support',
                onTap: onHelpSupport,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCompactCard(
                icon: Icons.smart_toy_outlined,
                iconColor: const Color(0xFF3B82F6),
                iconBg: const Color(0xFFEFF6FF),
                title: 'PunekarBot AI',
                onTap: onPunekarAi,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Desktop Detailed Card with Subtitle & Chevron
  Widget _buildHubCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isDark ? AppColors.darkSurface : Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : const Color(0xFFEDF2F7),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark ? iconColor.withValues(alpha: 0.18) : iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(icon, size: 20, color: iconColor),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isDark ? AppColors.darkTextSecondary : const Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mobile Compact Card
  Widget _buildCompactCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isDark ? AppColors.darkSurface : Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : const Color(0xFFEDF2F7),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isDark ? iconColor.withValues(alpha: 0.18) : iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(icon, size: 16, color: iconColor),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.chevron_right_rounded,
                size: 14,
                color: isDark ? AppColors.darkTextSecondary : const Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
