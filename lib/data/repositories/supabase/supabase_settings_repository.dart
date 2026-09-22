import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/admin_global_settings.dart';
import '../../models/admin_personalization.dart';
import '../admin_settings_repository.dart';
import '../../../core/supabase/supabase_config.dart';

class SupabaseSettingsRepository implements AdminSettingsRepository {
  final SupabaseClient? _client;
  final LocalAdminSettingsRepository _fallback = LocalAdminSettingsRepository();

  SupabaseSettingsRepository([SupabaseClient? client])
      : _client = client ?? SupabaseConfig.client;

  SupabaseClient get client {
    final c = _client ?? SupabaseConfig.client;
    if (c == null) throw StateError('Supabase is not initialized.');
    return c;
  }

  @override
  Future<AdminGlobalSettings> getGlobalSettings() async {
    try {
      final res = await client
          .from(SupabaseConfig.tableAppSettings)
          .select()
          .eq('key', 'general')
          .maybeSingle();

      if (res == null) return await _fallback.getGlobalSettings();

      final val = res['value'];
      if (val is Map<String, dynamic>) {
        return AdminGlobalSettings.fromJson(val);
      }
      return await _fallback.getGlobalSettings();
    } catch (e) {
      debugPrint('[SupabaseSettingsRepository] getGlobalSettings error: $e');
      return await _fallback.getGlobalSettings();
    }
  }

  @override
  Future<void> updateGlobalSettings(AdminGlobalSettings settings) async {
    try {
      await client.from(SupabaseConfig.tableAppSettings).upsert({
        'key': 'general',
        'value': settings.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      await _fallback.updateGlobalSettings(settings);
    } catch (e) {
      debugPrint('[SupabaseSettingsRepository] updateGlobalSettings error: $e');
      await _fallback.updateGlobalSettings(settings);
    }
  }

  @override
  Future<AdminPersonalization> getPersonalization() async => _fallback.getPersonalization();

  @override
  Future<void> updatePersonalization(AdminPersonalization personalization) async =>
      _fallback.updatePersonalization(personalization);
}
