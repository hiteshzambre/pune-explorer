import 'package:flutter_test/flutter_test.dart';
import 'package:pune_explorer/core/utils/booking_cutoff_validator.dart';
import 'package:pune_explorer/data/models/tour_package.dart';

void main() {
  group('BookingCutoffValidator Unit Tests', () {
    const morningTour = TourPackage(
      id: 'TOUR-01',
      title: 'Sinhagad Sunrise Tour',
      subtitle: 'Early morning fort trek',
      destinationId: 'dest_2',
      destinationName: 'Sinhagad',
      duration: '1 Day',
      price: 999.0,
      originalPrice: 1499.0,
      rating: 4.8,
      reviewCount: 120,
      badge: 'Bestseller',
      category: 'Fort',
      images: [],
      inclusions: [],
      exclusions: [],
      highlights: [],
      itinerary: [
        TourItineraryItem(time: '06:00 AM', title: 'Pickup', desc: 'Pickup from Swargate'),
        TourItineraryItem(time: '09:00 AM', title: 'Summit', desc: 'Reach fort'),
      ],
      pickupPoints: ['Swargate'],
    );

    const afternoonTour = TourPackage(
      id: 'TOUR-02',
      title: 'Heritage Walk & Evening Sunset',
      subtitle: 'Afternoon heritage trail',
      destinationId: 'dest_1',
      destinationName: 'Shaniwar Wada',
      duration: 'Half Day',
      price: 499.0,
      originalPrice: 699.0,
      rating: 4.7,
      reviewCount: 90,
      badge: 'Heritage',
      category: 'Culture',
      images: [],
      inclusions: [],
      exclusions: [],
      highlights: [],
      itinerary: [
        TourItineraryItem(time: '03:30 PM', title: 'Meet Guide', desc: 'Dilli Darwaza'),
      ],
      pickupPoints: ['Shaniwar Wada'],
    );

    test('Parses various time formats accurately', () {
      expect(BookingCutoffValidator.parseTimeString('06:00 AM'), equals((hour: 6, minute: 0)));
      expect(BookingCutoffValidator.parseTimeString('6:30 AM'), equals((hour: 6, minute: 30)));
      expect(BookingCutoffValidator.parseTimeString('03:45 PM'), equals((hour: 15, minute: 45)));
      expect(BookingCutoffValidator.parseTimeString('14:00'), equals((hour: 14, minute: 0)));
      expect(BookingCutoffValidator.parseTimeString(''), isNull);
    });

    test('Past date is never selectable and fails validation', () {
      final now = DateTime(2026, 9, 15, 10, 0); // 10:00 AM
      final yesterday = DateTime(2026, 9, 14);

      expect(BookingCutoffValidator.isDateSelectable(yesterday, morningTour, currentTime: now), isFalse);
      final error = BookingCutoffValidator.validateBookingDate(date: yesterday, tour: morningTour, currentTime: now);
      expect(error, isNotNull);
      expect(error, contains('already passed'));
    });

    test('Tomorrow and future dates are always selectable', () {
      final now = DateTime(2026, 9, 15, 10, 0); // 10:00 AM
      final tomorrow = DateTime(2026, 9, 16);
      final nextMonth = DateTime(2026, 10, 15);

      expect(BookingCutoffValidator.isDateSelectable(tomorrow, morningTour, currentTime: now), isTrue);
      expect(BookingCutoffValidator.isDateSelectable(nextMonth, morningTour, currentTime: now), isTrue);
      expect(BookingCutoffValidator.validateBookingDate(date: tomorrow, tour: morningTour, currentTime: now), isNull);
    });

    test('Today BEFORE departure is selectable', () {
      final now = DateTime(2026, 9, 15, 5, 30); // 5:30 AM (before 6:00 AM departure)
      final today = DateTime(2026, 9, 15);

      expect(BookingCutoffValidator.isDateSelectable(today, morningTour, currentTime: now), isTrue);
      expect(BookingCutoffValidator.validateBookingDate(date: today, tour: morningTour, currentTime: now), isNull);
      expect(BookingCutoffValidator.getEarliestSelectableDate(morningTour, currentTime: now), equals(today));
    });

    test('Today EXACTLY AT departure is cutoff', () {
      final now = DateTime(2026, 9, 15, 6, 0); // Exactly 6:00 AM
      final today = DateTime(2026, 9, 15);

      expect(BookingCutoffValidator.isDateSelectable(today, morningTour, currentTime: now), isFalse);
      final error = BookingCutoffValidator.validateBookingDate(date: today, tour: morningTour, currentTime: now);
      expect(error, isNotNull);
      expect(error, contains('has already passed'));
      expect(BookingCutoffValidator.getEarliestSelectableDate(morningTour, currentTime: now), equals(DateTime(2026, 9, 16)));
    });

    test('Today AFTER departure is cutoff and earliest date moves to tomorrow', () {
      final now = DateTime(2026, 9, 15, 14, 0); // 2:00 PM (well past 6:00 AM)
      final today = DateTime(2026, 9, 15);

      expect(BookingCutoffValidator.isDateSelectable(today, morningTour, currentTime: now), isFalse);
      expect(BookingCutoffValidator.getEarliestSelectableDate(morningTour, currentTime: now), equals(DateTime(2026, 9, 16)));

      // But today for afternoon tour (3:30 PM departure) is STILL selectable at 2:00 PM!
      expect(BookingCutoffValidator.isDateSelectable(today, afternoonTour, currentTime: now), isTrue);
      expect(BookingCutoffValidator.getEarliestSelectableDate(afternoonTour, currentTime: now), equals(today));
    });

    test('Fallback default 8:00 AM applies if tour has empty itinerary', () {
      const emptyItineraryTour = TourPackage(
        id: 'TOUR-03',
        title: 'Generic Tour',
        subtitle: 'No stops listed',
        destinationId: 'dest_3',
        destinationName: 'Aga Khan',
        duration: '1 Day',
        price: 299.0,
        originalPrice: 499.0,
        rating: 4.5,
        reviewCount: 30,
        badge: 'General',
        category: 'Heritage',
        images: [],
        inclusions: [],
        exclusions: [],
        highlights: [],
        itinerary: [],
        pickupPoints: ['Pune Station'],
      );

      final before8 = DateTime(2026, 9, 15, 7, 30);
      final after8 = DateTime(2026, 9, 15, 8, 30);
      final today = DateTime(2026, 9, 15);

      expect(BookingCutoffValidator.isDateSelectable(today, emptyItineraryTour, currentTime: before8), isTrue);
      expect(BookingCutoffValidator.isDateSelectable(today, emptyItineraryTour, currentTime: after8), isFalse);
    });
  });
}
