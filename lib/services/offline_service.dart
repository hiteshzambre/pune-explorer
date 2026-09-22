import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class OfflineService {
  static SharedPreferences? _prefsCache;

  static Future<SharedPreferences> _getPrefs() async {
    _prefsCache ??= await SharedPreferences.getInstance();
    return _prefsCache!;
  }

  static Future<Set<String>> getFavoriteIds() async {
    try {
      final prefs = await _getPrefs();
      final list = prefs.getStringList(AppConstants.keyFavorites);
      return list != null ? list.toSet() : <String>{};
    } catch (_) {
      return <String>{};
    }
  }

  static Future<void> toggleFavorite(String id) async {
    try {
      final prefs = await _getPrefs();
      final set = (prefs.getStringList(AppConstants.keyFavorites) ?? []).toSet();
      if (set.contains(id)) {
        set.remove(id);
      } else {
        set.add(id);
      }
      await prefs.setStringList(AppConstants.keyFavorites, set.toList());
    } catch (_) {}
  }

  static Future<List<String>> getRecentSearches() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getStringList(AppConstants.keyRecentSearches) ?? [];
    } catch (_) {
      return [];
    }
  }

  static Future<void> addRecentSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;
    try {
      final prefs = await _getPrefs();
      final list = prefs.getStringList(AppConstants.keyRecentSearches) ?? [];
      list.remove(clean);
      list.insert(0, clean);
      if (list.length > 8) list.removeLast();
      await prefs.setStringList(AppConstants.keyRecentSearches, list);
    } catch (_) {}
  }

  static Future<void> clearRecentSearches() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(AppConstants.keyRecentSearches);
    } catch (_) {}
  }
}
