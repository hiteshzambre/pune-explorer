import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/models/cms_models.dart';

class AdminMediaLibraryScreen extends ConsumerStatefulWidget {
  const AdminMediaLibraryScreen({super.key});

  @override
  ConsumerState<AdminMediaLibraryScreen> createState() => _AdminMediaLibraryScreenState();
}

class _AdminMediaLibraryScreenState extends ConsumerState<AdminMediaLibraryScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showAddMediaModal(BuildContext context) {
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final altCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'Heritage & Forts');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Media to Asset Library', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField('Asset Title', titleCtrl, hint: 'e.g. Shaniwar Wada North Wall'),
              const SizedBox(height: 12),
              _buildField('Image Direct URL (https://...)', urlCtrl, hint: 'https://images.unsplash.com/...'),
              const SizedBox(height: 12),
              _buildField('Accessibility Alt Text', altCtrl, hint: 'Historic stone ramparts with sunset lighting'),
              const SizedBox(height: 12),
              _buildField('Media Category', catCtrl, hint: 'Heritage & Forts'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final url = urlCtrl.text.trim();
              if (url.isEmpty || !url.startsWith('http')) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Please enter a valid HTTP/HTTPS image URL.'), backgroundColor: AppColors.error),
                );
                return;
              }

              final newAsset = MediaAsset(
                id: 'med_${DateTime.now().millisecondsSinceEpoch}',
                url: url,
                title: titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : 'Pune Travel Asset',
                altText: altCtrl.text.trim(),
                category: catCtrl.text.trim(),
                uploadedAt: DateTime.now().toIso8601String(),
                fileSizeKb: 350,
                dimensions: '1920x1080',
                usageCount: 0,
              );

              Navigator.of(ctx).pop();
              await ref.read(mediaAssetsProvider.notifier).addAsset(newAsset);

              final admin = ref.read(adminSessionProvider);
              await ref.read(auditLogsProvider.notifier).log(
                actorEmail: admin.email.isNotEmpty ? admin.email : 'admin@puneexplorer.in',
                actorRole: admin.role,
                action: 'UPLOAD_MEDIA_ASSET',
                resourceType: 'MEDIA_LIBRARY',
                resourceId: newAsset.id,
                metadata: {'title': newAsset.title, 'url': newAsset.url},
              );

              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Media asset added to central library!'), backgroundColor: AppColors.emerald),
                );
              }
            },
            child: const Text('Add to Library', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showBatchImportModal(BuildContext context) {
    final urlsCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'Heritage & Forts');
    final prefixCtrl = TextEditingController(text: 'Pune Asset');
    int detectedCount = 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.library_add_rounded, color: AppColors.saffron, size: 20),
              SizedBox(width: 8),
              Text('Batch Import Multiple Media Assets', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: 540,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Paste multiple image URLs (separated by newlines or commas). Assets will be bulk-registered into the central library with auto-generated metadata.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: urlsCtrl,
                  maxLines: 6,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    hintText: 'https://images.unsplash.com/photo-1...\nhttps://images.unsplash.com/photo-2...\nhttps://images.unsplash.com/photo-3...',
                    hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                  ),
                  onChanged: (val) {
                    final split = val.split(RegExp(r'[\n,]+')).map((s) => s.trim()).where((s) => s.startsWith('http')).toList();
                    setModalState(() => detectedCount = split.length);
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Detected: $detectedCount valid URLs',
                  style: TextStyle(color: detectedCount > 0 ? AppColors.emerald : const Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _buildField('Title Prefix', prefixCtrl, hint: 'e.g. Sinhagad Fort')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildField('Category', catCtrl, hint: 'Heritage & Forts')),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.saffron),
              icon: const Icon(Icons.download_done_rounded, color: Colors.black, size: 18),
              label: Text(
                detectedCount > 0 ? 'Batch Import ($detectedCount) Assets' : 'Batch Import Assets',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
              ),
              onPressed: detectedCount == 0
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final split = urlsCtrl.text
                          .split(RegExp(r'[\n,]+'))
                          .map((s) => s.trim())
                          .where((s) => s.startsWith('http'))
                          .toList();

                      final prefix = prefixCtrl.text.trim().isNotEmpty ? prefixCtrl.text.trim() : 'Pune Asset';
                      final category = catCtrl.text.trim().isNotEmpty ? catCtrl.text.trim() : 'General';
                      final now = DateTime.now();

                      final newAssets = <MediaAsset>[];
                      for (int i = 0; i < split.length; i++) {
                        newAssets.add(
                          MediaAsset(
                            id: 'med_batch_${now.millisecondsSinceEpoch}_$i',
                            url: split[i],
                            title: split.length == 1 ? prefix : '$prefix ${i + 1}',
                            altText: '$prefix visual asset',
                            category: category,
                            uploadedAt: now.toIso8601String(),
                            fileSizeKb: 350 + (i * 20),
                            dimensions: '1920x1080',
                            usageCount: 0,
                          ),
                        );
                      }

                      Navigator.of(ctx).pop();
                      await ref.read(mediaAssetsProvider.notifier).addAssets(newAssets);

                      final admin = ref.read(adminSessionProvider);
                      await ref.read(auditLogsProvider.notifier).log(
                        actorEmail: admin.email.isNotEmpty ? admin.email : 'admin@puneexplorer.in',
                        actorRole: admin.role,
                        action: 'BATCH_IMPORT_MEDIA_ASSETS',
                        resourceType: 'MEDIA_LIBRARY',
                        resourceId: 'batch_${now.millisecondsSinceEpoch}',
                        metadata: {'count': newAssets.length, 'category': category},
                      );

                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(content: Text('Successfully imported ${newAssets.length} media assets into library!'), backgroundColor: AppColors.emerald),
                        );
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  void _showReplaceUrlModal(BuildContext context, MediaAsset asset) {
    final newUrlCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Replace Asset: ${asset.title}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Replacing this image will update references across the entire application where this asset is utilized.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
            const SizedBox(height: 14),
            _buildField('New Image URL', newUrlCtrl, hint: 'https://...'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
            onPressed: () async {
              final newUrl = newUrlCtrl.text.trim();
              if (newUrl.isEmpty || !newUrl.startsWith('http')) return;
              final messenger = ScaffoldMessenger.of(context);

              Navigator.of(ctx).pop();
              await ref.read(mediaAssetsProvider.notifier).replaceAssetUrl(oldUrl: asset.url, newUrl: newUrl);

              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Asset URL replaced across application!'), backgroundColor: AppColors.emerald),
                );
              }
            },
            child: const Text('Confirm Replace', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {String hint = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF64748B)),
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
    final assetsAsync = ref.watch(mediaAssetsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      body: SingleChildScrollView(
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
                      Text('Media Assets Library', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                      SizedBox(height: 4),
                      Text('Centralized high-resolution images, metadata, and consumer app references.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.saffron,
                        side: BorderSide(color: AppColors.saffron.withValues(alpha: 0.6)),
                      ),
                      icon: const Icon(Icons.library_add_rounded, size: 18),
                      label: const Text('Batch Import', style: TextStyle(fontWeight: FontWeight.w700)),
                      onPressed: () => _showBatchImportModal(context),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
                      icon: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white, size: 18),
                      label: const Text('Add Media', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      onPressed: () => _showAddMediaModal(context),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                hintText: 'Search media assets by title, category, or tags...',
                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            assetsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.emerald)),
              error: (e, _) => Text('Error loading media: $e', style: const TextStyle(color: AppColors.error)),
              data: (assets) {
                final query = _searchCtrl.text.trim().toLowerCase();
                final filtered = assets.where((a) {
                  return query.isEmpty || a.title.toLowerCase().contains(query) || a.category.toLowerCase().contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No media assets found.', style: TextStyle(color: Colors.grey)));
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final cols = constraints.maxWidth > 1000 ? 3 : constraints.maxWidth > 650 ? 2 : 1;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: cols,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.15,
                      children: filtered.map((asset) {
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                  child: Image.network(
                                    asset.url,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: const Color(0xFF0F172A),
                                      child: const Icon(Icons.broken_image, color: Colors.grey, size: 36),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(asset.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 2),
                                    Text('${asset.category} • ${asset.dimensions} • ${asset.fileSizeKb} KB', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Used in ${asset.usageCount} places', style: const TextStyle(color: AppColors.emerald, fontSize: 11, fontWeight: FontWeight.w700)),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.saffron, size: 18),
                                              tooltip: 'Replace Image Across App',
                                              onPressed: () => _showReplaceUrlModal(context, asset),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                                              tooltip: 'Delete Asset',
                                              onPressed: () async {
                                                await ref.read(mediaAssetsProvider.notifier).deleteAsset(asset.id);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
