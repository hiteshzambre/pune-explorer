import 'package:flutter_test/flutter_test.dart';
import 'package:pune_explorer/data/models/booking.dart';
import 'package:pune_explorer/data/models/coupon.dart';
import 'package:pune_explorer/services/booking_service.dart';

void main() {
  group('BookingService & Pricing Calculation Tests', () {
    test('Calculates pricing correctly without coupon', () {
      final pricing = BookingService.calculatePricing(
        tourPrice: 499.0,
        travelers: 2,
        seatExtraPrice: 100.0, // 2 window seats
      );

      // Base: 499 * 2 = 998
      // Subtotal: 998 + 100 = 1098
      // Discount: 0
      // Net: 1098
      // GST 5%: 1098 * 0.05 = 54.9
      // Platform Fee: 99
      // Total: 1098 + 54.9 + 99 = 1251.9
      expect(pricing.basePrice, 998.0);
      expect(pricing.seatExtraPrice, 100.0);
      expect(pricing.subtotal, 1098.0);
      expect(pricing.discountAmount, 0.0);
      expect(pricing.gstAmount, closeTo(54.9, 0.01));
      expect(pricing.platformFee, 99.0);
      expect(pricing.totalAmount, closeTo(1251.9, 0.01));
    });

    test('Calculates percentage coupon discount correctly with cap', () {
      const coupon = Coupon(
        code: 'PUNEPASS20',
        title: '20% Off',
        description: 'Test coupon',
        type: 'percent',
        discountValue: 20.0,
        maxDiscount: 500.0,
        minBookingAmount: 1000.0,
        expiry: '2026',
        badge: 'Promo',
      );

      final pricing = BookingService.calculatePricing(
        tourPrice: 3000.0,
        travelers: 1,
        seatExtraPrice: 0.0,
        coupon: coupon,
      );

      // Subtotal = 3000
      // 20% of 3000 = 600, capped at maxDiscount 500
      expect(pricing.discountAmount, 500.0);
      expect(pricing.netAmount, 2500.0);
      expect(pricing.gstAmount, 125.0); // 5% of 2500
      expect(pricing.totalAmount, 2500 + 125 + 99);
    });

    test('Generates deterministic verification pass hash', () {
      final hash1 = Booking.generatePassHash('PUNE123', '+91 9822012345');
      final hash2 = Booking.generatePassHash('PUNE123', '+91 9822012345');

      expect(hash1.length, 6);
      expect(hash1, equals(hash2));
    });
  });
}
