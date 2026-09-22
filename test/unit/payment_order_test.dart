import 'package:flutter_test/flutter_test.dart';
import 'package:pune_explorer/core/enums/app_enums.dart';
import 'package:pune_explorer/data/models/payment_order.dart';
import 'package:pune_explorer/services/payment_service.dart';

void main() {
  group('UpiPaymentEngine UTR Validation Tests', () {
    test('Rejects null, empty, or whitespace-only UTR', () {
      expect(UpiPaymentEngine.validateUtr(null), isNotNull);
      expect(UpiPaymentEngine.validateUtr(''), isNotNull);
      expect(UpiPaymentEngine.validateUtr('   '), isNotNull);
    });

    test('Rejects UTR shorter than 8 characters', () {
      final err = UpiPaymentEngine.validateUtr('1234567');
      expect(err, contains('at least 8 characters'));
    });

    test('Rejects UTR longer than 24 characters', () {
      final err = UpiPaymentEngine.validateUtr('1234567890123456789012345');
      expect(err, contains('cannot exceed 24 characters'));
    });

    test('Rejects invalid symbols or spaces in UTR', () {
      final err = UpiPaymentEngine.validateUtr('1234@5678#90');
      expect(err, contains('only contain letters, numbers, or hyphens'));
    });

    test('Rejects trivial repeating character sequences', () {
      expect(UpiPaymentEngine.validateUtr('000000000000'), contains('non-trivial'));
      expect(UpiPaymentEngine.validateUtr('111111111111'), contains('non-trivial'));
      expect(UpiPaymentEngine.validateUtr('AAAAAAAAAAAA'), contains('non-trivial'));
    });

    test('Rejects common dummy test sequences', () {
      expect(UpiPaymentEngine.validateUtr('12345678'), contains('actual UPI transaction'));
      expect(UpiPaymentEngine.validateUtr('123456789012'), contains('actual UPI transaction'));
      expect(UpiPaymentEngine.validateUtr('testtest'), contains('actual UPI transaction'));
    });

    test('Accepts valid 12-digit bank UTR numbers and alphanumeric references', () {
      expect(UpiPaymentEngine.validateUtr('425619842011'), isNull);
      expect(UpiPaymentEngine.validateUtr('HDFC9823418293'), isNull);
      expect(UpiPaymentEngine.validateUtr('UPI-4291-8842-19'), isNull);
      expect(UpiPaymentEngine.validateUtr('SBI2026091238421'), isNull);
    });

    test('Correctly identifies sandbox QA test codes', () {
      expect(UpiPaymentEngine.isSandboxVerifyCode('TEST-VERIFY-1234'), isTrue);
      expect(UpiPaymentEngine.isSandboxFailCode('TEST-FAIL-1234'), isTrue);
      expect(UpiPaymentEngine.isSandboxVerifyCode('425619842011'), isFalse);
    });
  });

  group('UPI URI Deep Link Generator Tests', () {
    test('Builds valid RFC-compliant UPI payment URI', () {
      final uriStr = UpiPaymentEngine.buildUpiUri(
        payeeUpiId: 'pay.puneexplorer@upi',
        payeeName: 'PuneExplorer Tours & Travels',
        amount: 648.0,
        orderId: 'PE-2026-000184',
      );

      expect(uriStr.startsWith('upi://pay?'), isTrue);
      expect(uriStr, contains('pa=pay.puneexplorer@upi'));
      expect(uriStr, contains('am=648.00'));
      expect(uriStr, contains('cu=INR'));
      expect(uriStr, contains('tr=PE-2026-000184'));
    });
  });

  group('PaymentOrder Model & Lifecycle State Tests', () {
    test('Serializes to and from JSON correctly', () {
      final now = DateTime.now();
      final order = PaymentOrder(
        id: 'ord_123',
        orderId: 'PE-2026-998877',
        bookingId: 'PUNE-8841',
        userId: 'traveler@gmail.com',
        packageId: 'pkg_darshan',
        packageName: 'Pune Darshan Royal AC Tour',
        amount: 1041.9,
        currency: 'INR',
        paymentMethod: 'upi_qr',
        merchantUpiId: 'pay.puneexplorer@upi',
        merchantName: 'PuneExplorer',
        upiUri: 'upi://pay?pa=pay.puneexplorer@upi&am=1041.90',
        transactionId: '425619842011',
        status: PaymentStatus.underVerification,
        createdAt: now,
        updatedAt: now,
        expiresAt: now.add(const Duration(minutes: 10)),
      );

      final json = order.toJson();
      final recovered = PaymentOrder.fromJson(json);

      expect(recovered.id, order.id);
      expect(recovered.orderId, order.orderId);
      expect(recovered.amount, order.amount);
      expect(recovered.status, PaymentStatus.underVerification);
      expect(recovered.isUnderVerification, isTrue);
      expect(recovered.isPaid, isFalse);
      expect(recovered.isExpired, isFalse);
    });

    test('Tracks 10-minute expiry correctly', () {
      final past = DateTime.now().subtract(const Duration(minutes: 15));
      final expiredOrder = PaymentOrder(
        id: 'ord_exp',
        orderId: 'PE-2026-112233',
        bookingId: 'PUNE-1122',
        userId: 'traveler@gmail.com',
        packageId: 'pkg_1',
        packageName: 'Heritage Walk',
        amount: 500.0,
        upiUri: 'upi://pay?pa=test@upi',
        status: PaymentStatus.pendingPayment,
        createdAt: past,
        updatedAt: past,
        expiresAt: past.add(const Duration(minutes: 10)), // Expired 5 mins ago
      );

      expect(expiredOrder.isExpired, isTrue);
      expect(expiredOrder.remainingDuration, Duration.zero);
      expect(expiredOrder.canSubmitUtr, isFalse);
    });

    test('Enforces that underVerification is NOT marked as paid', () {
      final order = PaymentOrder(
        id: 'ord_claim',
        orderId: 'PE-2026-445566',
        bookingId: 'PUNE-4455',
        userId: 'user@example.com',
        packageId: 'pkg_2',
        packageName: 'Sinhagad Trek',
        amount: 799.0,
        upiUri: 'upi://pay?pa=test@upi',
        transactionId: '998877665544',
        status: PaymentStatus.underVerification,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      );

      expect(order.isUnderVerification, isTrue);
      expect(order.isPaid, isFalse);
      // Double payment guard: canSubmitUtr should be false once already under verification
      expect(order.canSubmitUtr, isFalse);
    });
  });
}
