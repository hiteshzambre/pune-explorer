import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin_refund_request.dart';

abstract class AdminRefundRepository {
  Future<List<AdminRefundRequest>> getRefundRequests();
  Future<AdminRefundRequest?> getRefundById(String id);
  Future<void> createRefundRequest(AdminRefundRequest request);
  Future<void> updateRefundStatus(
    String id,
    String status, {
    String? notes,
    String? processedBy,
    double? cancellationFee,
  });
}

class LocalAdminRefundRepository implements AdminRefundRepository {
  static const String keyRefunds = 'pune_explorer_refund_requests';
  List<AdminRefundRequest>? _cache;

  Future<void> _initFromStorage() async {
    if (_cache != null) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(keyRefunds);
    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(raw);
        _cache = list.map((e) => AdminRefundRequest.fromJson(e as Map<String, dynamic>)).toList();
        return;
      } catch (_) {}
    }

    final now = DateTime.now();
    _cache = [
      AdminRefundRequest(
        id: 'REF-2026-001',
        bookingId: 'PUNE-BK-9182',
        orderId: 'PE-2026-000142',
        customerName: 'Kunal Shinde',
        customerEmail: 'kunal.shinde@gmail.com',
        originalAmount: 1299.0,
        cancellationFee: 100.0,
        refundAmount: 1199.0,
        reason: 'Medical emergency in family; requested 48h prior to departure',
        date: now.subtract(const Duration(hours: 5)).toIso8601String(),
        status: 'requested',
      ),
      AdminRefundRequest(
        id: 'REF-2026-002',
        bookingId: 'PUNE-BK-8841',
        orderId: 'PE-2026-000129',
        customerName: 'Meera Patil',
        customerEmail: 'meera.p@outlook.com',
        originalAmount: 899.0,
        cancellationFee: 50.0,
        refundAmount: 849.0,
        reason: 'Duplicate payment made accidentally via phonepe',
        date: now.subtract(const Duration(days: 1)).toIso8601String(),
        status: 'approved',
        adminNotes: 'Verified duplicate order. Approved for processing.',
        processedBy: 'admin@puneexplorer.in',
        processedAt: now.subtract(const Duration(hours: 12)).toIso8601String(),
      ),
      AdminRefundRequest(
        id: 'REF-2026-003',
        bookingId: 'PUNE-BK-7712',
        orderId: 'PE-2026-000104',
        customerName: 'Vishal Nair',
        customerEmail: 'vishal.nair@live.com',
        originalAmount: 648.0,
        cancellationFee: 0.0,
        refundAmount: 648.0,
        reason: 'Heavy monsoon storm alert issued by IMD',
        date: now.subtract(const Duration(days: 4)).toIso8601String(),
        status: 'completed',
        adminNotes: '100% weather disruption refund credited to original UPI.',
        processedBy: 'admin@puneexplorer.in',
        processedAt: now.subtract(const Duration(days: 3)).toIso8601String(),
      ),
    ];
    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (_cache != null) {
      final raw = jsonEncode(_cache!.map((r) => r.toJson()).toList());
      await prefs.setString(keyRefunds, raw);
    }
  }

  @override
  Future<List<AdminRefundRequest>> getRefundRequests() async {
    await _initFromStorage();
    return List.unmodifiable(_cache!);
  }

  @override
  Future<AdminRefundRequest?> getRefundById(String id) async {
    await _initFromStorage();
    return _cache!.where((r) => r.id == id).firstOrNull;
  }

  @override
  Future<void> createRefundRequest(AdminRefundRequest request) async {
    await _initFromStorage();
    _cache!.insert(0, request);
    await _saveToStorage();
  }

  @override
  Future<void> updateRefundStatus(
    String id,
    String status, {
    String? notes,
    String? processedBy,
    double? cancellationFee,
  }) async {
    await _initFromStorage();
    final idx = _cache!.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      final current = _cache![idx];
      final newFee = cancellationFee ?? current.cancellationFee;
      final newRefundAmount = (current.originalAmount - newFee).clamp(0.0, current.originalAmount);

      _cache![idx] = current.copyWith(
        status: status,
        cancellationFee: newFee,
        refundAmount: newRefundAmount,
        adminNotes: notes ?? current.adminNotes,
        processedBy: processedBy ?? current.processedBy,
        processedAt: DateTime.now().toIso8601String(),
      );
      await _saveToStorage();
    }
  }
}
