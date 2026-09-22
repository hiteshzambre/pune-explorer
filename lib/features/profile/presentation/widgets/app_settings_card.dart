import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/providers/app_providers.dart';

class AppSettingsCard extends ConsumerWidget {
  final bool isDark;
  final bool hapticsEnabled;
  final bool tourAlertsEnabled;
  final ValueChanged<bool> onHapticsChanged;
  final ValueChanged<bool> onAlertsChanged;

  const AppSettingsCard({
    super.key,
    required this.isDark,
    required this.hapticsEnabled,
    required this.tourAlertsEnabled,
    required this.onHapticsChanged,
    required this.onAlertsChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final appLocale = ref.watch(appLocaleProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'APP PREFERENCES',
            style: TextStyle(
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            children: [
              _buildDropdownTile(
                icon: Icons.brightness_6_rounded,
                title: 'Theme Mode',
                value: themeMode.name,
                items: ThemeMode.values.map((m) => m.name).toList(),
                onChanged: (val) {
                  if (val != null) {
                    final newMode = ThemeMode.values.firstWhere((m) => m.name == val);
                    ref.read(themeModeProvider.notifier).setThemeMode(newMode);
                  }
                },
              ),
              Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              _buildDropdownTile(
                icon: Icons.language_rounded,
                title: 'Language / भाषा',
                value: appLocale.languageCode,
                items: ['en', 'mr', 'hi'],
                onChanged: (val) {
                  if (val != null) {
                    ref.read(appLocaleProvider.notifier).setLocale(val);
                  }
                },
              ),
              Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              _buildSwitchTile(
                icon: Icons.vibration_rounded,
                title: 'Haptic Touch Vibrations',
                value: hapticsEnabled,
                onChanged: onHapticsChanged,
              ),
              Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              _buildSwitchTile(
                icon: Icons.notifications_active_rounded,
                title: 'Tour Departure Alerts',
                value: tourAlertsEnabled,
                onChanged: onAlertsChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.emerald),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        underline: const SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
        style: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          fontSize: 14,
        ),
        onChanged: onChanged,
        items: items.map((item) {
          String displayValue = item;
          if (title == 'Language / भाषा') {
            if (item == 'en') displayValue = 'English';
            if (item == 'mr') displayValue = 'Marathi';
            if (item == 'hi') displayValue = 'Hindi';
          } else {
            displayValue = item[0].toUpperCase() + item.substring(1);
          }
          
          return DropdownMenuItem<String>(
            value: item,
            child: Text(displayValue),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.emerald),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.emerald,
      ),
    );
  }
}
