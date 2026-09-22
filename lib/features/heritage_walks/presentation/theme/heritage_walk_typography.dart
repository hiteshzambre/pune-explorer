import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Refined Typography System dedicated exclusively to the Heritage Walks feature.
/// Pairs Plus Jakarta Sans (crisp contemporary UI) with Noto Sans Devanagari (authentic Marathi text).
class HeritageWalkTypography {
  // --- English & Numeric Typography (Plus Jakarta Sans) ---

  static TextStyle heroTitle({required Color color, double fontSize = 26}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      color: color,
      letterSpacing: -0.6,
      height: 1.2,
    );
  }

  static TextStyle pageTitle({required Color color, double fontSize = 20}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: -0.4,
    );
  }

  static TextStyle cardTitle({required Color color, double fontSize = 16.5}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: -0.3,
      height: 1.25,
    );
  }

  static TextStyle cardDescription({required Color color, double fontSize = 12.5}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.42,
    );
  }

  static TextStyle meta({required Color color, double fontSize = 11.5, FontWeight fontWeight = FontWeight.w600}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: 0.1,
    );
  }

  static TextStyle price({required Color color, double fontSize = 16}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: -0.2,
    );
  }

  static TextStyle priceLabel({required Color color, double fontSize = 10.5}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 0.2,
    );
  }

  static TextStyle button({required Color color, double fontSize = 12.5}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: 0.1,
    );
  }

  static TextStyle chip({required Color color, double fontSize = 12, bool isSelected = false}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
      color: color,
      letterSpacing: 0.1,
    );
  }

  // --- Devanagari Typography (Noto Sans Devanagari) ---

  static TextStyle marathiSubtitle({required Color color, double fontSize = 12}) {
    return GoogleFonts.notoSansDevanagari(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.3,
      letterSpacing: 0.1,
    );
  }

  static TextStyle marathiBadge({required Color color, double fontSize = 11}) {
    return GoogleFonts.notoSansDevanagari(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: 0.2,
    );
  }
}
