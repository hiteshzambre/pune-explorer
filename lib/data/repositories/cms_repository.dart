import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cms_models.dart';

abstract class CmsRepository {
  Future<HomepageCmsConfig> getHomepageConfig();
  Future<void> saveHomepageConfig(HomepageCmsConfig config);

  Future<List<FaqItem>> getFaqs();
  Future<void> saveFaq(FaqItem faq);
  Future<void> deleteFaq(String id);

  Future<List<AnnouncementItem>> getAnnouncements();
  Future<void> saveAnnouncement(AnnouncementItem announcement);
  Future<void> deleteAnnouncement(String id);

  Future<List<SeoMetadata>> getAllSeo();
  Future<SeoMetadata?> getSeoForRoute(String routePath);
  Future<void> saveSeoMetadata(SeoMetadata seo);

  Future<void> resetToDefaults();
}

class LocalCmsRepository implements CmsRepository {
  static const String keyHomepageCms = 'pune_cms_homepage_config';
  static const String keyFaqs = 'pune_cms_faqs';
  static const String keyAnnouncements = 'pune_cms_announcements';
  static const String keySeo = 'pune_cms_seo_metadata';

  HomepageCmsConfig _cachedHomepage = HomepageCmsConfig.defaultSeed();
  final List<FaqItem> _inMemoryFaqs = [];
  final List<AnnouncementItem> _inMemoryAnnouncements = [];
  final List<SeoMetadata> _inMemorySeo = [];
  bool _isLoaded = false;

  Future<void> _loadFromStorage() async {
    if (_isLoaded) return;
    _isLoaded = true;
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(milliseconds: 60),
      );

      // 1. Homepage Config
      final rawHomepage = prefs.getString(keyHomepageCms);
      if (rawHomepage != null) {
        _cachedHomepage = HomepageCmsConfig.fromJson(jsonDecode(rawHomepage) as Map<String, dynamic>);
      }

      // 2. FAQs
      final rawFaqs = prefs.getString(keyFaqs);
      if (rawFaqs != null) {
        final List<dynamic> list = jsonDecode(rawFaqs);
        _inMemoryFaqs.clear();
        for (var item in list) {
          _inMemoryFaqs.add(FaqItem.fromJson(item as Map<String, dynamic>));
        }
      } else {
        _inMemoryFaqs.addAll([
          const FaqItem(
            id: 'faq_1',
            question: 'What is the reporting time for the daily Pune Darshan bus tour?',
            answer: 'Reporting time is 08:00 AM sharp at the Swargate Tourist Terminal. The air-conditioned luxury coach departs promptly at 08:30 AM.',
            category: 'Pune Darshan',
            sortOrder: 1,
            isPublished: true,
          ),
          const FaqItem(
            id: 'faq_2',
            question: 'Are monument tickets and fort entry fees included in the tour package?',
            answer: 'Yes! All individual destination entry passes for Shaniwar Wada, Aga Khan Palace, Raja Dinkar Kelkar Museum, and Sinhagad toll are covered in your package booking.',
            category: 'Booking & Tickets',
            sortOrder: 2,
            isPublished: true,
          ),
          const FaqItem(
            id: 'faq_3',
            question: 'How do Heritage Walks work?',
            answer: 'Heritage Walks are 2.5-hour leisurely walking experiences led by certified Pune historians. You will explore historic peths, wadas, and temples with included audio headsets.',
            category: 'Heritage Walks',
            sortOrder: 3,
            isPublished: true,
          ),
          const FaqItem(
            id: 'faq_4',
            question: 'What is the cancellation and refund policy?',
            answer: 'Free 100% cancellation up to 24 hours before scheduled departure. Cancellations within 24 hours incur a flat 15% administrative fee.',
            category: 'Cancellations',
            sortOrder: 4,
            isPublished: true,
          ),
        ]);
      }

      // 3. Announcements
      final rawAnnouncements = prefs.getString(keyAnnouncements);
      if (rawAnnouncements != null) {
        final List<dynamic> list = jsonDecode(rawAnnouncements);
        _inMemoryAnnouncements.clear();
        for (var item in list) {
          _inMemoryAnnouncements.add(AnnouncementItem.fromJson(item as Map<String, dynamic>));
        }
      } else {
        _inMemoryAnnouncements.addAll([
          const AnnouncementItem(
            id: 'ann_monsoon_01',
            title: 'Monsoon Ghat & Fort Trekking Advisory',
            message: 'Carry waterproof rain jackets and sturdy grip footwear when visiting Sinhagad Fort, Rajgad, and Tamhini Ghat.',
            badgeText: 'WEATHER ALERT',
            linkUrl: '/explore',
            isActive: true,
            priority: 'warning',
            createdAt: '2026-08-15T09:00:00Z',
          ),
          const AnnouncementItem(
            id: 'ann_ganpati_fest',
            title: 'Ganeshotsaw 2026 Special Heritage Darshan Passes',
            message: 'Experience the 5 Manache Ganpati temples with priority queue darshan wristbands.',
            badgeText: 'FESTIVAL SPECIAL',
            linkUrl: '/destination/dest_4',
            isActive: true,
            priority: 'info',
            createdAt: '2026-08-20T10:00:00Z',
          ),
        ]);
      }

      // 4. SEO Metadata
      final rawSeo = prefs.getString(keySeo);
      if (rawSeo != null) {
        final List<dynamic> list = jsonDecode(rawSeo);
        _inMemorySeo.clear();
        for (var item in list) {
          _inMemorySeo.add(SeoMetadata.fromJson(item as Map<String, dynamic>));
        }
      } else {
        _inMemorySeo.addAll([
          const SeoMetadata(
            routePath: '/home',
            pageTitle: 'PuneExplorer | Official Guide & Daily Pune Darshan Booking',
            metaDescription: 'Discover historic forts, heritage walks, culinary hotspots, and guided Pune Darshan bus tours with real-time seat reservation.',
            keywords: 'pune travel, pune darshan, shaniwar wada, sinhagad fort, heritage walks, maharashtra tourism',
            ogImageUrl: 'https://images.unsplash.com/photo-1599661046289-e31897846e41?q=80&w=1200',
          ),
          const SeoMetadata(
            routePath: '/darshan',
            pageTitle: 'Pune Darshan Daily AC Bus Tour Booking | PuneExplorer',
            metaDescription: 'Book daily AC electric bus tours covering 10 major Pune heritage sights with live onboard commentary and priority passes.',
            keywords: 'pune darshan bus booking, swargate tourist bus, pune sightseeing coach, dagdusheth darshan pass',
            ogImageUrl: 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?q=80&w=1200',
          ),
          const SeoMetadata(
            routePath: '/walks',
            pageTitle: 'Pune Heritage Walks & Old City Trails | PuneExplorer',
            metaDescription: 'Curated walking tours through historic Kasba, Shaniwar, and Budhwar Peths with certified local historians.',
            keywords: 'pune heritage walk, old pune walking tour, tulshibaug walk, peshwa trail',
            ogImageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=1200',
          ),
        ]);
      }
    } catch (_) {}
  }

  @override
  Future<HomepageCmsConfig> getHomepageConfig() async {
    await _loadFromStorage();
    return _cachedHomepage;
  }

  @override
  Future<void> saveHomepageConfig(HomepageCmsConfig config) async {
    await _loadFromStorage();
    _cachedHomepage = config;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyHomepageCms, jsonEncode(config.toJson()));
    } catch (_) {}
  }

  @override
  Future<List<FaqItem>> getFaqs() async {
    await _loadFromStorage();
    final sorted = List<FaqItem>.from(_inMemoryFaqs)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return List.unmodifiable(sorted);
  }

  @override
  Future<void> saveFaq(FaqItem faq) async {
    await _loadFromStorage();
    final index = _inMemoryFaqs.indexWhere((f) => f.id == faq.id);
    if (index >= 0) {
      _inMemoryFaqs[index] = faq;
    } else {
      _inMemoryFaqs.add(faq);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _inMemoryFaqs.map((f) => f.toJson()).toList();
      await prefs.setString(keyFaqs, jsonEncode(data));
    } catch (_) {}
  }

  @override
  Future<void> deleteFaq(String id) async {
    await _loadFromStorage();
    _inMemoryFaqs.removeWhere((f) => f.id == id);
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _inMemoryFaqs.map((f) => f.toJson()).toList();
      await prefs.setString(keyFaqs, jsonEncode(data));
    } catch (_) {}
  }

  @override
  Future<List<AnnouncementItem>> getAnnouncements() async {
    await _loadFromStorage();
    return List.unmodifiable(_inMemoryAnnouncements);
  }

  @override
  Future<void> saveAnnouncement(AnnouncementItem announcement) async {
    await _loadFromStorage();
    final index = _inMemoryAnnouncements.indexWhere((a) => a.id == announcement.id);
    if (index >= 0) {
      _inMemoryAnnouncements[index] = announcement;
    } else {
      _inMemoryAnnouncements.insert(0, announcement);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _inMemoryAnnouncements.map((a) => a.toJson()).toList();
      await prefs.setString(keyAnnouncements, jsonEncode(data));
    } catch (_) {}
  }

  @override
  Future<void> deleteAnnouncement(String id) async {
    await _loadFromStorage();
    _inMemoryAnnouncements.removeWhere((a) => a.id == id);
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _inMemoryAnnouncements.map((a) => a.toJson()).toList();
      await prefs.setString(keyAnnouncements, jsonEncode(data));
    } catch (_) {}
  }

  @override
  Future<List<SeoMetadata>> getAllSeo() async {
    await _loadFromStorage();
    return List.unmodifiable(_inMemorySeo);
  }

  @override
  Future<SeoMetadata?> getSeoForRoute(String routePath) async {
    await _loadFromStorage();
    try {
      return _inMemorySeo.firstWhere((s) => s.routePath == routePath);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveSeoMetadata(SeoMetadata seo) async {
    await _loadFromStorage();
    final index = _inMemorySeo.indexWhere((s) => s.routePath == seo.routePath);
    if (index >= 0) {
      _inMemorySeo[index] = seo;
    } else {
      _inMemorySeo.add(seo);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _inMemorySeo.map((s) => s.toJson()).toList();
      await prefs.setString(keySeo, jsonEncode(data));
    } catch (_) {}
  }

  @override
  Future<void> resetToDefaults() async {
    _cachedHomepage = HomepageCmsConfig.defaultSeed();
    _inMemoryFaqs.clear();
    _inMemoryAnnouncements.clear();
    _inMemorySeo.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(keyHomepageCms);
      await prefs.remove(keyFaqs);
      await prefs.remove(keyAnnouncements);
      await prefs.remove(keySeo);
    } catch (_) {}
    _isLoaded = false;
    await _loadFromStorage();
  }
}
