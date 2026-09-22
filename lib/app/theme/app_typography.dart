import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized Typography System for PuneExplorer
/// Uses Playfair Display for editorial headings & Inter for crisp UI text.
class AppTypography {
  static TextTheme createTextTheme(Color textPrimary, Color textSecondary) {
    return TextTheme(
      // Display / Editorial Hero Headings
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.3,
        height: 1.25,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.3,
      ),

      // Headline
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.2,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),

      // Titles
      titleLarge: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        letterSpacing: 0.1,
      ),

      // Body UI
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.45,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.4,
      ),

      // Labels & Buttons
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: 0.2,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }

  /// Responsive Hero Editorial Title (Playfair Display)
  /// Scaled for desktop (44-52px), tablet (36-40px), mobile (28-32px), compact (24-26px)
  static TextStyle heroTitle(BuildContext context, {Color color = Colors.white}) {
    final width = MediaQuery.sizeOf(context).width;
    final double size;
    if (width > 1024) {
      size = 46.0;
    } else if (width > 600) {
      size = 38.0;
    } else if (width < 360) {
      size = 25.0;
    } else {
      size = 30.0;
    }

    return GoogleFonts.playfairDisplay(
      fontSize: size,
      fontWeight: FontWeight.w900,
      color: color,
      letterSpacing: -0.5,
      height: 1.15,
      shadows: const [
        Shadow(
          color: Colors.black87,
          blurRadius: 12,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  /// Responsive Hero Subtitle (Inter)
  static TextStyle heroSubtitle(BuildContext context, {Color color = const Color(0xFFF1F5F9)}) {
    final width = MediaQuery.sizeOf(context).width;
    final double size = width < 360 ? 12.0 : (width > 600 ? 15.0 : 13.5);

    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: FontWeight.w500,
      color: color,
      height: 1.35,
      letterSpacing: 0.1,
      shadows: const [
        Shadow(
          color: Colors.black87,
          blurRadius: 8,
          offset: Offset(0, 1),
        ),
      ],
    );
  }

  /// Responsive Section Title
  static TextStyle sectionTitle(BuildContext context, {Color? color}) {
    final width = MediaQuery.sizeOf(context).width;
    final double size = width < 360 ? 16.0 : (width > 600 ? 20.0 : 17.5);

    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: -0.2,
    );
  }
}
