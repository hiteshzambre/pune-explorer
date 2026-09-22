import 'package:flutter/material.dart';

/// Central Design System tokens for the PuneExplorer Enterprise Admin Portal.
/// Visual direction: Deep forest green / dark slate sidebar (#07241D / #0A3327),
/// emerald brand accents (#10B981), saffron/gold secondary accents (#F59E0B),
/// subtle borders, and modern SaaS density.
class AdminTheme {
  AdminTheme._();

  // ── Palette: Sidebar & Navigation ──────────────────────────────────────────
  static const Color sidebarBg = Color(0xFF07241D);
  static const Color sidebarBgLight = Colors.white;
  static const Color sidebarSurface = Color(0xFF0A3327);
  static const Color sidebarSurfaceLight = Color(0xFFF8FAFC);
  static const Color sidebarItemHover = Color(0xFF0F4434);
  static const Color sidebarItemHoverLight = Color(0xFFF1F5F9);
  static const Color sidebarItemActive = Color(0xFF10B981);
  static const Color sidebarItemActiveLight = Color(0xFFDCFCE7);
  static const Color sidebarTextActive = Colors.white;
  static const Color sidebarTextActiveLight = Color(0xFF065F46);
  static const Color sidebarTextInactive = Color(0xFF94A3B8);
  static const Color sidebarTextInactiveLight = Color(0xFF64748B);
  static const Color sidebarTextGroup = Color(0xFF5E8176);
  static const Color sidebarTextGroupLight = Color(0xFF94A3B8);
  static const Color sidebarBorder = Color(0xFF123D30);
  static const Color sidebarBorderLight = Color(0xFFE2E8F0);

  // ── Palette: Workspaces & Content Surfaces ─────────────────────────────────
  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color scaffoldBgDark = Color(0xFF0B1120);

  static const Color cardBg = Colors.white;
  static const Color cardBgDark = Color(0xFF1E293B);

  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color cardBorderDark = Color(0xFF334155);

  // ── Palette: Typography & Content ──────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textPrimaryDark = Colors.white;

  static const Color textSecondary = Color(0xFF64748B);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // ── Palette: Accents & Status Semantic ─────────────────────────────────────
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldDark = Color(0xFF059669);
  static const Color emeraldLight = Color(0xFFD1FAE5);

  static const Color saffron = Color(0xFFF59E0B);
  static const Color saffronDark = Color(0xFFD97706);
  static const Color saffronLight = Color(0xFFFEF3C7);

  static const Color sky = Color(0xFF0284C7);
  static const Color skyLight = Color(0xFFE0F2FE);

  static const Color indigo = Color(0xFF6366F1);
  static const Color indigoLight = Color(0xFFEEF2FF);

  static const Color rose = Color(0xFFE11D48);
  static const Color roseLight = Color(0xFFFFE4E6);

  static const Color crimson = Color(0xFFEF4444);
  static const Color crimsonLight = Color(0xFFFEE2E2);

  static const Color purple = Color(0xFF9333EA);
  static const Color purpleLight = Color(0xFFF3E8FF);

  // ── Dimensions & Spacing ───────────────────────────────────────────────────
  static const double sidebarExpandedWidth = 260.0;
  static const double sidebarCollapsedWidth = 68.0;
  static const double topHeaderHeight = 64.0;
  static const double cardRadius = 14.0;
  static const double buttonRadius = 10.0;
  static const double badgeRadius = 6.0;

  // ── Helpers ────────────────────────────────────────────────────────────────
  static BoxDecoration cardDecoration(BuildContext context, {Color? borderColor, Color? bgColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: bgColor ?? (isDark ? cardBgDark : cardBg),
      borderRadius: BorderRadius.circular(cardRadius),
      border: Border.all(
        color: borderColor ?? (isDark ? cardBorderDark : cardBorder),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
