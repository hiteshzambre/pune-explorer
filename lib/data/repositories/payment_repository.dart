import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/payment_order.dart';
import '../../core/constants/app_constants.dart';
import '../../core/enums/app_enums.dart';
import 'booking_repository.dart';

abstract class PaymentRepository {
  Future<List<PaymentOrder>> getAllOrders();
  Future<PaymentOrder?> getOrderByOrderId(String orderId);
  Future<PaymentOrder?> getOrderByBookingId(String bookingId);
  Future<PaymentOrder> createOrder({
    required String bookingId,
    required String userId,
    required String packageId,
    required String packageName,
    required double amount,
    String? merchantUpiId,
    String? merchantName,
  });
  Future<PaymentOrder> submitTransactionId({
    required String orderId,
    required String transactionId,
  });
  Future<PaymentOrder> verifyPayment({
    required String orderId,
    required String verifiedBy,
    String? notes,
  });
  Future<PaymentOrder> rejectPayment({
    required String orderId,
    required String reason,
    required String rejectedBy,
  });
  Future<PaymentOrder> regenerateExpiredOrder(String orderId);
  Future<bool> isTransactionIdAlreadyUsed(String transactionId, {String? excludeOrderId});
}

class LocalPaymentRepository implements PaymentRepository {
  final BookingRepository _bookingRepository;
  final List<PaymentOrder> _inMemoryOrders = [];
  bool _isLoaded = false;
  static const _uuid = Uuid();

  LocalPaymentRepository({required BookingRepository bookingRepository})
      : _bookingRepository = bookingRepository;

  Future<void> _loadFromStorage() async {
    if (_isLoaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(AppConstants.keyPayments);
      if (raw != null) {
        final List<dynamic> list = jsonDecode(raw);
        _inMemoryOrders.clear();
        for (var item in list) {
          _inMemoryOrders.add(PaymentOrder.fromJson(item as Map<String, dynamic>));
        }
      } else {
        // Seed an initial payment claim for testing/demo purposes
        final now = DateTime.now();
        _inMemoryOrders.add(
          PaymentOrder(
            id: 'ord_demo_01',
            orderId: 'PE-2026-000184',
            bookingId: 'PUNE-2026-8941',
            userId: 'rahul.deshmukh@gmail.com',
            packageId: 'PNE-DAR-01',
            packageName: 'Classic Pune Darshan',
            amount: 1041.9,
            currency: 'INR',
            paymentMethod: 'upi_qr',
            merchantUpiId: 'pay.puneexplorer@upi',
            merchantName: 'PuneExplorer Tours & Travels',
            upiUri:
                'upi://pay?pa=pay.puneexplorer@upi&pn=PuneExplorer%20Tours&am=1041.90&cu=INR&tn=PE-2026-000184&tr=PE-2026-000184',
            transactionId: '425619842011',
            status: PaymentStatus.paid,
            verificationSource: 'admin',
            verifiedAt: now.subtract(const Duration(days: 1)),
            verifiedBy: 'admin@puneexplorer.in',
            createdAt: now.subtract(const Duration(days: 1)),
            updatedAt: now.subtract(const Duration(days: 1)),
            expiresAt: now.add(const Duration(days: 365)),
          ),
        );
      }
    } catch (_) {}
    _isLoaded = true;
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _inMemoryOrders.map((o) => o.toJson()).toList();
      await prefs.setString(AppConstants.keyPayments, jsonEncode(data));
    } catch (_) {}
  }

  static String generateOrderId() {
    final rand = Random().nextInt(900000) + 100000;
    return 'PE-2026-$rand';
  }

  static String buildUpiUri({
    required String payeeUpiId,
    required String payeeName,
    required double amount,
    required String orderId,
  }) {
    final encName = Uri.encodeComponent(payeeName);
    final encNote = Uri.encodeComponent('PuneExplorer Order $orderId');
    final formattedAmount = amount.toStringAsFixed(2);
    return 'upi://pay?pa=$payeeUpiId&pn=$encName&am=$formattedAmount&cu=INR&tn=$encNote&tr=$orderId';
  }

  @override
  Future<List<PaymentOrder>> getAllOrders() async {
    await _loadFromStorage();
    return List.unmodifiable(_inMemoryOrders);
  }

  @override
  Future<PaymentOrder?> getOrderByOrderId(String orderId) async {
    await _loadFromStorage();
    try {
      return _inMemoryOrders.firstWhere((o) => o.orderId == orderId || o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PaymentOrder?> getOrderByBookingId(String bookingId) async {
    await _loadFromStorage();
    try {
      return _inMemoryOrders.firstWhere((o) => o.bookingId == bookingId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PaymentOrder> createOrder({
    required String bookingId,
    required String userId,
    required String packageId,
    required String packageName,
    required double amount,
    String? merchantUpiId,
    String? merchantName,
  }) async {
    await _loadFromStorage();

    // Check if an active, unexpired order already exists for this booking
    final existingIndex = _inMemoryOrders.indexWhere(
      (o) => o.bookingId == bookingId && !o.isExpired && o.status != PaymentStatus.failed,
    );
    if (existingIndex >= 0) {
      return _inMemoryOrders[existingIndex];
    }

    final id = _uuid.v4();
    final orderId = generateOrderId();
    final merchantUpi = merchantUpiId ?? 'pay.puneexplorer@upi';
    final merchant = merchantName ?? 'PuneExplorer Tours & Travels';
    final upiUri = buildUpiUri(
      payeeUpiId: merchantUpi,
      payeeName: merchant,
      amount: amount,
      orderId: orderId,
    );

    final now = DateTime.now();
    final order = PaymentOrder(
      id: id,
      orderId: orderId,
      bookingId: bookingId,
      userId: userId,
      packageId: packageId,
      packageName: packageName,
      amount: amount,
      currency: 'INR',
      paymentMethod: 'upi_qr',
      merchantUpiId: merchantUpi,
      merchantName: merchant,
      upiUri: upiUri,
      status: PaymentStatus.pendingPayment,
      createdAt: now,
      updatedAt: now,
      expiresAt: now.add(const Duration(minutes: 10)),
    );

    _inMemoryOrders.insert(0, order);
    await _saveToStorage();

    // Link orderId to booking
    final booking = await _bookingRepository.getBookingById(bookingId);
    if (booking != null) {
      final updatedBooking = booking.copyWith(
        orderId: orderId,
        paymentStatus: PaymentStatus.pendingPayment,
        status: BookingStatus.pendingPayment,
      );
      await _bookingRepository.saveBooking(updatedBooking);
    }

    return order;
  }

  @override
  Future<bool> isTransactionIdAlreadyUsed(String transactionId, {String? excludeOrderId}) async {
    await _loadFromStorage();
    final normalized = transactionId.trim().toUpperCase();
    return _inMemoryOrders.any(
      (o) =>
          o.orderId != excludeOrderId &&
          o.transactionId != null &&
          o.transactionId!.trim().toUpperCase() == normalized &&
          (o.status == PaymentStatus.paid ||
              o.status == PaymentStatus.underVerification ||
              o.status == PaymentStatus.paymentSubmitted),
    );
  }

  @override
  Future<PaymentOrder> submitTransactionId({
    required String orderId,
    required String transactionId,
  }) async {
    await _loadFromStorage();
    final index = _inMemoryOrders.indexWhere((o) => o.orderId == orderId || o.id == orderId);
    if (index < 0) {
      throw Exception('Payment order $orderId not found.');
    }

    final current = _inMemoryOrders[index];
    if (current.isExpired) {
      throw Exception('This payment session has expired. Please generate a new QR code.');
    }

    if (current.status == PaymentStatus.paid) {
      throw Exception('This order is already verified and paid.');
    }

    final trimmedUtr = transactionId.trim();

    // Basic format validation
    if (trimmedUtr.length < 8 || trimmedUtr.length > 24) {
      throw Exception('Transaction ID / UTR must be between 8 and 24 characters.');
    }

    // Reject all identical repeating characters (e.g. 00000000, 11111111)
    if (RegExp(r'^(.)\1+$').hasMatch(trimmedUtr)) {
      throw Exception('Please enter a valid, non-trivial transaction reference number.');
    }

    // Check duplicate UTR protection
    final isDuplicate = await isTransactionIdAlreadyUsed(trimmedUtr, excludeOrderId: current.orderId);
    if (isDuplicate) {
      throw Exception(
        'This transaction reference has already been associated with another booking. Flagged for review.',
      );
    }

    // Update order status to underVerification (Unverified payment claim!)
    final updated = current.copyWith(
      transactionId: trimmedUtr,
      status: PaymentStatus.underVerification,
      updatedAt: DateTime.now(),
    );
    _inMemoryOrders[index] = updated;
    await _saveToStorage();

    // Update associated booking
    final booking = await _bookingRepository.getBookingById(current.bookingId);
    if (booking != null) {
      final updatedBooking = booking.copyWith(
        transactionId: trimmedUtr,
        paymentStatus: PaymentStatus.underVerification,
        status: BookingStatus.underVerification,
      );
      await _bookingRepository.saveBooking(updatedBooking);
    }

    return updated;
  }

  @override
  Future<PaymentOrder> verifyPayment({
    required String orderId,
    required String verifiedBy,
    String? notes,
  }) async {
    await _loadFromStorage();
    final index = _inMemoryOrders.indexWhere((o) => o.orderId == orderId || o.id == orderId);
    if (index < 0) {
      throw Exception('Payment order $orderId not found.');
    }

    final current = _inMemoryOrders[index];
    final now = DateTime.now();

    final updated = current.copyWith(
      status: PaymentStatus.paid,
      verifiedAt: now,
      verifiedBy: verifiedBy,
      verificationSource: 'admin',
      adminNotes: notes,
      updatedAt: now,
    );
    _inMemoryOrders[index] = updated;
    await _saveToStorage();

    // Mark booking as CONFIRMED and PAID
    final booking = await _bookingRepository.getBookingById(current.bookingId);
    if (booking != null) {
      final updatedBooking = booking.copyWith(
        paymentStatus: PaymentStatus.paid,
        status: BookingStatus.confirmed,
        verifiedAt: now.toIso8601String(),
        verifiedBy: verifiedBy,
      );
      await _bookingRepository.saveBooking(updatedBooking);
    }

    return updated;
  }

  @override
  Future<PaymentOrder> rejectPayment({
    required String orderId,
    required String reason,
    required String rejectedBy,
  }) async {
    await _loadFromStorage();
    final index = _inMemoryOrders.indexWhere((o) => o.orderId == orderId || o.id == orderId);
    if (index < 0) {
      throw Exception('Payment order $orderId not found.');
    }

    final current = _inMemoryOrders[index];
    final now = DateTime.now();

    final updated = current.copyWith(
      status: PaymentStatus.failed,
      failureReason: reason,
      verifiedBy: rejectedBy,
      updatedAt: now,
    );
    _inMemoryOrders[index] = updated;
    await _saveToStorage();

    // Mark booking as paymentFailed
    final booking = await _bookingRepository.getBookingById(current.bookingId);
    if (booking != null) {
      final updatedBooking = booking.copyWith(
        paymentStatus: PaymentStatus.failed,
        status: BookingStatus.paymentFailed,
        cancellationReason: 'Payment Verification Failed: $reason',
      );
      await _bookingRepository.saveBooking(updatedBooking);
    }

    return updated;
  }

  @override
  Future<PaymentOrder> regenerateExpiredOrder(String orderId) async {
    await _loadFromStorage();
    final index = _inMemoryOrders.indexWhere((o) => o.orderId == orderId || o.id == orderId);
    if (index < 0) {
      throw Exception('Payment order $orderId not found.');
    }

    final old = _inMemoryOrders[index];
    final now = DateTime.now();
    final newOrderId = generateOrderId();
    final upiUri = buildUpiUri(
      payeeUpiId: old.merchantUpiId,
      payeeName: old.merchantName,
      amount: old.amount,
      orderId: newOrderId,
    );

    final refreshed = old.copyWith(
      orderId: newOrderId,
      upiUri: upiUri,
      status: PaymentStatus.pendingPayment,
      createdAt: now,
      updatedAt: now,
      expiresAt: now.add(const Duration(minutes: 10)),
      transactionId: null,
      failureReason: null,
    );

    _inMemoryOrders[index] = refreshed;
    await _saveToStorage();

    // Update booking orderId
    final booking = await _bookingRepository.getBookingById(old.bookingId);
    if (booking != null) {
      final updatedBooking = booking.copyWith(
        orderId: newOrderId,
        paymentStatus: PaymentStatus.pendingPayment,
        status: BookingStatus.pendingPayment,
      );
      await _bookingRepository.saveBooking(updatedBooking);
    }

    return refreshed;
  }
}
