import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/admin_refund_request.dart';
import '../admin_refund_repository.dart';
import '../../../core/supabase/supabase_config.dart';

class SupabaseRefundRepository implements AdminRefundRepository {
  final SupabaseClient? _client;
  final LocalAdminRefundRepository _fallback = LocalAdminRefundRepository();

  SupabaseRefundRepository([SupabaseClient? client])
      : _client = client ?? SupabaseConfig.client;

  SupabaseClient get client {
    final c = _client ?? SupabaseConfig.client;
    if (c == null) throw StateError('Supabase is not initialized.');
    return c;
  }

  @override
  Future<List<AdminRefundRequest>> getRefundRequests() async {
    try {
      final res = await client
          .from(SupabaseConfig.tableRefundRequests)
          .select()
          .order('created_at', ascending: false);

      final list = res as List<dynamic>;
      if (list.isEmpty) return await _fallback.getRefundRequests();

      return list.map((item) {
        return AdminRefundRequest(
          id: item['id'] as String,
          bookingId: item['booking_id'] as String? ?? '',
          orderId: item['refund_code'] as String? ?? item['id'] as String,
          customerName: item['customer_name'] as String? ?? 'Traveler',
          customerEmail: item['customer_email'] as String? ?? '',
          originalAmount: (item['original_amount'] as num?)?.toDouble() ?? 0.0,
          cancellationFee: (item['cancellation_fee'] as num?)?.toDouble() ?? 0.0,
          refundAmount: (item['refund_amount'] as num?)?.toDouble() ?? 0.0,
          reason: item['reason'] as String? ?? '',
          date: item['created_at']?.toString() ?? DateTime.now().toIso8601String(),
          status: item['status'] as String? ?? 'requested',
          processedBy: item['approved_by'] as String?,
          adminNotes: item['notes'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseRefundRepository] getRefundRequests error: $e');
      return await _fallback.getRefundRequests();
    }
  }

  @override
  Future<AdminRefundRequest?> getRefundById(String id) async {
    try {
      final res = await client
          .from(SupabaseConfig.tableRefundRequests)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (res == null) return await _fallback.getRefundById(id);

      return AdminRefundRequest(
        id: res['id'] as String,
        bookingId: res['booking_id'] as String? ?? '',
        orderId: res['refund_code'] as String? ?? res['id'] as String,
        customerName: res['customer_name'] as String? ?? 'Traveler',
        customerEmail: res['customer_email'] as String? ?? '',
        originalAmount: (res['original_amount'] as num?)?.toDouble() ?? 0.0,
        cancellationFee: (res['cancellation_fee'] as num?)?.toDouble() ?? 0.0,
        refundAmount: (res['refund_amount'] as num?)?.toDouble() ?? 0.0,
        reason: res['reason'] as String? ?? '',
        date: res['created_at']?.toString() ?? DateTime.now().toIso8601String(),
        status: res['status'] as String? ?? 'requested',
        processedBy: res['approved_by'] as String?,
        adminNotes: res['notes'] as String?,
      );
    } catch (e) {
      debugPrint('[SupabaseRefundRepository] getRefundById error: $e');
      return await _fallback.getRefundById(id);
    }
  }

  @override
  Future<void> createRefundRequest(AdminRefundRequest request) async {
    try {
      final user = client.auth.currentUser;
      await client.from(SupabaseConfig.tableRefundRequests).insert({
        'id': request.id,
        'refund_code': request.id,
        'booking_id': request.bookingId,
        'user_id': user?.id ?? '00000000-0000-0000-0000-000000000000',
        'customer_name': request.customerName,
        'customer_email': request.customerEmail,
        'original_amount': request.originalAmount,
        'cancellation_fee': request.cancellationFee,
        'refund_amount': request.refundAmount,
        'reason': request.reason,
        'status': request.status,
      });
      await _fallback.createRefundRequest(request);
    } catch (e) {
      debugPrint('[SupabaseRefundRepository] createRefundRequest error: $e');
      await _fallback.createRefundRequest(request);
    }
  }

  @override
  Future<void> updateRefundStatus(
    String id,
    String status, {
    String? notes,
    String? processedBy,
    double? cancellationFee,
  }) async {
    try {
      await client.rpc('process_refund_claim', params: {
        'p_refund_id': id,
        'p_status': status,
        'p_deduction_fee': cancellationFee ?? 0.0,
        'p_notes': notes ?? '',
        'p_admin_id': processedBy ?? 'admin',
      });
      await _fallback.updateRefundStatus(
        id,
        status,
        notes: notes,
        processedBy: processedBy,
        cancellationFee: cancellationFee,
      );
    } catch (e) {
      debugPrint('[SupabaseRefundRepository] updateRefundStatus error: $e');
      await _fallback.updateRefundStatus(
        id,
        status,
        notes: notes,
        processedBy: processedBy,
        cancellationFee: cancellationFee,
      );
    }
  }
}
