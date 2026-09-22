import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

/// Reusable KPI card matching the top row of the admin dashboard reference design.
/// Displays metric title, bold formatted value, delta trend pill (e.g. ↑ 12%),
/// icon badge, and optional subtitle/footnote.
class AdminKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String? delta;
  final bool isPositiveDelta;
  final IconData icon;
  final Color accentColor;
  final String? subtitle;
  final VoidCallback? onTap;

  const AdminKpiCard({
    super.key,
    required this.title,
    required this.value,
    this.delta,
    this.isPositiveDelta = true,
    required this.icon,
    this.accentColor = AdminTheme.emerald,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminTheme.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: AdminTheme.cardDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top row: Icon badge + Delta pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: accentColor, size: 20),
                  ),
                  if (delta != null && delta!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isPositiveDelta
                            ? AdminTheme.emerald.withValues(alpha: isDark ? 0.2 : 0.12)
                            : AdminTheme.rose.withValues(alpha: isDark ? 0.2 : 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositiveDelta ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                            color: isPositiveDelta ? AdminTheme.emerald : AdminTheme.rose,
                            size: 11,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            delta!,
                            style: TextStyle(
                              color: isPositiveDelta ? AdminTheme.emerald : AdminTheme.rose,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Value
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: isDark ? AdminTheme.textPrimaryDark : AdminTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Title
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AdminTheme.textSecondaryDark : AdminTheme.textSecondary,
                ),
              ),

              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AdminTheme.textMutedDark : AdminTheme.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
