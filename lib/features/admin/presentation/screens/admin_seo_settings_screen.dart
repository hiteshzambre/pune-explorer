import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/models/cms_models.dart';

class AdminSeoSettingsScreen extends ConsumerStatefulWidget {
  const AdminSeoSettingsScreen({super.key});

  @override
  ConsumerState<AdminSeoSettingsScreen> createState() => _AdminSeoSettingsScreenState();
}

class _AdminSeoSettingsScreenState extends ConsumerState<AdminSeoSettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _siteNameCtrl = TextEditingController();
  final _helplineCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _heroTitleCtrl = TextEditingController();
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _siteNameCtrl.dispose();
    _helplineCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _heroTitleCtrl.dispose();
    super.dispose();
  }

  void _showSeoDialog(BuildContext context, SeoMetadata seo) {
    final titleCtrl = TextEditingController(text: seo.pageTitle);
    final descCtrl = TextEditingController(text: seo.metaDescription);
    final keysCtrl = TextEditingController(text: seo.keywords);
    final ogCtrl = TextEditingController(text: seo.ogImageUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('SEO: ${seo.routePath}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField('Browser Tab Title', titleCtrl),
            const SizedBox(height: 12),
            _buildField('Search Engine Meta Description', descCtrl, maxLines: 2),
            const SizedBox(height: 12),
            _buildField('Search Keywords (comma separated)', keysCtrl),
            const SizedBox(height: 12),
            _buildField('OpenGraph Social Share Image URL', ogCtrl),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final updated = seo.copyWith(
                pageTitle: titleCtrl.text.trim(),
                metaDescription: descCtrl.text.trim(),
                keywords: keysCtrl.text.trim(),
                ogImageUrl: ogCtrl.text.trim(),
              );
              Navigator.of(ctx).pop();
              await ref.read(cmsRepositoryProvider).saveSeoMetadata(updated);
              setState(() {});
              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(content: Text('SEO metadata updated for ${seo.routePath}!'), backgroundColor: AppColors.emerald),
                );
              }
            },
            child: const Text('Save SEO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final branding = ref.watch(brandingConfigProvider);
    if (!_isInit) {
      _siteNameCtrl.text = branding.siteName;
      _helplineCtrl.text = branding.touristHelpline;
      _phoneCtrl.text = branding.contactPhone;
      _emailCtrl.text = branding.contactEmail;
      _heroTitleCtrl.text = branding.heroHeadline;
      _isInit = true;
    }

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
              Tab(icon: Icon(Icons.tune_rounded, size: 18), text: 'Platform Brand & Helplines'),
              Tab(icon: Icon(Icons.language_rounded, size: 18), text: 'Route SEO & Social Cards'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Platform Brand & Helplines
          SingleChildScrollView(
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
                      const Text('Official App Branding & Helplines', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      const Text('Displayed throughout consumer footers, support cards, and contact menus.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      const SizedBox(height: 20),
                      _buildField('Application Name', _siteNameCtrl),
                      const SizedBox(height: 12),
                      _buildField('Official Tourist Helpline (e.g. 1363)', _helplineCtrl),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildField('Support Phone Number', _phoneCtrl)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildField('Support Email Address', _emailCtrl)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildField('Default Hero Headline', _heroTitleCtrl),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                        icon: const Icon(Icons.save_rounded, color: Colors.white, size: 18),
                        label: const Text('Save Brand Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        onPressed: () {
                          final current = ref.read(brandingConfigProvider);
                          ref.read(brandingConfigProvider.notifier).updateConfig(
                                current.copyWith(
                                  siteName: _siteNameCtrl.text.trim(),
                                  touristHelpline: _helplineCtrl.text.trim(),
                                  contactPhone: _phoneCtrl.text.trim(),
                                  contactEmail: _emailCtrl.text.trim(),
                                  heroHeadline: _heroTitleCtrl.text.trim(),
                                ),
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Branding settings updated across consumer platform!'), backgroundColor: AppColors.emerald),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Route SEO
          FutureBuilder<List<SeoMetadata>>(
            future: ref.read(cmsRepositoryProvider).getAllSeo(),
            builder: (context, snapshot) {
              final seoList = snapshot.data ?? [];
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Route-Level SEO & Social Share Cards', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    const Text('Manage search engine indexing, page titles, and OpenGraph link preview banners.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    const SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: seoList.length,
                      itemBuilder: (context, index) {
                        final seo = seoList[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: AppColors.emerald.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.language_rounded, color: AppColors.emerald, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(seo.routePath, style: const TextStyle(color: AppColors.saffron, fontSize: 13, fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 2),
                                    Text(seo.pageTitle, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 4),
                                    Text(seo.metaDescription, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12), maxLines: 1),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_rounded, color: Colors.white70, size: 20),
                                onPressed: () => _showSeoDialog(context, seo),
                              ),
                            ],
                          ),
                        );
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
}
