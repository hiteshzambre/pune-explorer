import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/providers/app_providers.dart';

/// Reusable, Enterprise-Grade Multi-Image Gallery Manager for Admin Portal.
/// Supports thumbnail reordering, primary cover photo selection, single URL input,
/// multi-line batch URL pasting, and selection from the central Media Library.
class AdminMultiImagePicker extends ConsumerStatefulWidget {
  final List<String> initialImages;
  final ValueChanged<List<String>> onImagesChanged;
  final String title;
  final String subtitle;
  final int maxImages;

  const AdminMultiImagePicker({
    super.key,
    required this.initialImages,
    required this.onImagesChanged,
    this.title = 'Photo Gallery & Visual Assets',
    this.subtitle = 'First photo serves as the primary cover card image. Drag or reorder as needed.',
    this.maxImages = 20,
  });

  @override
  ConsumerState<AdminMultiImagePicker> createState() => _AdminMultiImagePickerState();
}

class _AdminMultiImagePickerState extends ConsumerState<AdminMultiImagePicker> {
  late List<String> _images;

  @override
  void initState() {
    super.initState();
    _images = List<String>.from(widget.initialImages);
  }

  @override
  void didUpdateWidget(covariant AdminMultiImagePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialImages != widget.initialImages) {
      _images = List<String>.from(widget.initialImages);
    }
  }

  void _notifyChange() {
    setState(() {});
    widget.onImagesChanged(List<String>.unmodifiable(_images));
  }

  void _setAsPrimary(int index) {
    if (index <= 0 || index >= _images.length) return;
    final item = _images.removeAt(index);
    _images.insert(0, item);
    _notifyChange();
  }

  void _move(int fromIndex, int toIndex) {
    if (toIndex < 0 || toIndex >= _images.length) return;
    final item = _images.removeAt(fromIndex);
    _images.insert(toIndex, item);
    _notifyChange();
  }

  void _remove(int index) {
    if (index < 0 || index >= _images.length) return;
    _images.removeAt(index);
    _notifyChange();
  }

  void _addImages(List<String> newUrls) {
    final filtered = newUrls
        .map((u) => u.trim())
        .where((u) => u.isNotEmpty && (u.startsWith('http://') || u.startsWith('https://')))
        .where((u) => !_images.contains(u))
        .toList();

    if (filtered.isEmpty) return;

    final availableSlots = widget.maxImages - _images.length;
    if (availableSlots <= 0) return;

    _images.addAll(filtered.take(availableSlots));
    _notifyChange();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header & Counter Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.collections_rounded, color: AppColors.emerald, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          widget.title,
                          style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _images.isEmpty ? Colors.amber.withValues(alpha: 0.15) : AppColors.emerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _images.isEmpty ? Colors.amber.withValues(alpha: 0.4) : AppColors.emerald.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '${_images.length} / ${widget.maxImages} Photos',
                  style: TextStyle(
                    color: _images.isEmpty ? Colors.amber : AppColors.emerald,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Action Toolbar: Single URL, Batch Paste, Media Library Picker
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActionButton(
                icon: Icons.add_photo_alternate_rounded,
                label: 'Add URL',
                onTap: () => _showAddSingleUrlDialog(context),
                accentColor: AppColors.emerald,
              ),
              _buildActionButton(
                icon: Icons.library_add_rounded,
                label: 'Batch Paste URLs',
                onTap: () => _showBatchPasteDialog(context),
                accentColor: AppColors.saffron,
              ),
              _buildActionButton(
                icon: Icons.perm_media_rounded,
                label: 'From Media Library',
                onTap: () => _showMediaLibrarySelector(context),
                accentColor: Colors.blueAccent,
              ),
              if (_images.isNotEmpty)
                _buildActionButton(
                  icon: Icons.delete_sweep_rounded,
                  label: 'Clear All',
                  onTap: () {
                    _images.clear();
                    _notifyChange();
                  },
                  accentColor: AppColors.error,
                  isDestructive: true,
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Image Gallery Grid / Empty State
          if (_images.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155), style: BorderStyle.solid),
              ),
              child: const Column(
                children: [
                  Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF64748B), size: 36),
                  SizedBox(height: 8),
                  Text('No photos configured yet', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('Add single URLs, batch paste multi-line links, or pick from central library.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5), textAlign: TextAlign.center),
                ],
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _images.length,
              // ignore: deprecated_member_use
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex -= 1;
                _move(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final url = _images[index];
                final isCover = index == 0;

                return Container(
                  key: ValueKey('img_${url}_$index'),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCover ? AppColors.emerald : const Color(0xFF334155),
                      width: isCover ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Drag Handle
                      const Icon(Icons.drag_indicator_rounded, color: Color(0xFF64748B), size: 20),
                      const SizedBox(width: 8),

                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 64,
                          height: 52,
                          color: const Color(0xFF0F172A),
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.broken_image_rounded, color: Colors.white30, size: 24),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Index & URL Label
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isCover ? AppColors.emerald : const Color(0xFF334155),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isCover ? '★ PRIMARY COVER' : '#${index + 1}',
                                    style: TextStyle(
                                      color: isCover ? Colors.white : Colors.white70,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              url,
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Action Icons
                      if (!isCover)
                        IconButton(
                          icon: const Icon(Icons.star_border_rounded, color: AppColors.saffron, size: 19),
                          tooltip: 'Set as Primary Cover',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _setAsPrimary(index),
                        ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.white70, size: 19),
                        tooltip: 'Preview Full Size',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _showImagePreviewModal(context, url, index),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 19),
                        tooltip: 'Remove Image',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _remove(index),
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color accentColor,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accentColor.withValues(alpha: 0.35), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: accentColor, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSingleUrlDialog(BuildContext context) {
    final controller = TextEditingController();
    String previewUrl = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Image URL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'https://images.unsplash.com/...',
                  hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                ),
                onChanged: (val) => setModalState(() => previewUrl = val.trim()),
              ),
              const SizedBox(height: 12),
              if (previewUrl.isNotEmpty && previewUrl.startsWith('http'))
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 140,
                    color: const Color(0xFF0F172A),
                    child: Image.network(
                      previewUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text('Invalid image link', style: TextStyle(color: AppColors.error, fontSize: 12)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
              onPressed: () {
                final url = controller.text.trim();
                if (url.isNotEmpty && url.startsWith('http')) {
                  _addImages([url]);
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Add Photo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  void _showBatchPasteDialog(BuildContext context) {
    final controller = TextEditingController();
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
              Text('Batch Import Image URLs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Paste multiple image URLs separated by newlines or commas. You can add up to 20 images at once.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  maxLines: 6,
                  style: const TextStyle(color: Colors.white, fontSize: 12.5, fontFamily: 'monospace'),
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
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detected: $detectedCount valid URLs',
                      style: TextStyle(
                        color: detectedCount > 0 ? AppColors.emerald : const Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Remaining slots: ${widget.maxImages - _images.length}',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.saffron),
              icon: const Icon(Icons.file_download_done_rounded, color: Colors.black, size: 18),
              label: Text(
                detectedCount > 0 ? 'Import $detectedCount Photos' : 'Import Photos',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
              ),
              onPressed: detectedCount == 0
                  ? null
                  : () {
                      final split = controller.text
                          .split(RegExp(r'[\n,]+'))
                          .map((s) => s.trim())
                          .where((s) => s.startsWith('http'))
                          .toList();
                      _addImages(split);
                      Navigator.of(ctx).pop();
                    },
            ),
          ],
        ),
      ),
    );
  }

  void _showMediaLibrarySelector(BuildContext context) {
    final selectedUrls = <String>{};
    String filterQuery = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final assetsAsync = ref.watch(mediaAssetsProvider);

          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.perm_media_rounded, color: Colors.blueAccent, size: 20),
                    SizedBox(width: 8),
                    Text('Select from Central Media Library', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                  ],
                ),
                Text(
                  '${selectedUrls.length} selected',
                  style: const TextStyle(color: AppColors.emerald, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            content: SizedBox(
              width: 600,
              height: 450,
              child: Column(
                children: [
                  TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search assets by title or category...',
                      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 18),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                    ),
                    onChanged: (val) => setModalState(() => filterQuery = val.trim().toLowerCase()),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: assetsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.emerald)),
                      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.error))),
                      data: (assets) {
                        final filtered = assets.where((a) {
                          if (filterQuery.isEmpty) return true;
                          return a.title.toLowerCase().contains(filterQuery) ||
                              a.category.toLowerCase().contains(filterQuery) ||
                              a.altText.toLowerCase().contains(filterQuery);
                        }).toList();

                        if (filtered.isEmpty) {
                          return const Center(child: Text('No matching media assets found.', style: TextStyle(color: Color(0xFF94A3B8))));
                        }

                        return GridView.builder(
                          itemCount: filtered.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.1,
                          ),
                          itemBuilder: (context, idx) {
                            final asset = filtered[idx];
                            final isSelected = selectedUrls.contains(asset.url);
                            final alreadyAdded = _images.contains(asset.url);

                            return InkWell(
                              onTap: alreadyAdded
                                  ? null
                                  : () {
                                      setModalState(() {
                                        if (isSelected) {
                                          selectedUrls.remove(asset.url);
                                        } else {
                                          selectedUrls.add(asset.url);
                                        }
                                      });
                                    },
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.emerald
                                            : alreadyAdded
                                                ? Colors.white24
                                                : const Color(0xFF334155),
                                        width: isSelected ? 2.5 : 1,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(9),
                                      child: Image.network(
                                        asset.url,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: const Color(0xFF0F172A),
                                          child: const Icon(Icons.broken_image, color: Colors.white24),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Gradient info overlay
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(9)),
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [Colors.black.withValues(alpha: 0.85), Colors.transparent],
                                        ),
                                      ),
                                      child: Text(
                                        asset.title,
                                        style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  // Selection Indicator
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: alreadyAdded
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.7),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text('ADDED', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w800)),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isSelected ? AppColors.emerald : Colors.black45,
                                            ),
                                            child: Icon(
                                              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                              color: isSelected ? Colors.white : Colors.white70,
                                              size: 20,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
                icon: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                label: Text(
                  selectedUrls.isEmpty ? 'Insert Selected' : 'Insert ${selectedUrls.length} Photos',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                onPressed: selectedUrls.isEmpty
                    ? null
                    : () {
                        _addImages(selectedUrls.toList());
                        Navigator.of(ctx).pop();
                      },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showImagePreviewModal(BuildContext context, String url, int index) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text('Photo #${index + 1}${index == 0 ? ' (Primary Cover)' : ''}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                leading: IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white), onPressed: () => Navigator.of(ctx).pop()),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(child: Text('Could not load full size preview', style: TextStyle(color: AppColors.error))),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SelectableText(
                  url,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
