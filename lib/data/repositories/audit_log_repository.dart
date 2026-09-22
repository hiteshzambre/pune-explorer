import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cms_models.dart';

abstract class AuditLogRepository {
  Future<List<AuditLogEntry>> getLogs();
  Future<AuditLogEntry> log({
    required String actorEmail,
    required String actorRole,
    required String action,
    required String resourceType,
    required String resourceId,
    Map<String, dynamic> metadata = const {},
  });
  Future<void> clearLogs();
}

class LocalAuditLogRepository implements AuditLogRepository {
  static const String keyAuditLogs = 'pune_cms_audit_logs';
  final List<AuditLogEntry> _inMemoryLogs = [];
  bool _isLoaded = false;

  Future<void> _loadFromStorage() async {
    if (_isLoaded) return;
    _isLoaded = true;
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(milliseconds: 60),
      );
      final raw = prefs.getString(keyAuditLogs);
      if (raw != null) {
        final List<dynamic> list = jsonDecode(raw);
        _inMemoryLogs.clear();
        for (var item in list) {
          _inMemoryLogs.add(AuditLogEntry.fromJson(item as Map<String, dynamic>));
        }
      } else {
        // Bootstrap realistic audit history
        _inMemoryLogs.addAll([
          AuditLogEntry(
            id: 'log_boot_01',
            actorEmail: 'system@puneexplorer.in',
            actorRole: 'Super Admin',
            action: 'SYSTEM_BOOTSTRAP',
            resourceType: 'PLATFORM',
            resourceId: 'SYS-2026',
            timestamp: DateTime.now().subtract(const Duration(hours: 36)).toIso8601String(),
            metadata: {'version': '2.4.0', 'environment': 'production'},
          ),
          AuditLogEntry(
            id: 'log_boot_02',
            actorEmail: 'admin@puneexplorer.in',
            actorRole: 'Super Admin',
            action: 'CATALOG_SYNC',
            resourceType: 'DESTINATION',
            resourceId: 'dest_1',
            timestamp: DateTime.now().subtract(const Duration(hours: 18)).toIso8601String(),
            metadata: {'destination': 'Shaniwar Wada', 'changes': 'Updated timings & audio guide rates'},
          ),
          AuditLogEntry(
            id: 'log_boot_03',
            actorEmail: 'editor@puneexplorer.in',
            actorRole: 'Content Admin',
            action: 'HERO_SLIDE_UPDATE',
            resourceType: 'HOMEPAGE_CMS',
            resourceId: 'slide_1',
            timestamp: DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
            metadata: {'slide': 'Relive Peshwa Glory at Shaniwar Wada', 'status': 'PUBLISHED'},
          ),
          AuditLogEntry(
            id: 'log_boot_04',
            actorEmail: 'ops@puneexplorer.in',
            actorRole: 'Booking Admin',
            action: 'PAYMENT_VERIFIED',
            resourceType: 'PAYMENT_ORDER',
            resourceId: 'PE-2026-888999',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
            metadata: {'amount': 648.0, 'method': 'UPI_QR', 'utr': '425619842011'},
          ),
        ]);
      }
    } catch (_) {}
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _inMemoryLogs.take(500).map((l) => l.toJson()).toList();
      await prefs.setString(keyAuditLogs, jsonEncode(data));
    } catch (_) {}
  }

  @override
  Future<List<AuditLogEntry>> getLogs() async {
    await _loadFromStorage();
    return List.unmodifiable(_inMemoryLogs);
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
    await _loadFromStorage();
    final entry = AuditLogEntry(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      actorEmail: actorEmail,
      actorRole: actorRole,
      action: action,
      resourceType: resourceType,
      resourceId: resourceId,
      timestamp: DateTime.now().toIso8601String(),
      metadata: metadata,
    );
    _inMemoryLogs.insert(0, entry);
    await _saveToStorage();
    return entry;
  }

  @override
  Future<void> clearLogs() async {
    _inMemoryLogs.clear();
    await _saveToStorage();
  }
}
