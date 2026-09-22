import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

/// Semantic, high-contrast status badge for admin tables and detail views.
/// Communicates state through color, icon, and readable text label (WCAG 2.2 compliant).
class AdminStatusBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;
  final bool isSmall;

  const AdminStatusBadge({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.isSmall = false,
  });

  factory AdminStatusBadge.fromStatus(String status, {bool isSmall = false}) {
    final s = status.trim().toLowerCase();
    if (s == 'active' || s == 'published' || s == 'paid' || s == 'confirmed' || s == 'resolved' || s == 'healthy') {
      return AdminStatusBadge(
        label: status.toUpperCase(),
        color: AdminTheme.emerald,
        icon: Icons.check_circle_rounded,
        isSmall: isSmall,
      );
    } else if (s.contains('pending') || s.contains('verification') || s.contains('progress') || s.contains('review')) {
      return AdminStatusBadge(
        label: status.toUpperCase(),
        color: AdminTheme.saffron,
        icon: Icons.pending_actions_rounded,
        isSmall: isSmall,
      );
    } else if (s.contains('scheduled')) {
      return AdminStatusBadge(
        label: status.toUpperCase(),
        color: AdminTheme.sky,
        icon: Icons.schedule_rounded,
        isSmall: isSmall,
      );
    } else if (s.contains('draft')) {
      return AdminStatusBadge(
        label: status.toUpperCase(),
        color: AdminTheme.indigo,
        icon: Icons.edit_note_rounded,
        isSmall: isSmall,
      );
    } else if (s.contains('fail') || s.contains('reject') || s.contains('cancel') || s.contains('suspend') || s.contains('expired')) {
      return AdminStatusBadge(
        label: status.toUpperCase(),
        color: AdminTheme.rose,
        icon: Icons.cancel_rounded,
        isSmall: isSmall,
      );
    }
    return AdminStatusBadge(
      label: status.toUpperCase(),
      color: AdminTheme.textMuted,
      icon: Icons.info_outline_rounded,
      isSmall: isSmall,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badgeColor = color ?? AdminTheme.emerald;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(AdminTheme.badgeRadius),
        border: Border.all(
          color: badgeColor.withValues(alpha: isDark ? 0.4 : 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: isSmall ? 10 : 12, color: badgeColor),
            SizedBox(width: isSmall ? 3 : 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: isSmall ? 10 : 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
