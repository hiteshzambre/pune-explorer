import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/models/heritage_walk.dart';
import '../widgets/admin_multi_image_picker.dart';

class AdminHeritageWalksScreen extends ConsumerStatefulWidget {
  const AdminHeritageWalksScreen({super.key});

  @override
  ConsumerState<AdminHeritageWalksScreen> createState() => _AdminHeritageWalksScreenState();
}

class _AdminHeritageWalksScreenState extends ConsumerState<AdminHeritageWalksScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showWalkForm(BuildContext context, {HeritageWalk? walk}) {
    final isNew = walk == null;
    final titleCtrl = TextEditingController(text: walk?.title ?? '');
    final subtitleCtrl = TextEditingController(text: walk?.subtitle ?? '');
    final guideCtrl = TextEditingController(text: walk?.guideName ?? 'Dr. Mandar Lavate');
    final priceCtrl = TextEditingController(text: walk?.price.toString() ?? '299');
    final durationCtrl = TextEditingController(text: walk?.durationMinutes.toString() ?? '90');
    final distanceCtrl = TextEditingController(text: walk?.distanceKm.toString() ?? '2.5');
    List<String> currentImages = [
      if (walk?.coverImage != null && walk!.coverImage.isNotEmpty) walk.coverImage,
      ...?walk?.galleryImages,
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isNew ? 'Create Heritage Walk' : 'Edit Walk: ${walk.title}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          content: SizedBox(
            width: 580,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildField('Heritage Walk Title', titleCtrl),
                  const SizedBox(height: 12),
                  _buildField('Subtitle / Historic Context', subtitleCtrl),
                  const SizedBox(height: 12),
                  _buildField('Historian Guide Name', guideCtrl),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildField('Pass Price (₹)', priceCtrl, isNumber: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField('Duration (Minutes)', durationCtrl, isNumber: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField('Distance (km)', distanceCtrl, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AdminMultiImagePicker(
                    initialImages: currentImages,
                    title: 'Walk Cover & Gallery Photos',
                    subtitle: 'First image is the main route cover; others appear in the walk itinerary gallery.',
                    onImagesChanged: (updated) {
                      setDialogState(() => currentImages = List<String>.from(updated));
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
              onPressed: () async {
                final cover = currentImages.isNotEmpty ? currentImages.first : 'https://images.unsplash.com/photo-1599661046289-e31897846e41?q=80&w=1200';
                final gallery = currentImages.length > 1 ? currentImages.skip(1).toList() : <String>[];
                final updated = HeritageWalk(
                  id: walk?.id ?? 'walk_${DateTime.now().millisecondsSinceEpoch}',
                  title: titleCtrl.text.trim(),
                  marathiTitle: walk?.marathiTitle ?? '',
                  subtitle: subtitleCtrl.text.trim(),
                  category: walk?.category ?? HeritageWalkCategory.royalWadas,
                  coverImage: cover,
                  galleryImages: gallery,
                durationMinutes: int.tryParse(durationCtrl.text.trim()) ?? 90,
                distanceKm: double.tryParse(distanceCtrl.text.trim()) ?? 2.5,
                difficulty: walk?.difficulty ?? WalkDifficulty.easy,
                startLocationName: walk?.startLocationName ?? 'Shaniwar Wada Dilli Darwaza',
                endLocationName: walk?.endLocationName ?? 'Vishrambaug Wada',
                startLatitude: walk?.startLatitude ?? 18.5196,
                startLongitude: walk?.startLongitude ?? 73.8553,
                rating: walk?.rating ?? 4.9,
                reviewCount: walk?.reviewCount ?? 120,
                price: double.tryParse(priceCtrl.text.trim()) ?? 299.0,
                isSelfGuided: false,
                hasAudioGuide: true,
                bestTimeOfDay: walk?.bestTimeOfDay ?? WalkTimeOfDay.morning,
                bestDays: walk?.bestDays ?? 'Saturday & Sunday',
                highlights: walk?.highlights ?? ['Peshwa architecture', 'Secret courtyards'],
                included: walk?.included ?? ['Certified Historian Guide', 'Audio Headsets'],
                whatToBring: walk?.whatToBring ?? ['Comfortable shoes', 'Water bottle'],
                culturalEtiquette: walk?.culturalEtiquette ?? const [],
                localFoodPitstops: walk?.localFoodPitstops ?? const [],
                description: walk?.description ?? 'Guided historical walking trail.',
                historicalContext: walk?.historicalContext ?? '',
                stops: walk?.stops ?? const [],
                guideName: guideCtrl.text.trim(),
                guideRole: walk?.guideRole ?? 'Senior Heritage Historian',
                guideAvatar: walk?.guideAvatar ?? '',
                isFeatured: walk?.isFeatured ?? true,
              );

              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(ctx).pop();
              try {
                final notifier = ref.read(heritageWalksCatalogProvider.notifier);
                if (isNew) {
                  await notifier.addHeritageWalk(updated);
                } else {
                  await notifier.updateHeritageWalk(updated);
                }

                try {
                  final admin = ref.read(adminSessionProvider);
                  await ref.read(auditLogsProvider.notifier).log(
                    actorEmail: admin.email.isNotEmpty ? admin.email : 'admin@puneexplorer.in',
                    actorRole: admin.role,
                    action: isNew ? 'CREATE_HERITAGE_WALK' : 'UPDATE_HERITAGE_WALK',
                    resourceType: 'HERITAGE_WALK',
                    resourceId: updated.id,
                    metadata: {'title': updated.title, 'price': updated.price},
                  );
                } catch (_) {}

                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Heritage Walk "${updated.title}" saved! Live across app.'), backgroundColor: AppColors.emerald),
                  );
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Notice: $e'), backgroundColor: Colors.amber.shade900),
                  );
                }
              }
            },
            child: const Text('Save Walk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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
    return FutureBuilder<List<HeritageWalk>>(
      future: ref.read(destinationRepositoryProvider).getHeritageWalks(),
      builder: (context, snapshot) {
        final walks = snapshot.data ?? [];
        final query = _searchCtrl.text.trim().toLowerCase();
        final filtered = walks.where((w) => query.isEmpty || w.title.toLowerCase().contains(query)).toList();

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
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Heritage Walks & Old City Trails', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                        SizedBox(height: 4),
                        Text('Manage walking circuits, historian guides, audio guides, and ticketing passes.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
                      icon: const Icon(Icons.add, color: Colors.white, size: 18),
                      label: const Text('Add Heritage Walk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      onPressed: () => _showWalkForm(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                    hintText: 'Search heritage walks...',
                    hintStyle: const TextStyle(color: Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final walk = filtered[index];
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 80,
                              height: 64,
                              color: const Color(0xFF0F172A),
                              child: walk.coverImage.isNotEmpty
                                  ? Image.network(walk.coverImage, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey))
                                  : const Icon(Icons.directions_walk, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(walk.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 4),
                                Text(walk.subtitle, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12), maxLines: 1),
                                const SizedBox(height: 6),
                                Text('Guide: ${walk.guideName} • Price: ₹${walk.price.toInt()} • ${walk.durationFormatted} (${walk.distanceKm} km)', style: const TextStyle(color: AppColors.saffron, fontSize: 11.5, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: Colors.white70, size: 20),
                            tooltip: 'Edit Walk',
                            onPressed: () => _showWalkForm(context, walk: walk),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                            tooltip: 'Delete Walk',
                            onPressed: () async {
                              await ref.read(heritageWalksCatalogProvider.notifier).deleteHeritageWalk(walk.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Deleted "${walk.title}"'), backgroundColor: AppColors.emerald),
                                );
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
          ),
        );
      },
    );
  }
}
