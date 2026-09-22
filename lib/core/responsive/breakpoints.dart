import 'package:flutter/material.dart';

/// Screen Size Breakpoints and Adaptive Android Form-Factor Intelligence
/// Supports small phones (compact <360px), standard phones (360–480px),
/// large phones (480–600px), foldables (600–840px), tablets (840–1200px),
/// and desktop / wide displays (>1200px).
class Breakpoints {
  static const double smallPhoneMax = 360.0;
  static const double standardPhoneMax = 480.0;
  static const double mobileMax = 600.0;
  static const double foldableMax = 840.0;
  static const double tabletMax = 1200.0;
  /// Minimum width for laptop/desktop split layouts (1024px)
  static const double desktopMin = 1024.0;

  /// Check if device is a small compact phone (< 360px) like outer screens of foldables
  static bool isSmallPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < smallPhoneMax;

  /// Check if device is a standard phone (360px – 480px)
  static bool isStandardPhone(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= smallPhoneMax && width < standardPhoneMax;
  }

  /// Check if device is any phone form-factor (< 600px)
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileMax;

  /// Check if device is a foldable unfolded screen or small 7-inch tablet (600px – 840px)
  static bool isFoldable(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileMax && width < foldableMax;
  }

  /// Check if device is a tablet (600px – 1200px)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileMax && width < tabletMax;
  }

  /// Check if device is a desktop or ultra-wide display (>= 1200px)
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletMax;

  /// Check if device is in landscape orientation
  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  /// Adaptive Horizontal Margin/Padding based on screen width
  static double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < smallPhoneMax) return 12.0;
    if (width < mobileMax) return 16.0;
    if (width < foldableMax) return 20.0;
    if (width < tabletMax) return 28.0;
    return 36.0;
  }

  /// Adaptive Vertical Spacing between sections
  static double getSectionGap(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < smallPhoneMax) return 14.0;
    if (width < mobileMax) return 20.0;
    if (width < foldableMax) return 24.0;
    return 32.0;
  }

  /// Dynamically calculate grid columns based on target card width
  static int getAdaptiveColumnCount(
    BuildContext context, {
    double targetCardWidth = 320.0,
    int minColumns = 1,
    int maxColumns = 6,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    final padding = getHorizontalPadding(context) * 2;
    final availableWidth = width - padding;
    final count = (availableWidth / targetCardWidth).floor();
    return count.clamp(minColumns, maxColumns);
  }

  /// Grid column count presets with support for mobile, foldable, tablet, desktop and wide screens
  static int getGridColumnCount(
    BuildContext context, {
    int mobile = 1,
    int foldable = 2,
    int tablet = 2,
    int? desktop,
    int wide = 4,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobileMax) return mobile;
    if (width < foldableMax) return foldable;
    if (width < tabletMax) return tablet;
    if (desktop != null) return desktop;
    return wide;
  }

  /// Maximum readable container width on large screens and tablets
  static double getMaxContentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1440) return 1280;
    if (width >= 1200) return 1140;
    if (width >= 900) return 860;
    return double.infinity;
  }

  /// Recommended threshold for splitting wide card contents (e.g. price and CTA) side-by-side vs stacked.
  /// When available card width is under ~420px, stacking vertically provides significantly better mobile UX.
  static bool shouldStackCard(double cardWidth) => cardWidth < 420.0;

  /// Adaptive Font Size scaling that respects accessibility textScaleFactor while clamping limits
  static double getClampedFontSize(
    BuildContext context,
    double baseSize, {
    double minScale = 0.85,
    double maxScale = 1.3,
  }) {
    final textScaler = MediaQuery.textScalerOf(context);
    final scaled = textScaler.scale(baseSize);
    return scaled.clamp(baseSize * minScale, baseSize * maxScale);
  }
}
