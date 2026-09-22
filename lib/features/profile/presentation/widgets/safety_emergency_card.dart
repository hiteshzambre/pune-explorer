import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class SafetyEmergencyCard extends StatelessWidget {
  final bool isDark;

  const SafetyEmergencyCard({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.health_and_safety_outlined, color: AppColors.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '24x7 Tourist Safety & Helpline',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _EmergencyPill(title: 'Police 112', icon: Icons.local_police_outlined, isDark: isDark),
                _EmergencyPill(title: 'Medical 108', icon: Icons.local_hospital_outlined, isDark: isDark),
                _EmergencyPill(title: 'MTDC 1800-229930', icon: Icons.support_agent_outlined, isDark: isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyPill extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;

  const _EmergencyPill({
    required this.title,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.skyBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.skyBlue),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.skyBlue),
            ),
          ),
        ],
      ),
    );
  }
}
