import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class ProfileQuickActions extends StatelessWidget {
  final bool isDark;
  final VoidCallback onBookings;
  final VoidCallback onSavedPlaces;
  final VoidCallback onItineraries;
  final VoidCallback onCoins;
  final VoidCallback onRewards;

  const ProfileQuickActions({
    super.key,
    required this.isDark,
    required this.onBookings,
    required this.onSavedPlaces,
    required this.onItineraries,
    required this.onCoins,
    required this.onRewards,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // Desktop: 5 cards in a horizontal row
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildActionCards(context).map((card) => Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: card,
            ))).toList(),
          );
        } else {
          // Mobile: Horizontal scrollable row
          return SizedBox(
            height: 175,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _buildActionCards(context).map((card) => Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: SizedBox(width: 140, child: card),
              )).toList(),
            ),
          );
        }
      },
    );
  }

  List<Widget> _buildActionCards(BuildContext context) {
    return [
      _ActionCard(
        title: 'My Bookings',
        subtitle: 'View & manage trips',
        icon: Icons.confirmation_number_outlined,
        color: AppColors.emerald,
        isDark: isDark,
        onTap: onBookings,
      ),
      _ActionCard(
        title: 'Saved Places',
        subtitle: 'Your favorite spots',
        icon: Icons.favorite_border,
        color: Colors.pink,
        isDark: isDark,
        onTap: onSavedPlaces,
      ),
      _ActionCard(
        title: 'My Itineraries',
        subtitle: 'Custom travel plans',
        icon: Icons.map_outlined,
        color: AppColors.skyBlue,
        isDark: isDark,
        onTap: onItineraries,
      ),
      _ActionCard(
        title: 'Explorer Coins',
        subtitle: '1,250 coins',
        icon: Icons.stars_rounded,
        color: AppColors.gold,
        isDark: isDark,
        onTap: onCoins,
      ),
      _ActionCard(
        title: 'Rewards & Offers',
        subtitle: 'Exclusive deals',
        icon: Icons.card_giftcard,
        color: AppColors.saffron,
        isDark: isDark,
        onTap: onRewards,
      ),
    ];
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
