import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/models/cms_models.dart';

class AdminHomeCmsScreen extends ConsumerStatefulWidget {
  const AdminHomeCmsScreen({super.key});

  @override
  ConsumerState<AdminHomeCmsScreen> createState() => _AdminHomeCmsScreenState();
}

class _AdminHomeCmsScreenState extends ConsumerState<AdminHomeCmsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _noticeCtrl = TextEditingController();
  bool _noticeVisible = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noticeCtrl.dispose();
    super.dispose();
  }

  void _showSlideEditorDialog(BuildContext context, {HeroSlideItem? slide}) {
    final isNew = slide == null;
    final titleCtrl = TextEditingController(text: slide?.title ?? '');
    final subtitleCtrl = TextEditingController(text: slide?.subtitle ?? '');
    final imageCtrl = TextEditingController(text: slide?.imageUrl ?? '');
    final ctaLabelCtrl = TextEditingController(text: slide?.ctaLabel ?? 'Explore Now');
    final ctaRouteCtrl = TextEditingController(text: slide?.ctaRoute ?? '/explore');
    int sortOrder = slide?.sortOrder ?? 1;
    bool isActive = slide?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isNew ? 'Add New Hero Slide' : 'Edit Hero Slide',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDialogTextField('Slide Title / Headline', titleCtrl),
                  const SizedBox(height: 12),
                  _buildDialogTextField('Slide Subtitle / Description', subtitleCtrl, maxLines: 2),
                  const SizedBox(height: 12),
                  _buildDialogTextField('Image URL', imageCtrl),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildDialogTextField('CTA Button Label', ctaLabelCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDialogTextField('CTA Route (e.g. /explore)', ctaRouteCtrl)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Active on Home Screen:', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      Switch(
                        value: isActive,
                        activeThumbColor: AppColors.emerald,
                        onChanged: (val) => setDialogState(() => isActive = val),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final newSlide = HeroSlideItem(
                  id: slide?.id ?? 'slide_${DateTime.now().millisecondsSinceEpoch}',
                  imageUrl: imageCtrl.text.trim(),
                  title: titleCtrl.text.trim(),
                  subtitle: subtitleCtrl.text.trim(),
                  ctaLabel: ctaLabelCtrl.text.trim(),
                  ctaRoute: ctaRouteCtrl.text.trim(),
                  sortOrder: sortOrder,
                  isActive: isActive,
                );

                Navigator.of(ctx).pop();
                if (isNew) {
                  await ref.read(homepageCmsProvider.notifier).addSlide(newSlide);
                } else {
                  await ref.read(homepageCmsProvider.notifier).updateSlide(newSlide);
                }

                // Log audit
                final admin = ref.read(adminSessionProvider);
                await ref.read(auditLogsProvider.notifier).log(
                  actorEmail: admin.email.isNotEmpty ? admin.email : 'admin@puneexplorer.in',
                  actorRole: admin.role,
                  action: isNew ? 'CREATE_HERO_SLIDE' : 'UPDATE_HERO_SLIDE',
                  resourceType: 'HOMEPAGE_CMS',
                  resourceId: newSlide.id,
                  metadata: {'title': newSlide.title},
                );

                if (mounted) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Hero slide saved and updated in consumer app!'), backgroundColor: AppColors.emerald),
                  );
                }
              },
              child: const Text('Save Slide', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cmsAsync = ref.watch(homepageCmsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: const Color(0xFF0F172A),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.emerald,
            labelColor: AppColors.emerald,
            unselectedLabelColor: const Color(0xFF94A3B8),
            tabs: const [
              Tab(icon: Icon(Icons.view_carousel_rounded, size: 18), text: 'Hero Slides Carousel'),
              Tab(icon: Icon(Icons.campaign_rounded, size: 18), text: 'Promotional Banner & Notice'),
              Tab(icon: Icon(Icons.reorder_rounded, size: 18), text: 'Section Order & Visibility'),
            ],
          ),
        ),
      ),
      body: cmsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.emerald)),
        error: (e, _) => Center(child: Text('Error loading CMS: $e', style: const TextStyle(color: AppColors.error))),
        data: (cms) {
          return TabBarView(
            controller: _tabController,
            children: [
              // 1. Hero Slides
              _buildHeroSlidesTab(context, cms),

              // 2. Banner Notice
              _buildBannerNoticeTab(context, cms),

              // 3. Section Order & Visibility
              _buildSectionConfigTab(context, cms),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroSlidesTab(BuildContext context, HomepageCmsConfig cms) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hero Slides Manager', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('Manage dynamic rotating banners shown at the top of the Home screen.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text('Add Slide', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                onPressed: () => _showSlideEditorDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (cms.slides.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
              child: const Center(
                child: Text('No hero slides configured. Click "Add Slide" to create the first one.', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cms.slides.length,
              itemBuilder: (context, index) {
                final slide = cms.slides[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: slide.isActive ? const Color(0xFF334155) : AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 80,
                          height: 56,
                          color: const Color(0xFF0F172A),
                          child: slide.imageUrl.isNotEmpty
                              ? Image.network(slide.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey))
                              : const Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    slide.title,
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: slide.isActive ? AppColors.emerald.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    slide.isActive ? 'ACTIVE' : 'INACTIVE',
                                    style: TextStyle(
                                      color: slide.isActive ? AppColors.emerald : Colors.grey,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(slide.subtitle, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text('CTA: "${slide.ctaLabel}" → ${slide.ctaRoute}', style: const TextStyle(color: AppColors.saffron, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: Colors.white70, size: 20),
                        tooltip: 'Edit Slide',
                        onPressed: () => _showSlideEditorDialog(context, slide: slide),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                        tooltip: 'Delete Slide',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: const Color(0xFF1E293B),
                              title: const Text('Delete Hero Slide?', style: TextStyle(color: Colors.white)),
                              content: Text('Are you sure you want to remove "${slide.title}"?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await ref.read(homepageCmsProvider.notifier).deleteSlide(slide.id);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBannerNoticeTab(BuildContext context, HomepageCmsConfig cms) {
    if (_noticeCtrl.text.isEmpty && cms.noticeBanner.isNotEmpty) {
      _noticeCtrl.text = cms.noticeBanner;
      _noticeVisible = cms.showNoticeBanner;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Monsoon & Emergency Alert Banner', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('Displayed prominently across the top of the consumer application during special advisories.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Show Notice Banner on Live App:', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    Switch(
                      value: _noticeVisible,
                      activeThumbColor: AppColors.emerald,
                      onChanged: (val) => setState(() => _noticeVisible = val),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Banner Text Content:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _noticeCtrl,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.publish_rounded, color: Colors.white, size: 18),
                  label: const Text('Publish Banner Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final updated = cms.copyWith(
                      noticeBanner: _noticeCtrl.text.trim(),
                      showNoticeBanner: _noticeVisible,
                      lastUpdated: DateTime.now().toIso8601String(),
                    );
                    await ref.read(homepageCmsProvider.notifier).updateConfig(updated);
                    if (mounted) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Notice banner published to live application!'), backgroundColor: AppColors.emerald),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionConfigTab(BuildContext context, HomepageCmsConfig cms) {
    final cfg = cms.sectionConfig;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Home Screen Section Visibility', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('Enable or disable individual sections dynamically without releasing a code update.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                const SizedBox(height: 20),
                _buildSectionSwitch('Hero Carousel Section', cfg.showHero, (val) => _updateSection(cfg.copyWith(showHero: val), cms)),
                _buildSectionSwitch('Search & Quick Filter Bar', cfg.showSearch, (val) => _updateSection(cfg.copyWith(showSearch: val), cms)),
                _buildSectionSwitch('Categories Chips Section', cfg.showCategories, (val) => _updateSection(cfg.copyWith(showCategories: val), cms)),
                _buildSectionSwitch('Pune Darshan Daily Bus Spotlight Card', cfg.showDarshanSpotlight, (val) => _updateSection(cfg.copyWith(showDarshanSpotlight: val), cms)),
                _buildSectionSwitch('Trending & Heritage Destinations Grid', cfg.showTrendingDestinations, (val) => _updateSection(cfg.copyWith(showTrendingDestinations: val), cms)),
                _buildSectionSwitch('History & Timeline Section', cfg.showHistoryTimeline, (val) => _updateSection(cfg.copyWith(showHistoryTimeline: val), cms)),
                _buildSectionSwitch('Frequently Asked Questions & Reviews', cfg.showTestimonialsFaq, (val) => _updateSection(cfg.copyWith(showTestimonialsFaq: val), cms)),
                _buildSectionSwitch('App Footer & Helplines', cfg.showFooter, (val) => _updateSection(cfg.copyWith(showFooter: val), cms)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSwitch(String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          Switch(
            value: value,
            activeThumbColor: AppColors.emerald,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Future<void> _updateSection(SectionVisibilityConfig newCfg, HomepageCmsConfig cms) async {
    final updated = cms.copyWith(sectionConfig: newCfg, lastUpdated: DateTime.now().toIso8601String());
    await ref.read(homepageCmsProvider.notifier).updateConfig(updated);
  }
}
