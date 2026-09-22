import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin_global_settings.dart';
import '../models/admin_personalization.dart';

abstract class AdminSettingsRepository {
  Future<AdminGlobalSettings> getGlobalSettings();
  Future<void> updateGlobalSettings(AdminGlobalSettings settings);
  Future<AdminPersonalization> getPersonalization();
  Future<void> updatePersonalization(AdminPersonalization personalization);
}

class LocalAdminSettingsRepository implements AdminSettingsRepository {
  static const String keyGlobalSettings = 'pune_explorer_global_settings';
  static const String keyPersonalization = 'pune_explorer_admin_personalization';

  AdminGlobalSettings? _cachedSettings;
  AdminPersonalization? _cachedPersonalization;

  @override
  Future<AdminGlobalSettings> getGlobalSettings() async {
    if (_cachedSettings != null) return _cachedSettings!;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(keyGlobalSettings);
    if (raw != null && raw.isNotEmpty) {
      try {
        _cachedSettings = AdminGlobalSettings.fromJson(jsonDecode(raw));
        return _cachedSettings!;
      } catch (_) {}
    }
    _cachedSettings = const AdminGlobalSettings();
    return _cachedSettings!;
  }

  @override
  Future<void> updateGlobalSettings(AdminGlobalSettings settings) async {
    _cachedSettings = settings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyGlobalSettings, jsonEncode(settings.toJson()));
  }

  @override
  Future<AdminPersonalization> getPersonalization() async {
    if (_cachedPersonalization != null) return _cachedPersonalization!;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(keyPersonalization);
    if (raw != null && raw.isNotEmpty) {
      try {
        _cachedPersonalization = AdminPersonalization.fromJson(jsonDecode(raw));
        return _cachedPersonalization!;
      } catch (_) {}
    }
    _cachedPersonalization = const AdminPersonalization();
    return _cachedPersonalization!;
  }

  @override
  Future<void> updatePersonalization(AdminPersonalization personalization) async {
    _cachedPersonalization = personalization;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyPersonalization, jsonEncode(personalization.toJson()));
  }
}
