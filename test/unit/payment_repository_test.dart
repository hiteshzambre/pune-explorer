import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pune_explorer/core/enums/app_enums.dart';
import 'package:pune_explorer/data/models/booking.dart';
import 'package:pune_explorer/data/repositories/booking_repository.dart';
import 'package:pune_explorer/data/repositories/payment_repository.dart';

void main() {
  late LocalBookingRepository bookingRepo;
  late LocalPaymentRepository paymentRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    bookingRepo = LocalBookingRepository();
    paymentRepo = LocalPaymentRepository(bookingRepository: bookingRepo);

    // Seed a test booking in bookingRepo
    final testBooking = Booking(
      id: 'PUNE-TEST-100',
      tourId: 'pkg_darshan_royal',
      tourTitle: 'Royal Pune Darshan Tour',
      travelDate: '20 Sep 2026',
      pickupPoint: 'Pune Station',
      passengers: const [
        Passenger(fullName: 'Amit Shinde', age: 29, gender: 'Male'),
      ],
      selectedSeats: const ['2A'],
      basePrice: 599.0,
      seatExtraPrice: 50.0,
      discountAmount: 0.0,
      gstAmount: 32.45,
      platformFee: 99.0,
      totalAmount: 780.45,
      status: BookingStatus.pendingPayment,
      createdAt: DateTime.now().toIso8601String(),
      customerName: 'Amit Shinde',
      customerEmail: 'amit.shinde@example.com',
      customerPhone: '+91 98220 99887',
      verificationHash: 'AMIT26',
    );
    await bookingRepo.saveBooking(testBooking);
  });

  group('LocalPaymentRepository Unit Tests', () {
    test('createOrder generates valid PE-2026 order with 10-minute expiry', () async {
      final order = await paymentRepo.createOrder(
        bookingId: 'PUNE-TEST-100',
        userId: 'amit.shinde@example.com',
        packageId: 'pkg_darshan_royal',
        packageName: 'Royal Pune Darshan Tour',
        amount: 780.45,
      );

      expect(order.orderId.startsWith('PE-2026-'), isTrue);
      expect(order.amount, 780.45);
      expect(order.status, PaymentStatus.pendingPayment);
      expect(order.isExpired, isFalse);
      expect(order.upiUri, contains('am=780.45'));

      // Check linked booking was updated with orderId
      final linkedBooking = await bookingRepo.getBookingById('PUNE-TEST-100');
      expect(linkedBooking?.orderId, order.orderId);
      expect(linkedBooking?.paymentStatus, PaymentStatus.pendingPayment);
    });

    test('submitTransactionId transitions to underVerification and NEVER paid', () async {
      final order = await paymentRepo.createOrder(
        bookingId: 'PUNE-TEST-100',
        userId: 'amit.shinde@example.com',
        packageId: 'pkg_darshan_royal',
        packageName: 'Royal Pune Darshan Tour',
        amount: 780.45,
      );

      final submitted = await paymentRepo.submitTransactionId(
        orderId: order.orderId,
        transactionId: '556677889900',
      );

      // Must be underVerification (unverified claim)
      expect(submitted.status, PaymentStatus.underVerification);
      expect(submitted.isPaid, isFalse);
      expect(submitted.transactionId, '556677889900');

      // Check linked booking is also underVerification (NOT confirmed!)
      final linkedBooking = await bookingRepo.getBookingById('PUNE-TEST-100');
      expect(linkedBooking?.status, BookingStatus.underVerification);
      expect(linkedBooking?.paymentStatus, PaymentStatus.underVerification);
      expect(linkedBooking?.transactionId, '556677889900');
    });

    test('Prevents duplicate UTR submission across multiple bookings', () async {
      // First order submits UTR 425619842011
      final order1 = await paymentRepo.createOrder(
        bookingId: 'PUNE-TEST-100',
        userId: 'amit.shinde@example.com',
        packageId: 'pkg_1',
        packageName: 'Tour 1',
        amount: 500.0,
      );
      await paymentRepo.submitTransactionId(
        orderId: order1.orderId,
        transactionId: '778899001122',
      );

      // Second booking attempts to reuse the same UTR
      final testBooking2 = Booking(
        id: 'PUNE-TEST-200',
        tourId: 'pkg_2',
        tourTitle: 'Tour 2',
        travelDate: '21 Sep 2026',
        pickupPoint: 'Swargate',
        passengers: const [Passenger(fullName: 'Vikram', age: 30, gender: 'Male')],
        selectedSeats: const ['1B'],
        basePrice: 500.0,
        seatExtraPrice: 0.0,
        discountAmount: 0.0,
        gstAmount: 25.0,
        platformFee: 99.0,
        totalAmount: 624.0,
        status: BookingStatus.pendingPayment,
        createdAt: DateTime.now().toIso8601String(),
        customerName: 'Vikram',
        customerEmail: 'vikram@example.com',
        customerPhone: '+91 98220 11223',
        verificationHash: 'VIK26',
      );
      await bookingRepo.saveBooking(testBooking2);

      final order2 = await paymentRepo.createOrder(
        bookingId: 'PUNE-TEST-200',
        userId: 'vikram@example.com',
        packageId: 'pkg_2',
        packageName: 'Tour 2',
        amount: 624.0,
      );

      // Submitting the same UTR must throw duplicate error
      expect(
        () => paymentRepo.submitTransactionId(
          orderId: order2.orderId,
          transactionId: '778899001122',
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('already been associated with another booking'),
        )),
      );
    });

    test('verifyPayment confirms order and transitions booking to CONFIRMED and PAID', () async {
      final order = await paymentRepo.createOrder(
        bookingId: 'PUNE-TEST-100',
        userId: 'amit.shinde@example.com',
        packageId: 'pkg_darshan_royal',
        packageName: 'Royal Pune Darshan Tour',
        amount: 780.45,
      );
      await paymentRepo.submitTransactionId(
        orderId: order.orderId,
        transactionId: '987654321012',
      );

      // Admin verification action
      final verified = await paymentRepo.verifyPayment(
        orderId: order.orderId,
        verifiedBy: 'superadmin@puneexplorer.in',
        notes: 'Bank credit confirmed via UTR reconciliation',
      );

      expect(verified.status, PaymentStatus.paid);
      expect(verified.isPaid, isTrue);
      expect(verified.verifiedBy, 'superadmin@puneexplorer.in');
      expect(verified.verifiedAt, isNotNull);

      // Associated booking must be confirmed
      final linkedBooking = await bookingRepo.getBookingById('PUNE-TEST-100');
      expect(linkedBooking?.status, BookingStatus.confirmed);
      expect(linkedBooking?.paymentStatus, PaymentStatus.paid);
    });

    test('rejectPayment marks order as failed and updates booking accordingly', () async {
      final order = await paymentRepo.createOrder(
        bookingId: 'PUNE-TEST-100',
        userId: 'amit.shinde@example.com',
        packageId: 'pkg_darshan_royal',
        packageName: 'Royal Pune Darshan Tour',
        amount: 780.45,
      );
      await paymentRepo.submitTransactionId(
        orderId: order.orderId,
        transactionId: '887766554433',
      );

      final rejected = await paymentRepo.rejectPayment(
        orderId: order.orderId,
        reason: 'UTR reference not found in bank statement',
        rejectedBy: 'superadmin@puneexplorer.in',
      );

      expect(rejected.status, PaymentStatus.failed);
      expect(rejected.failureReason, 'UTR reference not found in bank statement');

      final linkedBooking = await bookingRepo.getBookingById('PUNE-TEST-100');
      expect(linkedBooking?.status, BookingStatus.paymentFailed);
      expect(linkedBooking?.paymentStatus, PaymentStatus.failed);
    });

    test('regenerateExpiredOrder creates fresh QR payment session with 10-minute validity', () async {
      final order = await paymentRepo.createOrder(
        bookingId: 'PUNE-TEST-100',
        userId: 'amit.shinde@example.com',
        packageId: 'pkg_darshan_royal',
        packageName: 'Royal Pune Darshan Tour',
        amount: 780.45,
      );

      final refreshed = await paymentRepo.regenerateExpiredOrder(order.orderId);

      expect(refreshed.orderId, isNot(order.orderId)); // New order ID
      expect(refreshed.status, PaymentStatus.pendingPayment);
      expect(refreshed.isExpired, isFalse);
      expect(refreshed.amount, order.amount);
    });
  });
}
