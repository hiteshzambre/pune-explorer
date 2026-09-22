import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/cms_models.dart';
import '../media_library_repository.dart';
import '../../../core/supabase/supabase_config.dart';

class SupabaseMediaRepository implements MediaLibraryRepository {
  final SupabaseClient? _client;
  final LocalMediaLibraryRepository _fallback = LocalMediaLibraryRepository();

  SupabaseMediaRepository([SupabaseClient? client])
      : _client = client ?? SupabaseConfig.client;

  SupabaseClient get client {
    final c = _client ?? SupabaseConfig.client;
    if (c == null) throw StateError('Supabase is not initialized.');
    return c;
  }

  @override
  Future<List<MediaAsset>> getAssets() async {
    try {
      final res = await client
          .from(SupabaseConfig.tableMediaAssets)
          .select()
          .order('created_at', ascending: false);

      final list = res as List<dynamic>;
      if (list.isEmpty) return await _fallback.getAssets();

      return list.map((item) {
        return MediaAsset(
          id: item['id'] as String,
          url: item['file_url'] as String? ?? '',
          title: item['title'] as String? ?? '',
          altText: item['title'] as String? ?? '',
          category: item['category'] as String? ?? 'General',
          fileSizeKb: ((item['file_size'] as num?)?.toInt() ?? 0) ~/ 1024,
          dimensions: item['dimensions'] as String? ?? '1920x1080',
          uploadedBy: item['uploaded_by'] as String? ?? 'Admin',
          uploadedAt: item['created_at']?.toString() ?? DateTime.now().toIso8601String(),
          usageCount: 1,
          usageReferences: const [],
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseMediaRepository] getAssets error: $e');
      return await _fallback.getAssets();
    }
  }

  @override
  Future<MediaAsset?> getAssetById(String id) async {
    try {
      final res = await client
          .from(SupabaseConfig.tableMediaAssets)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (res == null) return await _fallback.getAssetById(id);

      return MediaAsset(
        id: res['id'] as String,
        url: res['file_url'] as String? ?? '',
        title: res['title'] as String? ?? '',
        altText: res['title'] as String? ?? '',
        category: res['category'] as String? ?? 'General',
        fileSizeKb: ((res['file_size'] as num?)?.toInt() ?? 0) ~/ 1024,
        dimensions: res['dimensions'] as String? ?? '1920x1080',
        uploadedBy: res['uploaded_by'] as String? ?? 'Admin',
        uploadedAt: res['created_at']?.toString() ?? DateTime.now().toIso8601String(),
        usageCount: 1,
        usageReferences: const [],
      );
    } catch (e) {
      debugPrint('[SupabaseMediaRepository] getAssetById error: $e');
      return _fallback.getAssetById(id);
    }
  }

  @override
  Future<MediaAsset> addAsset(MediaAsset asset) async {
    try {
      await client.from(SupabaseConfig.tableMediaAssets).insert({
        'id': asset.id,
        'title': asset.title,
        'file_name': asset.id,
        'file_url': asset.url,
        'file_size': asset.fileSizeKb * 1024,
        'category': asset.category,
        'dimensions': asset.dimensions,
        'uploaded_by': asset.uploadedBy,
      });
      await _fallback.addAsset(asset);
      return asset;
    } catch (e) {
      debugPrint('[SupabaseMediaRepository] addAsset error: $e');
      return _fallback.addAsset(asset);
    }
  }

  @override
  Future<List<MediaAsset>> addAssets(List<MediaAsset> assets) async {
    for (final a in assets) {
      await addAsset(a);
    }
    return assets;
  }

  @override
  Future<MediaAsset> updateAsset(MediaAsset asset) async {
    try {
      await client.from(SupabaseConfig.tableMediaAssets).update({
        'title': asset.title,
        'category': asset.category,
        'dimensions': asset.dimensions,
      }).eq('id', asset.id);
      await _fallback.updateAsset(asset);
      return asset;
    } catch (e) {
      debugPrint('[SupabaseMediaRepository] updateAsset error: $e');
      return _fallback.updateAsset(asset);
    }
  }

  @override
  Future<bool> deleteAsset(String id) async {
    try {
      await client.from(SupabaseConfig.tableMediaAssets).delete().eq('id', id);
      return await _fallback.deleteAsset(id);
    } catch (e) {
      debugPrint('[SupabaseMediaRepository] deleteAsset error: $e');
      return await _fallback.deleteAsset(id);
    }
  }

  @override
  Future<int> replaceAssetUrl({required String oldUrl, required String newUrl}) async {
    return _fallback.replaceAssetUrl(oldUrl: oldUrl, newUrl: newUrl);
  }
}
