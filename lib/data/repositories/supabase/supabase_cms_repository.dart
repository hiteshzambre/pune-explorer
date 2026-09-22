import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/cms_models.dart';
import '../cms_repository.dart';
import '../../../core/supabase/supabase_config.dart';

class SupabaseCmsRepository implements CmsRepository {
  final SupabaseClient? _client;
  final LocalCmsRepository _fallback = LocalCmsRepository();

  SupabaseCmsRepository([SupabaseClient? client])
      : _client = client ?? SupabaseConfig.client;

  SupabaseClient get client {
    final c = _client ?? SupabaseConfig.client;
    if (c == null) throw StateError('Supabase is not initialized.');
    return c;
  }

  @override
  Future<HomepageCmsConfig> getHomepageConfig() async {
    try {
      final res = await client
          .from(SupabaseConfig.tableHomepageSlides)
          .select()
          .eq('is_active', true)
          .order('display_order', ascending: true);

      final list = res as List<dynamic>;
      if (list.isEmpty) return await _fallback.getHomepageConfig();

      final slides = list.map((item) {
        return HeroSlideItem(
          id: item['id'] as String,
          title: item['title'] as String,
          subtitle: item['subtitle'] as String? ?? '',
          imageUrl: item['image_url'] as String? ?? '',
          ctaLabel: item['cta_text'] as String? ?? 'Explore Now',
          ctaRoute: item['cta_route'] as String? ?? '/explore',
          sortOrder: (item['display_order'] as num?)?.toInt() ?? 0,
        );
      }).toList();

      final fallbackConfig = await _fallback.getHomepageConfig();
      return fallbackConfig.copyWith(slides: slides);
    } catch (e) {
      debugPrint('[SupabaseCmsRepository] getHomepageConfig error: $e. Falling back.');
      return await _fallback.getHomepageConfig();
    }
  }

  @override
  Future<void> saveHomepageConfig(HomepageCmsConfig config) async {
    try {
      for (final slide in config.slides) {
        await client.from(SupabaseConfig.tableHomepageSlides).upsert({
          'id': slide.id,
          'title': slide.title,
          'subtitle': slide.subtitle,
          'image_url': slide.imageUrl,
          'cta_text': slide.ctaLabel,
          'cta_route': slide.ctaRoute,
          'display_order': slide.sortOrder,
          'is_active': true,
        });
      }
      await _fallback.saveHomepageConfig(config);
    } catch (e) {
      debugPrint('[SupabaseCmsRepository] saveHomepageConfig error: $e');
      await _fallback.saveHomepageConfig(config);
    }
  }

  @override
  Future<List<FaqItem>> getFaqs() async {
    try {
      final res = await client
          .from(SupabaseConfig.tableFaqs)
          .select()
          .eq('is_active', true)
          .order('display_order', ascending: true);

      final list = res as List<dynamic>;
      if (list.isEmpty) return await _fallback.getFaqs();

      return list.map((item) {
        return FaqItem(
          id: item['id'] as String,
          question: item['question'] as String,
          answer: item['answer'] as String,
          category: item['category'] as String? ?? 'General',
          sortOrder: (item['display_order'] as num?)?.toInt() ?? 0,
          isPublished: item['is_active'] as bool? ?? true,
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseCmsRepository] getFaqs error: $e');
      return await _fallback.getFaqs();
    }
  }

  @override
  Future<void> saveFaq(FaqItem faq) async {
    try {
      await client.from(SupabaseConfig.tableFaqs).upsert({
        'id': faq.id,
        'question': faq.question,
        'answer': faq.answer,
        'category': faq.category,
        'display_order': faq.sortOrder,
        'is_active': faq.isPublished,
      });
      await _fallback.saveFaq(faq);
    } catch (e) {
      debugPrint('[SupabaseCmsRepository] saveFaq error: $e');
      await _fallback.saveFaq(faq);
    }
  }

  @override
  Future<void> deleteFaq(String id) async {
    try {
      await client.from(SupabaseConfig.tableFaqs).delete().eq('id', id);
      await _fallback.deleteFaq(id);
    } catch (e) {
      debugPrint('[SupabaseCmsRepository] deleteFaq error: $e');
      await _fallback.deleteFaq(id);
    }
  }

  @override
  Future<List<AnnouncementItem>> getAnnouncements() async {
    try {
      final res = await client
          .from(SupabaseConfig.tableNotifications)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final list = res as List<dynamic>;
      if (list.isEmpty) return await _fallback.getAnnouncements();

      return list.map((item) {
        return AnnouncementItem(
          id: item['id'] as String,
          title: item['title'] as String,
          message: item['message'] as String,
          priority: item['priority'] as String? ?? 'info',
          isActive: item['is_active'] as bool? ?? true,
          createdAt: item['created_at']?.toString() ?? DateTime.now().toIso8601String(),
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseCmsRepository] getAnnouncements error: $e');
      return await _fallback.getAnnouncements();
    }
  }

  @override
  Future<void> saveAnnouncement(AnnouncementItem announcement) async {
    try {
      await client.from(SupabaseConfig.tableNotifications).upsert({
        'id': announcement.id,
        'title': announcement.title,
        'message': announcement.message,
        'category': announcement.priority,
        'is_active': announcement.isActive,
        'valid_from': announcement.createdAt,
      });
      await _fallback.saveAnnouncement(announcement);
    } catch (e) {
      debugPrint('[SupabaseCmsRepository] saveAnnouncement error: $e');
      await _fallback.saveAnnouncement(announcement);
    }
  }

  @override
  Future<void> deleteAnnouncement(String id) async {
    try {
      await client.from(SupabaseConfig.tableNotifications).delete().eq('id', id);
      await _fallback.deleteAnnouncement(id);
    } catch (e) {
      debugPrint('[SupabaseCmsRepository] deleteAnnouncement error: $e');
      await _fallback.deleteAnnouncement(id);
    }
  }

  @override
  Future<List<SeoMetadata>> getAllSeo() async => _fallback.getAllSeo();

  @override
  Future<SeoMetadata?> getSeoForRoute(String routePath) async => _fallback.getSeoForRoute(routePath);

  @override
  Future<void> saveSeoMetadata(SeoMetadata seo) async => _fallback.saveSeoMetadata(seo);

  @override
  Future<void> resetToDefaults() async => _fallback.resetToDefaults();
}
