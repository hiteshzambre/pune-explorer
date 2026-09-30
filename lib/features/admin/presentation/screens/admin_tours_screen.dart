import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/models/tour_package.dart';
import '../widgets/admin_multi_image_picker.dart';

class AdminToursScreen extends ConsumerStatefulWidget {
  const AdminToursScreen({super.key});

  @override
  ConsumerState<AdminToursScreen> createState() => _AdminToursScreenState();
}

class _AdminToursScreenState extends ConsumerState<AdminToursScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showTourForm(BuildContext context, {TourPackage? tour}) {
    final isNew = tour == null;
    final titleCtrl = TextEditingController(text: tour?.title ?? '');
    final subtitleCtrl = TextEditingController(text: tour?.subtitle ?? '');
    final priceCtrl = TextEditingController(text: tour?.price.toString() ?? '649');
    final originalPriceCtrl = TextEditingController(text: tour?.originalPrice.toString() ?? '899');
    final durationCtrl = TextEditingController(text: tour?.duration ?? 'Full Day (8 Hours)');
    final badgeCtrl = TextEditingController(text: tour?.badge ?? 'POPULAR');
    final categoryCtrl = TextEditingController(text: tour?.category ?? 'Sightseeing');
    List<String> currentImages = List<String>.from(tour?.images ?? []);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isNew ? 'Create Tour Package' : 'Edit Tour: ${tour.title}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          content: SizedBox(
            width: 580,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildField('Tour Title', titleCtrl),
                  const SizedBox(height: 12),
                  _buildField('Subtitle / Tagline', subtitleCtrl),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildField('Discounted Price (₹)', priceCtrl, isNumber: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField('Original Price (₹)', originalPriceCtrl, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildField('Duration', durationCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField('Badge Tag', badgeCtrl)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AdminMultiImagePicker(
                    initialImages: currentImages,
                    title: 'Tour Gallery Photos',
                    subtitle: 'Add coach, sight, and route photos for passenger preview.',
                    onImagesChanged: (updated) {
                      setDialogState(() => currentImages = List<String>.from(updated));
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
              onPressed: () async {
                final updated = TourPackage(
                  id: tour?.id ?? 'tour_${DateTime.now().millisecondsSinceEpoch}',
                  title: titleCtrl.text.trim(),
                  subtitle: subtitleCtrl.text.trim(),
                  destinationId: tour?.destinationId ?? 'dest_1',
                  destinationName: tour?.destinationName ?? 'Pune',
                  duration: durationCtrl.text.trim(),
                  price: double.tryParse(priceCtrl.text.trim()) ?? 499.0,
                  originalPrice: double.tryParse(originalPriceCtrl.text.trim()) ?? 799.0,
                  rating: tour?.rating ?? 4.9,
                  reviewCount: tour?.reviewCount ?? 850,
                  badge: badgeCtrl.text.trim(),
                  category: categoryCtrl.text.trim(),
                  images: currentImages.isNotEmpty ? currentImages : (tour?.images ?? ['https://images.unsplash.com/photo-1544735716-392fe2489ffa?q=80&w=1200']),
                inclusions: tour?.inclusions ?? ['AC Coach Travel', 'Certified Guide', 'Monument Passes', 'Mineral Water Bottle'],
                exclusions: tour?.exclusions ?? ['Personal Lunch/Snacks', 'Special Camera Permits'],
                highlights: tour?.highlights ?? ['Historic Maratha forts', 'Temple darshan passes'],
                itinerary: tour?.itinerary ?? const [],
                pickupPoints: tour?.pickupPoints ?? ['Swargate Bus Stand (08:00 AM)', 'Pune Station (08:30 AM)'],
              );

              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(ctx).pop();
              try {
                final notifier = ref.read(toursCatalogProvider.notifier);
                if (isNew) {
                  await notifier.addTourPackage(updated);
                } else {
                  await notifier.updateTourPackage(updated);
                }

                try {
                  final admin = ref.read(adminSessionProvider);
                  await ref.read(auditLogsProvider.notifier).log(
                    actorEmail: admin.email.isNotEmpty ? admin.email : 'admin@puneexplorer.in',
                    actorRole: admin.role,
                    action: isNew ? 'CREATE_TOUR' : 'UPDATE_TOUR',
                    resourceType: 'TOUR_PACKAGE',
                    resourceId: updated.id,
                    metadata: {'title': updated.title, 'price': updated.price},
                  );
                } catch (_) {}

                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Tour "${updated.title}" saved! Live pricing applied to booking flow.'), backgroundColor: AppColors.emerald),
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
            child: const Text('Save Tour', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final toursAsync = ref.watch(tourPackagesAsyncProvider);

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
                    Text('Tour Packages & Experiences', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                    SizedBox(height: 4),
                    Text('Manage pricing, itineraries, inclusions, and boarding points for all guided tours.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text('Add Tour Package', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  onPressed: () => _showTourForm(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                hintText: 'Search tours by title or destination...',
                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            toursAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.emerald)),
              error: (e, _) => Text('Error loading tours: $e', style: const TextStyle(color: AppColors.error)),
              data: (tours) {
                final query = _searchCtrl.text.trim().toLowerCase();
                final filtered = tours.where((t) => query.isEmpty || t.title.toLowerCase().contains(query)).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final tour = filtered[index];
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
                              child: tour.images.isNotEmpty
                                  ? Image.network(tour.images.first, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey))
                                  : const Icon(Icons.tour, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                   children: [
                                     Expanded(child: Text(tour.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800))),
                                     Container(
                                       padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                       decoration: BoxDecoration(
                                         color: const Color(0xFF0F172A),
                                         borderRadius: BorderRadius.circular(6),
                                         border: Border.all(color: const Color(0xFF334155)),
                                       ),
                                       child: Row(
                                         mainAxisSize: MainAxisSize.min,
                                         children: [
                                           const Icon(Icons.photo_library_rounded, color: AppColors.saffron, size: 11),
                                           const SizedBox(width: 4),
                                           Text(
                                             '${tour.images.length} photos',
                                             style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700),
                                           ),
                                         ],
                                       ),
                                     ),
                                     const SizedBox(width: 6),
                                     Container(
                                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                       decoration: BoxDecoration(color: AppColors.saffron.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                                       child: Text(tour.badge, style: const TextStyle(color: AppColors.saffron, fontSize: 10, fontWeight: FontWeight.w900)),
                                     ),
                                   ],
                                ),
                                const SizedBox(height: 4),
                                Text(tour.subtitle, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12), maxLines: 1),
                                const SizedBox(height: 6),
                                Text('Price: ₹${tour.price.toInt()} (MRP ₹${tour.originalPrice.toInt()}) • ${tour.duration}', style: const TextStyle(color: AppColors.emerald, fontSize: 12, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: Colors.white70, size: 20),
                            tooltip: 'Edit Tour',
                            onPressed: () => _showTourForm(context, tour: tour),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                            tooltip: 'Delete Tour',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: const Color(0xFF1E293B),
                                  title: const Text('Delete Tour Package?', style: TextStyle(color: Colors.white)),
                                  content: Text('Are you sure you want to remove "${tour.title}"?'),
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
                                await ref.read(toursCatalogProvider.notifier).deleteTourPackage(tour.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Deleted "${tour.title}"'), backgroundColor: AppColors.emerald),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
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
