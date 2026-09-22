import 'package:flutter/material.dart';

/// Design Token Colors for PuneExplorer (Puneri Heritage Palette)
class AppColors {
  // Primary: Heritage Emerald (Sinhagad & Sahyadri Western Ghats greenery)
  static const Color emerald = Color(0xFF059669);
  static const Color emeraldLight = Color(0xFF10B981);
  static const Color emeraldDark = Color(0xFF047857);
  static const Color emeraldSurface = Color(0xFFECFDF5);
  static const Color emeraldSurfaceDark = Color(0xFF064E3B);

  // Secondary: Royal Saffron / Bhagwa (Maratha Empire & Cultural Pune)
  static const Color saffron = Color(0xFFE05305);
  static const Color saffronLight = Color(0xFFF97316);
  static const Color saffronDark = Color(0xFFC2410C);
  static const Color saffronSurface = Color(0xFFFFF7ED);
  static const Color saffronGlow = Color(0x33E05305);

  // Tertiary: Historic Royal Slate / Black Stone (Shaniwar Wada stone architecture)
  static const Color royalSlate = Color(0xFF0F172A);
  static const Color slateLight = Color(0xFF1E293B);
  static const Color slateMuted = Color(0xFF334155);

  // Accent Colors
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberLight = Color(0xFFFDE68A);
  static const Color cream = Color(0xFFFEF3C7);
  static const Color orange = Color(0xFFEA580C);
  static const Color skyBlue = Color(0xFF0284C7);
  static const Color skySurface = Color(0xFFF0F9FF);

  // Step 2 Dedicated Design System Tokens
  static const Color deepForest = Color(0xFF003C36);
  static const Color darkTeal = Color(0xFF004D46);
  static const Color teal = Color(0xFF008F83);
  static const Color goldAccent = Color(0xFFF5B83D);
  static const Color warmGold = Color(0xFFD99A24);
  static const Color creamBg = Color(0xFFFAF7F0);
  static const Color darkText = Color(0xFF14201F);
  static const Color mutedText = Color(0xFF6B706E);

  // Premium Authentication Design Tokens (Reference Spec)
  static const Color authPrimaryGreen = Color(0xFF006B4F);
  static const Color authEmerald = Color(0xFF00A878);
  static const Color authOrange = Color(0xFFF47A00);
  static const Color authGold = Color(0xFFE8A317);
  static const Color authCream = Color(0xFFFFF9EE);
  static const Color authBackground = Color(0xFFF7FAF8);
  static const Color authDarkText = Color(0xFF101828);
  static const Color authSecondary = Color(0xFF667085);

  static const LinearGradient forestNavbarGradient = LinearGradient(
    colors: [Color(0xFF003C36), Color(0xFF004D46)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Light theme gradient for navigation bars & rails
  static const LinearGradient lightNavbarGradient = LinearGradient(
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF7FAF8),
      Color(0xFFEFF7F2),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Dark theme gradient for navigation bars & rails
  static const LinearGradient darkNavbarGradient = LinearGradient(
    colors: [
      Color(0xFF182234),
      Color(0xFF111827),
      Color(0xFF0D1420),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldButtonGradient = LinearGradient(
    colors: [Color(0xFFF5B83D), Color(0xFFD99A24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Neutral - Light Theme
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF64748B);

  // Neutral - Dark Theme
  static const Color darkBackground = Color(0xFF090D16);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkSurfaceVariant = Color(0xFF1F2937);
  static const Color darkBorder = Color(0xFF283548);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextMuted = Color(0xFF9CA3AF);

  // Semantic Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Premium Gradients
  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF047857)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient saffronGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFE05305)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x22000000),
      Color(0x88000000),
      Color(0xDD090D16),
    ],
    stops: [0.0, 0.4, 0.7, 1.0],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightCardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient royalBannerGradient = LinearGradient(
    colors: [Color(0xFF064E3B), Color(0xFF047857), Color(0xFF065F46)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Heritage Gold Accent
  static const Color gold = Color(0xFFD97706);
  static const Color goldLight = Color(0xFFFBBF24);

  // Premium Glow Shadows
  static List<BoxShadow> cardShadow(bool isDark) => [
        BoxShadow(
          color: isDark ? Colors.black.withValues(alpha: 0.35) : const Color(0x0F0F172A),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> subtleShadow(bool isDark) => [
        BoxShadow(
          color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0x080F172A),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> glowShadow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.28),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  // Helper Methods for Semantic Surface Styling
  static Color getSurface(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color getSurfaceVariant(bool isDark) => isDark ? darkSurfaceVariant : lightSurfaceVariant;
  static Color getBorder(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color getTextPrimary(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color getTextSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color getTextMuted(bool isDark) => isDark ? darkTextMuted : lightTextMuted;
}
