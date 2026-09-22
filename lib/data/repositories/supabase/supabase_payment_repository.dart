import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/payment_order.dart';
import '../../../core/enums/app_enums.dart';
import '../booking_repository.dart';
import '../payment_repository.dart';
import '../../../core/supabase/supabase_config.dart';

class SupabasePaymentRepository implements PaymentRepository {
  final BookingRepository _bookingRepository;
  final SupabaseClient? _client;
  late final LocalPaymentRepository _fallback;
  static const _uuid = Uuid();

  SupabasePaymentRepository({
    required BookingRepository bookingRepository,
    SupabaseClient? client,
  })  : _bookingRepository = bookingRepository,
        _client = client ?? SupabaseConfig.client {
    _fallback = LocalPaymentRepository(bookingRepository: bookingRepository);
  }

  SupabaseClient get client {
    final c = _client ?? SupabaseConfig.client;
    if (c == null) throw StateError('Supabase is not initialized.');
    return c;
  }

  @override
  Future<List<PaymentOrder>> getAllOrders() async {
    try {
      final res = await client
          .from(SupabaseConfig.tablePayments)
          .select()
          .order('created_at', ascending: false);

      final list = res as List<dynamic>;
      if (list.isEmpty) return await _fallback.getAllOrders();

      return list.map((item) => _mapRowToPaymentOrder(item)).toList();
    } catch (e) {
      debugPrint('[SupabasePaymentRepository] getAllOrders error: $e. Using fallback.');
      return await _fallback.getAllOrders();
    }
  }

  @override
  Future<PaymentOrder?> getOrderByOrderId(String orderId) async {
    try {
      final res = await client
          .from(SupabaseConfig.tablePayments)
          .select()
          .eq('order_id', orderId)
          .maybeSingle();

      if (res == null) return await _fallback.getOrderByOrderId(orderId);
      return _mapRowToPaymentOrder(res);
    } catch (e) {
      debugPrint('[SupabasePaymentRepository] getOrderByOrderId error: $e');
      return await _fallback.getOrderByOrderId(orderId);
    }
  }

  @override
  Future<PaymentOrder?> getOrderByBookingId(String bookingId) async {
    try {
      final res = await client
          .from(SupabaseConfig.tablePayments)
          .select()
          .eq('booking_id', bookingId)
          .maybeSingle();

      if (res == null) return await _fallback.getOrderByBookingId(bookingId);
      return _mapRowToPaymentOrder(res);
    } catch (e) {
      debugPrint('[SupabasePaymentRepository] getOrderByBookingId error: $e');
      return await _fallback.getOrderByBookingId(bookingId);
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
    try {
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(minutes: 20));
      final orderSeq = 1000 + Random().nextInt(9000);
      final orderId = 'PE-${now.year}-${orderSeq.toString().padLeft(6, '0')}';
      final id = _uuid.v4();
      final mUpi = merchantUpiId ?? 'puneexplorer@icici';
      final mName = merchantName ?? 'PuneExplorer Tourism';

      final upiUri = 'upi://pay?pa=$mUpi&pn=${Uri.encodeComponent(mName)}&am=${amount.toStringAsFixed(2)}&cu=INR&tn=${Uri.encodeComponent('Booking $orderId')}';

      await client.from(SupabaseConfig.tablePayments).insert({
        'id': id,
        'order_id': orderId,
        'booking_id': bookingId,
        'user_id': userId.contains('-') ? userId : client.auth.currentUser?.id ?? _uuid.v4(),
        'amount': amount,
        'status': 'created',
        'payment_method': 'UPI_QR',
        'merchant_upi_id': mUpi,
        'merchant_name': mName,
      });

      return PaymentOrder(
        id: id,
        orderId: orderId,
        bookingId: bookingId,
        userId: userId,
        packageId: packageId,
        packageName: packageName,
        amount: amount,
        currency: 'INR',
        paymentMethod: 'upi_qr',
        merchantUpiId: mUpi,
        merchantName: mName,
        upiUri: upiUri,
        status: PaymentStatus.pendingPayment,
        createdAt: now,
        updatedAt: now,
        expiresAt: expiresAt,
      );
    } catch (e) {
      debugPrint('[SupabasePaymentRepository] createOrder error: $e. Falling back.');
      return await _fallback.createOrder(
        bookingId: bookingId,
        userId: userId,
        packageId: packageId,
        packageName: packageName,
        amount: amount,
        merchantUpiId: merchantUpiId,
        merchantName: merchantName,
      );
    }
  }

  @override
  Future<PaymentOrder> submitTransactionId({
    required String orderId,
    required String transactionId,
  }) async {
    try {
      final cleanTxId = transactionId.trim().toUpperCase();

      await client.from(SupabaseConfig.tablePayments).update({
        'upi_transaction_id': cleanTxId,
        'status': 'under_verification',
      }).eq('order_id', orderId);

      final updated = await getOrderByOrderId(orderId);
      if (updated != null) return updated;

      throw Exception('Order could not be retrieved after submission.');
    } catch (e) {
      debugPrint('[SupabasePaymentRepository] submitTransactionId error: $e');
      return _fallback.submitTransactionId(orderId: orderId, transactionId: transactionId);
    }
  }

  @override
  Future<PaymentOrder> verifyPayment({
    required String orderId,
    required String verifiedBy,
    String? notes,
  }) async {
    try {
      // Call atomic RPC stored procedure
      await client.rpc('verify_payment_claim', params: {
        'p_order_id': orderId,
        'p_verified_by': verifiedBy,
        'p_notes': notes ?? 'Verified via PuneExplorer Supabase Client',
      });

      final updated = await getOrderByOrderId(orderId);
      if (updated != null) {
        await _bookingRepository.updateBookingStatus(updated.bookingId, BookingStatus.confirmed);
        return updated;
      }

      throw Exception('Payment verified but updated record could not be loaded.');
    } catch (e) {
      debugPrint('[SupabasePaymentRepository] verifyPayment error: $e');
      return _fallback.verifyPayment(orderId: orderId, verifiedBy: verifiedBy, notes: notes);
    }
  }

  @override
  Future<PaymentOrder> rejectPayment({
    required String orderId,
    required String reason,
    required String rejectedBy,
  }) async {
    try {
      await client.rpc('reject_payment_claim', params: {
        'p_order_id': orderId,
        'p_reason': reason,
        'p_rejected_by': rejectedBy,
      });

      final updated = await getOrderByOrderId(orderId);
      if (updated != null) return updated;

      throw Exception('Payment rejected but order could not be reloaded.');
    } catch (e) {
      debugPrint('[SupabasePaymentRepository] rejectPayment error: $e');
      return _fallback.rejectPayment(orderId: orderId, reason: reason, rejectedBy: rejectedBy);
    }
  }

  @override
  Future<PaymentOrder> regenerateExpiredOrder(String orderId) async {
    return _fallback.regenerateExpiredOrder(orderId);
  }

  @override
  Future<bool> isTransactionIdAlreadyUsed(String transactionId, {String? excludeOrderId}) async {
    try {
      var query = client
          .from(SupabaseConfig.tablePayments)
          .select('id')
          .eq('upi_transaction_id', transactionId.trim().toUpperCase());

      if (excludeOrderId != null) {
        query = query.neq('order_id', excludeOrderId);
      }

      final res = await query;
      return (res as List).isNotEmpty;
    } catch (e) {
      return _fallback.isTransactionIdAlreadyUsed(transactionId, excludeOrderId: excludeOrderId);
    }
  }

  PaymentOrder _mapRowToPaymentOrder(Map<String, dynamic> row) {
    final statusStr = row['status'] as String? ?? 'created';
    PaymentStatus status;
    switch (statusStr) {
      case 'verified':
        status = PaymentStatus.paid;
        break;
      case 'under_verification':
        status = PaymentStatus.underVerification;
        break;
      case 'rejected':
        status = PaymentStatus.failed;
        break;
      default:
        status = PaymentStatus.pendingPayment;
    }

    final createdAt = DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now();
    final verifiedAt = row['verified_at'] != null
        ? DateTime.tryParse(row['verified_at'].toString())
        : null;

    final mUpi = row['merchant_upi_id'] as String? ?? 'puneexplorer@icici';
    final mName = row['merchant_name'] as String? ?? 'PuneExplorer Tourism';
    final amount = (row['amount'] as num?)?.toDouble() ?? 500.0;
    final orderId = row['order_id'] as String? ?? row['id'];

    return PaymentOrder(
      id: row['id'] as String,
      orderId: orderId,
      bookingId: row['booking_id'] as String? ?? '',
      userId: row['user_id'] as String? ?? '',
      packageId: 'pune-tour',
      packageName: 'PuneExplorer Experience',
      amount: amount,
      currency: 'INR',
      paymentMethod: row['payment_method'] as String? ?? 'upi_qr',
      merchantUpiId: mUpi,
      merchantName: mName,
      upiUri: 'upi://pay?pa=$mUpi&pn=${Uri.encodeComponent(mName)}&am=${amount.toStringAsFixed(2)}&cu=INR&tn=${Uri.encodeComponent('Booking $orderId')}',
      transactionId: row['upi_transaction_id'] as String?,
      status: status,
      verificationSource: 'supabase',
      verifiedAt: verifiedAt,
      verifiedBy: row['verified_by'] as String?,
      failureReason: row['rejection_reason'] as String?,
      adminNotes: null,
      createdAt: createdAt,
      updatedAt: DateTime.tryParse(row['updated_at']?.toString() ?? '') ?? createdAt,
      expiresAt: createdAt.add(const Duration(minutes: 20)),
    );
  }
}
