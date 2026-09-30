import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/models/destination.dart';
import '../widgets/admin_multi_image_picker.dart';

class AdminDestinationsScreen extends ConsumerStatefulWidget {
  const AdminDestinationsScreen({super.key});

  @override
  ConsumerState<AdminDestinationsScreen> createState() => _AdminDestinationsScreenState();
}

class _AdminDestinationsScreenState extends ConsumerState<AdminDestinationsScreen> {
  final _searchCtrl = TextEditingController();
  DestinationCategory? _selectedCategory;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showDestinationForm(BuildContext context, {Destination? destination}) {
    final isNew = destination == null;
    final nameCtrl = TextEditingController(text: destination?.name ?? '');
    final descCtrl = TextEditingController(text: destination?.description ?? '');
    final longDescCtrl = TextEditingController(text: destination?.longDescription ?? '');
    final cityCtrl = TextEditingController(text: destination?.city ?? 'Pune');
    final feeIndianCtrl = TextEditingController(text: destination?.entryFeeIndian.toString() ?? '25');
    final feeForeignCtrl = TextEditingController(text: destination?.entryFeeForeign.toString() ?? '300');
    final hoursCtrl = TextEditingController(text: destination?.openingHours ?? '8:00 AM – 6:30 PM');
    final bestTimeCtrl = TextEditingController(text: destination?.bestTime ?? 'October to March');
    List<String> currentImages = List<String>.from(destination?.images ?? []);
    DestinationCategory cat = destination?.category ?? DestinationCategory.forts;
    bool isTrending = destination?.isTrending ?? true;
    bool isFeatured = destination?.isFeatured ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isNew ? 'Create New Destination' : 'Edit ${destination.name}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          content: SizedBox(
            width: 620,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildField('Destination Name', nameCtrl),
                  const SizedBox(height: 12),
                  _buildCategoryPicker(cat, (newCat) => setDialogState(() => cat = newCat)),
                  const SizedBox(height: 12),
                  _buildField('Short Summary', descCtrl, maxLines: 2),
                  const SizedBox(height: 12),
                  _buildField('Detailed Heritage Story', longDescCtrl, maxLines: 3),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildField('Indian Entry Fee (₹)', feeIndianCtrl, isNumber: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField('Foreign Entry Fee (₹)', feeForeignCtrl, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildField('Opening Hours', hoursCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField('Best Visiting Season', bestTimeCtrl)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AdminMultiImagePicker(
                    initialImages: currentImages,
                    title: 'Destination Photo Gallery',
                    subtitle: 'Add multiple photos, set primary cover, or import from media library.',
                    onImagesChanged: (updated) {
                      setDialogState(() => currentImages = List<String>.from(updated));
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SwitchListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Featured', style: TextStyle(color: Colors.white, fontSize: 12)),
                          value: isFeatured,
                          activeThumbColor: AppColors.emerald,
                          onChanged: (val) => setDialogState(() => isFeatured = val),
                        ),
                      ),
                      Expanded(
                        child: SwitchListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Trending', style: TextStyle(color: Colors.white, fontSize: 12)),
                          value: isTrending,
                          activeThumbColor: AppColors.saffron,
                          onChanged: (val) => setDialogState(() => isTrending = val),
                        ),
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
                final updatedDest = Destination(
                  id: destination?.id ?? 'dest_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  city: cityCtrl.text.trim(),
                  state: 'Pune District',
                  category: cat,
                  description: descCtrl.text.trim(),
                  longDescription: longDescCtrl.text.trim(),
                  images: currentImages.isNotEmpty
                      ? currentImages
                      : ['https://images.unsplash.com/photo-1599661046289-e31897846e41?q=80&w=1200'],
                  rating: destination?.rating ?? 4.8,
                  reviewCount: destination?.reviewCount ?? 150,
                  latitude: destination?.latitude ?? 18.5204,
                  longitude: destination?.longitude ?? 73.8567,
                  entryFeeIndian: double.tryParse(feeIndianCtrl.text.trim()) ?? 0.0,
                  entryFeeForeign: double.tryParse(feeForeignCtrl.text.trim()) ?? 0.0,
                  bestTime: bestTimeCtrl.text.trim(),
                  openingHours: hoursCtrl.text.trim(),
                  recommendedDuration: destination?.recommendedDuration ?? '2-3 hours',
                  famousFor: destination?.famousFor ?? 'Heritage, Architecture',
                  difficulty: destination?.difficulty ?? DifficultyLevel.easy,
                  distanceFromPuneKm: destination?.distanceFromPuneKm ?? 5.0,
                  isTrending: isTrending,
                  isFeatured: isFeatured,
                  attractions: destination?.attractions ?? const [],
                  foods: destination?.foods ?? const [],
                  hotels: destination?.hotels ?? const [],
                  travelTips: destination?.travelTips ?? const [],
                );

                Navigator.of(ctx).pop();
                try {
                  final notifier = ref.read(destinationsCatalogProvider.notifier);
                  if (isNew) {
                    await notifier.addDestination(updatedDest);
                  } else {
                    await notifier.updateDestination(updatedDest);
                  }

                  try {
                    final admin = ref.read(adminSessionProvider);
                    await ref.read(auditLogsProvider.notifier).log(
                      actorEmail: admin.email.isNotEmpty ? admin.email : 'admin@puneexplorer.in',
                      actorRole: admin.role,
                      action: isNew ? 'CREATE_DESTINATION' : 'UPDATE_DESTINATION',
                      resourceType: 'DESTINATION',
                      resourceId: updatedDest.id,
                      metadata: {'name': updatedDest.name, 'category': updatedDest.category.name},
                    );
                  } catch (_) {}

                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Destination "${updatedDest.name}" saved! Changes live across app.'),
                        backgroundColor: AppColors.emerald,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Notice: Local cache updated. Cloud notice: $e'),
                        backgroundColor: Colors.amber.shade900,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                }
              },
              child: const Text('Save Destination', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {int maxLines = 1, bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
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

  Widget _buildCategoryPicker(DestinationCategory current, ValueChanged<DestinationCategory> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Destination Category', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<DestinationCategory>(
              value: current,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              items: DestinationCategory.values.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat.name.toUpperCase()));
              }).toList(),
              onChanged: (cat) {
                if (cat != null) onChanged(cat);
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final destinationsAsync = ref.watch(destinationsAsyncProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Action Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Destinations & Heritage Monuments', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                      SizedBox(height: 4),
                      Text('Manage official monuments, forts, entry ticketing fees, and visitor information.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text('Add Destination', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  onPressed: () => _showDestinationForm(context),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Search & Category Filter Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                      hintText: 'Search destinations by title, fort name, or city...',
                      hintStyle: const TextStyle(color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<DestinationCategory?>(
                      value: _selectedCategory,
                      hint: const Text('All Categories', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Categories')),
                        ...DestinationCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toUpperCase()))),
                      ],
                      onChanged: (cat) => setState(() => _selectedCategory = cat),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Destinations List
            destinationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.emerald)),
              error: (e, _) => Text('Error loading destinations: $e', style: const TextStyle(color: AppColors.error)),
              data: (destinations) {
                final query = _searchCtrl.text.trim().toLowerCase();
                final filtered = destinations.where((d) {
                  final matchesQuery = query.isEmpty || d.name.toLowerCase().contains(query) || d.city.toLowerCase().contains(query);
                  final matchesCat = _selectedCategory == null || d.category == _selectedCategory;
                  return matchesQuery && matchesCat;
                }).toList();

                if (filtered.isEmpty) {
                  final isCatalogEmpty = destinations.isEmpty;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_off_rounded, size: 48, color: Color(0xFF64748B)),
                        const SizedBox(height: 16),
                        Text(
                          isCatalogEmpty ? 'No Destinations in Database' : 'No Matching Destinations Found',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isCatalogEmpty
                              ? 'Your catalog is clean and ready. Add official Pune monuments, forts, and getaways.'
                              : 'Try clearing your search query or choosing "All Categories".',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        ),
                        if (isCatalogEmpty) ...[
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emerald,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.add, color: Colors.white, size: 18),
                            label: const Text('Add Your First Destination', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            onPressed: () => _showDestinationForm(context),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final dest = filtered[index];
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
                              child: dest.images.isNotEmpty
                                  ? Image.network(dest.images.first, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey))
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
                                        dest.name,
                                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                                            '${dest.images.length} photos',
                                            style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.emerald.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        dest.category.name.toUpperCase(),
                                        style: const TextStyle(color: AppColors.emerald, fontSize: 10, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(dest.description, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text('Entry: ₹${dest.entryFeeIndian} (Ind) / ₹${dest.entryFeeForeign} (For)', style: const TextStyle(color: AppColors.saffron, fontSize: 11, fontWeight: FontWeight.w700)),
                                    const SizedBox(width: 12),
                                    Text('• ${dest.openingHours}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: Colors.white70, size: 20),
                            tooltip: 'Edit Destination',
                            onPressed: () => _showDestinationForm(context, destination: dest),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                            tooltip: 'Delete Destination',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: const Color(0xFF1E293B),
                                  title: const Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Delete Destination Permanently?',
                                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Are you sure you want to permanently delete "${dest.name}"?',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                                        ),
                                        child: const Text(
                                          '⚠️ Warning: This action permanently removes this destination, its highlights, and food spots from Supabase. It cannot be undone.',
                                          style: TextStyle(color: Color(0xFFFCA5A5), fontSize: 12, height: 1.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      child: const Text('Delete Permanently', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                try {
                                  await ref.read(destinationsCatalogProvider.notifier).deleteDestination(dest.id);
                                  await ref.read(favoritesProvider.notifier).remove(dest.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Successfully deleted "${dest.name}" from database.'), backgroundColor: AppColors.emerald),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed to delete: $e'), backgroundColor: AppColors.error),
                                    );
                                  }
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
