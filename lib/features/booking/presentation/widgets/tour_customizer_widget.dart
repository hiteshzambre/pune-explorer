import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../data/models/tour_customization.dart';

class TourCustomizerWidget extends StatelessWidget {
  final TourCustomization customization;
  final ValueChanged<TourCustomization> onChanged;

  const TourCustomizerWidget({
    super.key,
    required this.customization,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
        boxShadow: AppColors.cardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'Tour Customizer & Add-Ons',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              if (customization.totalAddOnPerPerson > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '+₹${customization.totalAddOnPerPerson.toInt()}/person',
                    style: const TextStyle(color: AppColors.emerald, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Upgrade vehicle, meal plans, or choose homestay accommodation.',
            style: TextStyle(fontSize: 11.5, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
          ),
          const Divider(height: 24),

          // 1. Transport Mode
          Text('🚗 Transport Upgrade', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          _buildChoicePill(
            title: 'AC Volvo Coach',
            subtitle: 'Included in standard tour package',
            price: 0,
            isSelected: customization.transportCostPerPerson == 0,
            isDark: isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(customization.copyWith(
                transportMode: 'AC Volvo Coach',
                transportCostPerPerson: 0,
              ));
            },
          ),
          _buildChoicePill(
            title: 'Innova Crysta SUV',
            subtitle: 'Spacious 6-seater private luxury ride',
            price: 600,
            isSelected: customization.transportCostPerPerson == 600,
            isDark: isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(customization.copyWith(
                transportMode: 'Innova Crysta SUV',
                transportCostPerPerson: 600,
              ));
            },
          ),
          _buildChoicePill(
            title: 'Chauffeur-Driven Private Sedan',
            subtitle: 'Dedicated AC sedan for your party',
            price: 1000,
            isSelected: customization.transportCostPerPerson == 1000,
            isDark: isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(customization.copyWith(
                transportMode: 'Private Chauffeur Sedan',
                transportCostPerPerson: 1000,
              ));
            },
          ),
          const SizedBox(height: 16),

          // 2. Meal Preferences
          Text('🍛 Authentic Puneri Dining', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          _buildChoicePill(
            title: 'Standard Maharashtrian Lunch',
            subtitle: 'Fresh Bhakri, Pithla, Thecha & Rice',
            price: 0,
            isSelected: customization.mealCostPerPerson == 0,
            isDark: isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(customization.copyWith(
                mealOption: 'Standard Maharashtrian Lunch',
                mealCostPerPerson: 0,
              ));
            },
          ),
          _buildChoicePill(
            title: 'Royal Puneri Thali + Sujata Mastani',
            subtitle: 'Unlimited premium heritage thali & dessert',
            price: 350,
            isSelected: customization.mealCostPerPerson == 350,
            isDark: isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(customization.copyWith(
                mealOption: 'Royal Puneri Thali + Mastani',
                mealCostPerPerson: 350,
              ));
            },
          ),
          const SizedBox(height: 16),

          // 3. Accommodation Tier
          Text('🏨 Stay / Overnight Tier', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          _buildChoicePill(
            title: 'Day Trip (No Overnight Stay)',
            subtitle: 'Return to Pune on the same evening',
            price: 0,
            isSelected: customization.accommodationCostPerPerson == 0,
            isDark: isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(customization.copyWith(
                accommodationTier: 'Day Trip (No Stay)',
                accommodationCostPerPerson: 0,
              ));
            },
          ),
          _buildChoicePill(
            title: 'Heritage Homestay / Comfort Lodge',
            subtitle: 'Private room with mountain view & breakfast',
            price: 1100,
            isSelected: customization.accommodationCostPerPerson == 1100,
            isDark: isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(customization.copyWith(
                accommodationTier: 'Heritage Homestay',
                accommodationCostPerPerson: 1100,
              ));
            },
          ),
          _buildChoicePill(
            title: 'Lakeside Dome Glamping + Campfire',
            subtitle: 'Luxury waterfront tent at Pawna with BBQ',
            price: 1800,
            isSelected: customization.accommodationCostPerPerson == 1800,
            isDark: isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(customization.copyWith(
                accommodationTier: 'Lakeside Glamping',
                accommodationCostPerPerson: 1800,
              ));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChoicePill({
    required String title,
    required String subtitle,
    required double price,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? AppColors.emerald.withValues(alpha: 0.15) : AppColors.emeraldSurface)
            : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppColors.emerald
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? AppColors.emerald : Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 13,
                        color: isSelected
                            ? AppColors.emerald
                            : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                price == 0 ? 'Included' : '+₹${price.toInt()}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: price == 0 ? Colors.grey : AppColors.emerald,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
