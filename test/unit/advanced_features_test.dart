import 'package:flutter_test/flutter_test.dart';
import 'package:pune_explorer/data/models/branding_model.dart';
import 'package:pune_explorer/data/models/tour_customization.dart';
import 'package:pune_explorer/data/models/booking.dart';
import 'package:pune_explorer/core/enums/app_enums.dart';
import 'package:pune_explorer/services/booking_service.dart';
import 'package:pune_explorer/services/itinerary_service.dart';

void main() {
  group('TourCustomization & Dynamic Pricing Tests', () {
    test('Calculates zero add-on for standard package options', () {
      const custom = TourCustomization();
      expect(custom.totalAddOnPerPerson, 0.0);
    });

    test('Calculates accurate add-ons with transport, meals, and luxury stay', () {
      const custom = TourCustomization(
        transportMode: 'Innova Crysta SUV',
        transportCostPerPerson: 600.0,
        mealOption: 'Royal Puneri Thali + Mastani',
        mealCostPerPerson: 350.0,
        accommodationTier: 'Lakeside Glamping',
        accommodationCostPerPerson: 1800.0,
        travelersCount: 3,
      );

      expect(custom.totalAddOnPerPerson, 2750.0); // 600 + 350 + 1800
      expect(custom.totalCustomizationCost, 8250.0); // 2750 * 3
    });

    test('BookingService.calculatePricing incorporates customization accurately', () {
      const custom = TourCustomization(
        transportCostPerPerson: 500.0,
        mealCostPerPerson: 200.0,
        travelersCount: 2,
      );

      final pricing = BookingService.calculatePricing(
        tourPrice: 1000.0,
        travelers: 2,
        seatExtraPrice: 0.0,
        customization: custom,
      );

      expect(pricing.basePrice, 2000.0);
      expect(pricing.customizationCost, 1400.0); // 700 * 2
      expect(pricing.subtotal, 3400.0);
      expect(pricing.gstAmount, 170.0); // 5% of 3400
      expect(pricing.platformFee, 99.0);
      expect(pricing.totalAmount, 3669.0); // 3400 + 170 + 99
    });
  });

  group('Razorpay Cryptographic Signature & Verification Tests', () {
    test('Generates valid HMAC-SHA256 signature and verifies correctly', () {
      const orderId = 'order_test_123456';
      const paymentId = 'pay_test_987654';

      final signature = BookingService.generateRazorpaySignature(
        orderId: orderId,
        paymentId: paymentId,
      );

      expect(signature.isNotEmpty, isTrue);

      final isValid = BookingService.verifyRazorpaySignature(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
      );

      expect(isValid, isTrue);

      final isTampered = BookingService.verifyRazorpaySignature(
        orderId: orderId,
        paymentId: 'pay_tampered_000000',
        signature: signature,
      );

      expect(isTampered, isFalse);
    });
  });

  group('Cancellation Refund Tier Engine Tests', () {
    test('Calculates 90% refund when cancelled more than 24 hours prior', () {
      final futureDate = DateTime.now().add(const Duration(days: 5));
      final booking = Booking(
        id: 'BK_REFUND_90',
        tourId: 'pkg_darshan',
        tourTitle: 'Royal Pune Darshan',
        travelDate: '${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}',
        pickupPoint: 'Swargate',
        passengers: const [],
        selectedSeats: const ['A1', 'A2'],
        basePrice: 1000.0,
        seatExtraPrice: 0.0,
        gstAmount: 50.0,
        platformFee: 25.0,
        discountAmount: 0.0,
        totalAmount: 1075.0,
        status: BookingStatus.confirmed,
        createdAt: DateTime.now().toIso8601String(),
        verificationHash: 'HASH123',
        customerName: 'Rahul',
        customerEmail: 'rahul@test.com',
        customerPhone: '+91 98220 12345',
      );

      final quote = BookingService.calculateRefundQuote(booking);
      expect(quote.refundAmount, closeTo(967.5, 0.1)); // 90% of 1075
      expect(quote.cancellationFee, closeTo(107.5, 0.1)); // 10%
    });
  });

  group('BrandingConfig & Itinerary Models Tests', () {
    test('BrandingConfig serialized and deserialized flawlessly', () {
      const config = BrandingConfig(
        siteName: 'Pune Heritage Hub',
        contactPhone: '+91 20 1122 3344',
      );

      final json = config.toJson();
      final restored = BrandingConfig.fromJson(json);

      expect(restored.siteName, 'Pune Heritage Hub');
      expect(restored.contactPhone, '+91 20 1122 3344');
      expect(restored.showNoticeBanner, isTrue);
    });

    test('ItineraryService creates new structured multi-day plan', () {
      final plan = ItineraryService.createNewPlan(
        title: 'Sinhagad Weekend Adventure',
        description: 'Trekking and local delicacies',
        startDate: '2026-09-01',
        totalDays: 2,
        initialDestinations: const [],
      );

      expect(plan.days.length, 2);
      expect(plan.days[0].title, 'Day 1: Explore & Discover');
      expect(plan.days[1].title, 'Day 2: Explore & Discover');
      expect(plan.checklist.isNotEmpty, isTrue);
    });
  });
}
