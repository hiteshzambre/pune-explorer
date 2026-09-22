import 'package:intl/intl.dart';
import '../../data/models/tour_package.dart';

/// Centralized validator for tour departures and same-day booking cutoff times.
/// Ensures users cannot book tours whose departure times have already passed.
class BookingCutoffValidator {
  const BookingCutoffValidator._();

  /// Default morning departure time if tour itinerary does not explicitly specify one.
  static const int defaultDepartureHour = 8;
  static const int defaultDepartureMinute = 0;

  /// Lead time buffer (in minutes) required before departure. Default 0 min (cutoff at departure).
  static const int defaultCutoffLeadMinutes = 0;

  /// Parses a time string into hour and minute.
  /// Supports: "06:00 AM", "6:00 AM", "08:30 PM", "14:00", "07:15", "8 AM".
  static ({int hour, int minute})? parseTimeString(String rawTime) {
    final cleaned = rawTime.trim();
    if (cleaned.isEmpty) return null;

    try {
      // Try formats with AM/PM
      final upper = cleaned.toUpperCase();
      if (upper.contains('AM') || upper.contains('PM')) {
        final formats = ['hh:mm a', 'h:mm a', 'hh:mma', 'h:mma', 'h a', 'ha'];
        for (final fmt in formats) {
          try {
            final parsed = DateFormat(fmt, 'en_US').parse(upper);
            return (hour: parsed.hour, minute: parsed.minute);
          } catch (_) {}
        }
      }

      // Try 24-hour formats
      final parts = cleaned.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0].trim());
        final m = int.tryParse(parts[1].trim());
        if (h != null && m != null && h >= 0 && h < 24 && m >= 0 && m < 60) {
          return (hour: h, minute: m);
        }
      } else if (parts.length == 1) {
        final h = int.tryParse(parts[0].trim());
        if (h != null && h >= 0 && h < 24) {
          return (hour: h, minute: 0);
        }
      }
    } catch (_) {}

    return null;
  }

  /// Extracts all scheduled departure times from a tour package.
  /// If the tour has an itinerary, uses the first itinerary stop (pickup/departure).
  /// If multiple stops are marked as departures/pickups, includes them.
  static List<({int hour, int minute, String rawLabel})> getDepartureTimes(TourPackage tour) {
    final results = <({int hour, int minute, String rawLabel})>[];

    for (final item in tour.itinerary) {
      final parsed = parseTimeString(item.time);
      if (parsed != null) {
        results.add((hour: parsed.hour, minute: parsed.minute, rawLabel: item.time));
        // The first itinerary stop is the primary tour departure point
        break;
      }
    }

    // Fallback if no valid itinerary time was found
    if (results.isEmpty) {
      results.add((
        hour: defaultDepartureHour,
        minute: defaultDepartureMinute,
        rawLabel: '08:00 AM',
      ));
    }

    return results;
  }

  /// Returns true if [date] is today relative to [currentTime].
  static bool isToday(DateTime date, {DateTime? currentTime}) {
    final now = currentTime ?? DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Returns true if [date] is strictly before today (in the past).
  static bool isPastDate(DateTime date, {DateTime? currentTime}) {
    final now = currentTime ?? DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final targetStart = DateTime(date.year, date.month, date.day);
    return targetStart.isBefore(todayStart);
  }

  /// Returns true if a specific departure on [date] has already expired.
  static bool isDepartureExpired({
    required DateTime date,
    required int departureHour,
    required int departureMinute,
    DateTime? currentTime,
    int leadMinutes = defaultCutoffLeadMinutes,
  }) {
    final now = currentTime ?? DateTime.now();
    if (isPastDate(date, currentTime: now)) return true;

    if (isToday(date, currentTime: now)) {
      final departureDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        departureHour,
        departureMinute,
      ).subtract(Duration(minutes: leadMinutes));

      return now.isAfter(departureDateTime) || now.isAtSameMomentAs(departureDateTime);
    }

    // Future date departures are not expired
    return false;
  }

  /// Determines whether [date] can be selected for booking [tour].
  ///
  /// Rules:
  /// 1. Past dates: NEVER selectable.
  /// 2. Future dates (tomorrow onwards): ALWAYS selectable.
  /// 3. Today: ONLY selectable if at least one departure time is still in the future.
  static bool isDateSelectable(
    DateTime date,
    TourPackage tour, {
    DateTime? currentTime,
    int leadMinutes = defaultCutoffLeadMinutes,
  }) {
    final now = currentTime ?? DateTime.now();

    if (isPastDate(date, currentTime: now)) {
      return false;
    }

    if (!isToday(date, currentTime: now)) {
      // Future date
      return true;
    }

    // Today: check departures
    final departures = getDepartureTimes(tour);
    return departures.any((dep) => !isDepartureExpired(
          date: date,
          departureHour: dep.hour,
          departureMinute: dep.minute,
          currentTime: now,
          leadMinutes: leadMinutes,
        ));
  }

  /// Returns the earliest date that is selectable for [tour].
  /// If today still has available future departures, returns today.
  /// Otherwise, returns tomorrow.
  static DateTime getEarliestSelectableDate(
    TourPackage tour, {
    DateTime? currentTime,
    int leadMinutes = defaultCutoffLeadMinutes,
  }) {
    final now = currentTime ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (isDateSelectable(today, tour, currentTime: now, leadMinutes: leadMinutes)) {
      return today;
    }

    return today.add(const Duration(days: 1));
  }

  /// Centralized business logic validation for a booking request.
  /// Returns null if valid, or a descriptive user-facing error message if invalid.
  static String? validateBookingDate({
    required DateTime date,
    required TourPackage tour,
    DateTime? currentTime,
    int leadMinutes = defaultCutoffLeadMinutes,
  }) {
    final now = currentTime ?? DateTime.now();

    if (isPastDate(date, currentTime: now)) {
      return 'The selected travel date has already passed. Please select a future date.';
    }

    if (isToday(date, currentTime: now)) {
      final departures = getDepartureTimes(tour);
      final hasFutureDeparture = departures.any((dep) => !isDepartureExpired(
            date: date,
            departureHour: dep.hour,
            departureMinute: dep.minute,
            currentTime: now,
            leadMinutes: leadMinutes,
          ));

      if (!hasFutureDeparture) {
        final departureLabel = departures.isNotEmpty ? departures.first.rawLabel : 'scheduled time';
        return 'Today\'s tour departure ($departureLabel) has already passed. Please select tomorrow or a later date.';
      }
    }

    return null;
  }
}
