import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cms_models.dart';

abstract class MediaLibraryRepository {
  Future<List<MediaAsset>> getAssets();
  Future<MediaAsset?> getAssetById(String id);
  Future<MediaAsset> addAsset(MediaAsset asset);
  Future<List<MediaAsset>> addAssets(List<MediaAsset> assets);
  Future<MediaAsset> updateAsset(MediaAsset asset);
  Future<bool> deleteAsset(String id);
  Future<int> replaceAssetUrl({required String oldUrl, required String newUrl});
}

class LocalMediaLibraryRepository implements MediaLibraryRepository {
  static const String keyMediaAssets = 'pune_cms_media_assets';
  final List<MediaAsset> _inMemoryAssets = [];
  bool _isLoaded = false;

  Future<void> _loadFromStorage() async {
    if (_isLoaded) return;
    _isLoaded = true;
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(milliseconds: 60),
      );
      final raw = prefs.getString(keyMediaAssets);
      if (raw != null) {
        final List<dynamic> list = jsonDecode(raw);
        _inMemoryAssets.clear();
        for (var item in list) {
          _inMemoryAssets.add(MediaAsset.fromJson(item as Map<String, dynamic>));
        }
      } else {
        // Bootstrap with verified PuneExplorer curated assets
        _inMemoryAssets.addAll([
          const MediaAsset(
            id: 'med_shaniwar_wada_main',
            url: 'https://images.unsplash.com/photo-1599661046289-e31897846e41?q=80&w=1200&auto=format&fit=crop',
            title: 'Shaniwar Wada Dilli Darwaza Grand Gate',
            altText: 'Monumental 18th century fortification gates of Shaniwar Wada',
            category: 'Heritage & Forts',
            fileSizeKb: 420,
            dimensions: '1920x1080',
            uploadedBy: 'admin@puneexplorer.in',
            uploadedAt: '2026-08-01T10:00:00Z',
            usageCount: 3,
            usageReferences: ['Shaniwar Wada (dest_1)', 'Homepage Hero Slide 1', 'Old Pune Heritage Walk'],
          ),
          const MediaAsset(
            id: 'med_sinhagad_fort_panoramic',
            url: 'https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272?q=80&w=1200&auto=format&fit=crop',
            title: 'Sinhagad Fort Sahyadri Mountain Ridge',
            altText: 'Panoramic mountain view of the Sinhagad Lion Fort ramparts',
            category: 'Heritage & Forts',
            fileSizeKb: 510,
            dimensions: '1920x1080',
            uploadedBy: 'admin@puneexplorer.in',
            uploadedAt: '2026-08-02T11:30:00Z',
            usageCount: 2,
            usageReferences: ['Sinhagad Fort (dest_2)', 'Homepage Hero Slide 2'],
          ),
          const MediaAsset(
            id: 'med_aga_khan_palace_italian',
            url: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=1200&auto=format&fit=crop',
            title: 'Aga Khan Palace Italian Arches',
            altText: 'Historic Italianate palace arches and tranquil manicured gardens',
            category: 'Museums & Palaces',
            fileSizeKb: 380,
            dimensions: '1600x900',
            uploadedBy: 'editor@puneexplorer.in',
            uploadedAt: '2026-08-03T14:15:00Z',
            usageCount: 2,
            usageReferences: ['Aga Khan Palace (dest_3)', 'Freedom Trail Tour'],
          ),
          const MediaAsset(
            id: 'med_dagdusheth_ganpati_gold',
            url: 'https://images.unsplash.com/photo-1563379091339-03246963d96c?q=80&w=1200&auto=format&fit=crop',
            title: 'Shrimant Dagdusheth Halwai Ganpati Idol',
            altText: 'Golden idol of Lord Ganesha in central Pune sanctum',
            category: 'Temples & Spiritual',
            fileSizeKb: 460,
            dimensions: '1200x800',
            uploadedBy: 'admin@puneexplorer.in',
            uploadedAt: '2026-08-04T09:00:00Z',
            usageCount: 2,
            usageReferences: ['Dagdusheth Temple (dest_4)', 'Pune Darshan Circuit Stop 1'],
          ),
          const MediaAsset(
            id: 'med_pune_darshan_bus_fleet',
            url: 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?q=80&w=1200&auto=format&fit=crop',
            title: 'Pune Darshan Electric AC Tourist Coach',
            altText: 'Modern AC sightseeing bus waiting at Swargate terminal',
            category: 'Tours & Transport',
            fileSizeKb: 340,
            dimensions: '1440x960',
            uploadedBy: 'ops@puneexplorer.in',
            uploadedAt: '2026-08-05T08:30:00Z',
            usageCount: 3,
            usageReferences: ['Pune Darshan Tour (PNE-DAR-01)', 'Homepage Hero Slide 3', 'Darshan Highlight Card'],
          ),
          const MediaAsset(
            id: 'med_pawna_lake_camping',
            url: 'https://images.unsplash.com/photo-1510312305653-8ed496efae75?q=80&w=1200&auto=format&fit=crop',
            title: 'Pawna Lake Waterside Sunset Tents',
            altText: 'Waterfront camping tents against Sahyadri twilight mountains',
            category: 'Nature & Lakes',
            fileSizeKb: 480,
            dimensions: '1920x1080',
            uploadedBy: 'editor@puneexplorer.in',
            uploadedAt: '2026-08-06T17:45:00Z',
            usageCount: 1,
            usageReferences: ['Pawna Lake & Dam (dest_6)'],
          ),
        ]);
      }
    } catch (_) {}
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _inMemoryAssets.map((a) => a.toJson()).toList();
      await prefs.setString(keyMediaAssets, jsonEncode(data));
    } catch (_) {}
  }

  @override
  Future<List<MediaAsset>> getAssets() async {
    await _loadFromStorage();
    return List.unmodifiable(_inMemoryAssets);
  }

  @override
  Future<MediaAsset?> getAssetById(String id) async {
    await _loadFromStorage();
    try {
      return _inMemoryAssets.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<MediaAsset> addAsset(MediaAsset asset) async {
    await _loadFromStorage();
    _inMemoryAssets.insert(0, asset);
    await _saveToStorage();
    return asset;
  }

  @override
  Future<List<MediaAsset>> addAssets(List<MediaAsset> assets) async {
    await _loadFromStorage();
    _inMemoryAssets.insertAll(0, assets);
    await _saveToStorage();
    return assets;
  }

  @override
  Future<MediaAsset> updateAsset(MediaAsset asset) async {
    await _loadFromStorage();
    final index = _inMemoryAssets.indexWhere((a) => a.id == asset.id);
    if (index >= 0) {
      _inMemoryAssets[index] = asset;
      await _saveToStorage();
    }
    return asset;
  }

  @override
  Future<bool> deleteAsset(String id) async {
    await _loadFromStorage();
    final count = _inMemoryAssets.length;
    _inMemoryAssets.removeWhere((a) => a.id == id);
    final deleted = _inMemoryAssets.length < count;
    if (deleted) {
      await _saveToStorage();
    }
    return deleted;
  }

  @override
  Future<int> replaceAssetUrl({required String oldUrl, required String newUrl}) async {
    await _loadFromStorage();
    int updatedCount = 0;
    for (int i = 0; i < _inMemoryAssets.length; i++) {
      if (_inMemoryAssets[i].url == oldUrl) {
        _inMemoryAssets[i] = _inMemoryAssets[i].copyWith(url: newUrl);
        updatedCount++;
      }
    }
    if (updatedCount > 0) {
      await _saveToStorage();
    }
    return updatedCount;
  }
}
