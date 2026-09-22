import 'package:flutter_test/flutter_test.dart';
import 'package:pune_explorer/data/models/coupon.dart';

void main() {
  group('Coupon Logic Tests', () {
    test('Rejects coupon if subtotal below minimum amount', () {
      const coupon = Coupon(
        code: 'MIN1500',
        title: 'Min 1500',
        description: 'Test',
        type: 'fixed',
        discountValue: 300,
        minBookingAmount: 1500,
        expiry: '2026',
        badge: 'Offer',
      );

      final discount = coupon.calculateDiscount(1000, 2);
      expect(discount, 0.0);
    });

    test('Rejects coupon if travelers count below minimum required', () {
      const coupon = Coupon(
        code: 'GROUP4',
        title: 'Group 4',
        description: 'Test',
        type: 'fixed',
        discountValue: 800,
        minTravelers: 4,
        minBookingAmount: 2000,
        expiry: '2026',
        badge: 'Group',
      );

      final discount = coupon.calculateDiscount(3000, 3);
      expect(discount, 0.0);

      final discountValid = coupon.calculateDiscount(3000, 4);
      expect(discountValid, 800.0);
    });
  });
}
