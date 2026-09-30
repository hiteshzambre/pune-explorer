import 'package:flutter/material.dart';

/// Destination Categories
enum DestinationCategory {
  all('All Categories', '✨'),
  forts('Forts & Historical', '🏛️'),
  hillStation('Hill Stations & Ghats', '🏔️'),
  lakesNature('Lakes & Waterfalls', '🌊'),
  spiritual('Spiritual & Temples', '🛕'),
  adventure('Adventure & Treks', '🏕️'),
  weekendGetaway('Weekend Getaways', '🚗'),
  city('Pune City & Culture', '🌆');

  final String label;
  final String icon;
  const DestinationCategory(this.label, this.icon);

  Color get color {
    switch (this) {
      case DestinationCategory.all:
        return const Color(0xFF059669);
      case DestinationCategory.forts:
        return const Color(0xFFE05305);
      case DestinationCategory.hillStation:
        return const Color(0xFF059669);
      case DestinationCategory.lakesNature:
        return const Color(0xFF0284C7);
      case DestinationCategory.spiritual:
        return const Color(0xFFD97706);
      case DestinationCategory.adventure:
        return const Color(0xFF7C3AED);
      case DestinationCategory.weekendGetaway:
        return const Color(0xFFE11D48);
      case DestinationCategory.city:
        return const Color(0xFF0F766E);
    }
  }

  LinearGradient get gradient {
    switch (this) {
      case DestinationCategory.all:
        return const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case DestinationCategory.forts:
        return const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFE05305)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case DestinationCategory.hillStation:
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case DestinationCategory.lakesNature:
        return const LinearGradient(
          colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case DestinationCategory.spiritual:
        return const LinearGradient(
          colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case DestinationCategory.adventure:
        return const LinearGradient(
          colors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case DestinationCategory.weekendGetaway:
        return const LinearGradient(
          colors: [Color(0xFFFB7185), Color(0xFFE11D48)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case DestinationCategory.city:
        return const LinearGradient(
          colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  static DestinationCategory fromString(String? val) {
    if (val == null || val.trim().isEmpty) return DestinationCategory.all;
    final lower = val.toLowerCase().trim();
    if (lower == 'historical' || lower == 'fort' || lower == 'forts' || lower == 'museum') {
      return DestinationCategory.forts;
    }
    if (lower == 'religious' || lower == 'spiritual' || lower == 'temple' || lower == 'temples') {
      return DestinationCategory.spiritual;
    }
    if (lower == 'nature' || lower == 'lakes' || lower == 'waterfalls' || lower == 'ghats' || lower == 'lakesnature') {
      return DestinationCategory.lakesNature;
    }
    if (lower == 'hillstation' || lower == 'hills') {
      return DestinationCategory.hillStation;
    }
    if (lower == 'adventure' || lower == 'trek' || lower == 'treks') {
      return DestinationCategory.adventure;
    }
    if (lower == 'weekendgetaway' || lower == 'getaway') {
      return DestinationCategory.weekendGetaway;
    }
    if (lower == 'city' || lower == 'food' || lower == 'culture') {
      return DestinationCategory.city;
    }
    for (var cat in DestinationCategory.values) {
      if (cat.name.toLowerCase() == lower ||
          cat.label.toLowerCase().contains(lower)) {
        return cat;
      }
    }
    return DestinationCategory.all;
  }
}

/// Pune Districts / Geographic Regions
enum PuneRegion {
  all('All Regions'),
  puneCity('Pune City Center'),
  puneOutskirts('Pune Outskirts (0-30 km)'),
  lonavalaMaval('Lonavala & Maval (Pune District)'),
  mulshiTamhini('Mulshi & Tamhini Ghat (Pune District)'),
  bhorVelhe('Bhor & Velhe Fort Trail (Pune District)'),
  khedBhimashankar('Khed & Bhimashankar (Pune District)');

  final String label;
  const PuneRegion(this.label);
}

/// Trek & Activity Difficulty Levels
enum DifficultyLevel {
  easy('Easy', '🟢'),
  moderate('Moderate', '🟡'),
  challenging('Challenging', '🔴');

  final String label;
  final String badge;
  const DifficultyLevel(this.label, this.badge);
}

/// Booking Lifecycle States
enum BookingStatus {
  pending('Pending Payment'),
  pendingPayment('Pending Payment'),
  paymentPending('Processing'),
  paymentSubmitted('Payment Submitted'),
  underVerification('Under Verification'),
  paid('Paid'),
  confirmed('Confirmed'),
  completed('Completed'),
  cancelled('Cancelled'),
  paymentFailed('Payment Failed'),
  refundRequested('Refund Requested'),
  refunded('Refunded');

  final String label;
  const BookingStatus(this.label);
}

/// Payment Lifecycle States
enum PaymentStatus {
  pendingPayment('Pending Payment'),
  paymentSubmitted('Payment Submitted'),
  underVerification('Under Verification'),
  paid('Paid'),
  failed('Failed'),
  expired('Expired'),
  refundRequested('Refund Requested'),
  refunded('Refunded');

  final String label;
  const PaymentStatus(this.label);
}

/// Bus Seat States
enum SeatState {
  available,
  selected,
  booked,
  locked,
}

/// Supported App Locales
enum AppLanguage {
  en('English', 'en'),
  mr('मराठी', 'mr'),
  hi('हिंदी', 'hi');

  final String displayName;
  final String languageCode;
  const AppLanguage(this.displayName, this.languageCode);
}
