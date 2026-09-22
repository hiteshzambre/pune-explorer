import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class TravelPreferencesCard extends StatelessWidget {
  final bool isDark;
  final String selectedSeatPref;
  final String selectedDietPref;
  final String selectedPacePref;
  final ValueChanged<String> onSeatChanged;
  final ValueChanged<String> onDietChanged;
  final ValueChanged<String> onPaceChanged;

  const TravelPreferencesCard({
    super.key,
    required this.isDark,
    required this.selectedSeatPref,
    required this.selectedDietPref,
    required this.selectedPacePref,
    required this.onSeatChanged,
    required this.onDietChanged,
    required this.onPaceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'My Travel Preferences',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Edit', style: TextStyle(color: AppColors.emerald)),
                ),
              ],
            ),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildPrefItem('Travel Style', 'Relaxed Heritage', Icons.spa_outlined, isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildPrefItem('Trip Type', 'Trekking & Nature', Icons.terrain_outlined, isDark)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildPrefItem('Transport', 'AC Volvo Coach', Icons.directions_bus_outlined, isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildPrefItem('Travel Companion', 'Friends', Icons.people_outlined, isDark)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildPrefItem('Food Preference', 'Maharashtrian / Local', Icons.restaurant_outlined, isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildPrefItem('Notifications', 'Enabled', Icons.notifications_outlined, isDark)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildChoiceSection('Preferred Bus Seating', ['Window Seat', 'Aisle Seat'], selectedSeatPref, onSeatChanged, isDark),
            const SizedBox(height: 16),
            _buildChoiceSection('Dietary & Meal Choice', ['Pure Vegetarian', 'Jain Friendly', 'Puneri Non-Veg'], selectedDietPref, onDietChanged, isDark),
            const SizedBox(height: 16),
            _buildChoiceSection('Tour Exploration Pace', ['Relaxed Heritage', 'Fast Trekker'], selectedPacePref, onPaceChanged, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildPrefItem(String label, String value, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: AppColors.emerald, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label, 
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted, 
                  fontSize: 11,
                ),
              ),
              Text(
                value, 
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary, 
                  fontSize: 13, 
                  fontWeight: FontWeight.bold,
                ), 
                maxLines: 1, 
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceSection(String title, List<String> options, String selected, ValueChanged<String> onChanged, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title, 
          style: TextStyle(
            fontWeight: FontWeight.w600, 
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            return ChoiceChip(
              label: Text(option),
              selected: selected == option,
              onSelected: (selected) {
                if (selected) {
                  onChanged(option);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
