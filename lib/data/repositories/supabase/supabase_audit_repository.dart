import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/cms_models.dart';
import '../audit_log_repository.dart';
import '../../../core/supabase/supabase_config.dart';

class SupabaseAuditRepository implements AuditLogRepository {
  final SupabaseClient? _client;
  final LocalAuditLogRepository _fallback = LocalAuditLogRepository();

  SupabaseAuditRepository([SupabaseClient? client])
      : _client = client ?? SupabaseConfig.client;

  SupabaseClient get client {
    final c = _client ?? SupabaseConfig.client;
    if (c == null) throw StateError('Supabase is not initialized.');
    return c;
  }

  @override
  Future<List<AuditLogEntry>> getLogs() async {
    try {
      final res = await client
          .from(SupabaseConfig.tableAuditLogs)
          .select()
          .order('created_at', ascending: false);

      final list = res as List<dynamic>;
      if (list.isEmpty) return await _fallback.getLogs();

      return list.map((item) {
        return AuditLogEntry(
          id: item['id'] as String,
          actorEmail: item['user_email'] as String? ?? 'admin',
          actorRole: 'Admin',
          action: item['action'] as String? ?? 'LOG',
          resourceType: item['entity_type'] as String? ?? 'general',
          resourceId: item['entity_id'] as String? ?? '',
          timestamp: item['created_at']?.toString() ?? DateTime.now().toIso8601String(),
          metadata: (item['new_values'] is Map<String, dynamic>)
              ? item['new_values'] as Map<String, dynamic>
              : const {},
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseAuditRepository] getLogs error: $e');
      return await _fallback.getLogs();
    }
  }

  @override
  Future<AuditLogEntry> log({
    required String actorEmail,
    required String actorRole,
    required String action,
    required String resourceType,
    required String resourceId,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      final id = 'audit_${DateTime.now().millisecondsSinceEpoch}';

      await client.from(SupabaseConfig.tableAuditLogs).insert({
        'id': id,
        'user_id': client.auth.currentUser?.id ?? actorEmail,
        'user_email': actorEmail,
        'action': action,
        'entity_type': resourceType,
        'entity_id': resourceId,
        'new_values': metadata,
      });

      return await _fallback.log(
        actorEmail: actorEmail,
        actorRole: actorRole,
        action: action,
        resourceType: resourceType,
        resourceId: resourceId,
        metadata: metadata,
      );
    } catch (e) {
      debugPrint('[SupabaseAuditRepository] log error: $e');
      return await _fallback.log(
        actorEmail: actorEmail,
        actorRole: actorRole,
        action: action,
        resourceType: resourceType,
        resourceId: resourceId,
        metadata: metadata,
      );
    }
  }

  @override
  Future<void> clearLogs() async => _fallback.clearLogs();
}
