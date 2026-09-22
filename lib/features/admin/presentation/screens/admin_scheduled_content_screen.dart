import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_empty_state.dart';

class ScheduledItem {
  final String id;
  final String title;
  final String component;
  final DateTime startDate;
  final DateTime endDate;
  final bool isEnabled;

  const ScheduledItem({
    required this.id,
    required this.title,
    required this.component,
    required this.startDate,
    required this.endDate,
    this.isEnabled = true,
  });

  String get dynamicStatus {
    if (!isEnabled) return 'Draft';
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 'Scheduled';
    if (now.isAfter(endDate)) return 'Expired';
    return 'Active';
  }

  ScheduledItem copyWith({
    String? title,
    String? component,
    DateTime? startDate,
    DateTime? endDate,
    bool? isEnabled,
  }) {
    return ScheduledItem(
      id: id,
      title: title ?? this.title,
      component: component ?? this.component,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

class AdminScheduledContentScreen extends StatefulWidget {
  const AdminScheduledContentScreen({super.key});

  @override
  State<AdminScheduledContentScreen> createState() => _AdminScheduledContentScreenState();
}

class _AdminScheduledContentScreenState extends State<AdminScheduledContentScreen> {
  String _filter = 'all';
  final List<ScheduledItem> _items = [
    ScheduledItem(
      id: 'sch_1',
      title: 'Ganeshotsav 2026 Special Circuits',
      component: 'Hero Slide Banner',
      startDate: DateTime.now().add(const Duration(days: 14)),
      endDate: DateTime.now().add(const Duration(days: 24)),
      isEnabled: true,
    ),
    ScheduledItem(
      id: 'sch_2',
      title: 'Monsoon Sahyadri Trek Discount 20%',
      component: 'Promotional Banner',
      startDate: DateTime.now().subtract(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 12)),
      isEnabled: true,
    ),
    ScheduledItem(
      id: 'sch_3',
      title: 'Shivaji Maharaj Jayanti Exhibition',
      component: 'Tour Package Feature',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now().subtract(const Duration(days: 20)),
      isEnabled: true,
    ),
    ScheduledItem(
      id: 'sch_4',
      title: 'Pune Heritage Week Celebration',
      component: 'Notice Alert',
      startDate: DateTime.now().add(const Duration(days: 45)),
      endDate: DateTime.now().add(const Duration(days: 52)),
      isEnabled: false,
    ),
  ];

  void _showAddEditDialog([ScheduledItem? existing]) {
    final isEditing = existing != null;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    String component = existing?.component ?? 'Hero Slide Banner';
    DateTime start = existing?.startDate ?? DateTime.now().add(const Duration(days: 1));
    DateTime end = existing?.endDate ?? DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEditing ? 'Edit Scheduled Content' : 'Schedule New Campaign Content',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Campaign Title', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'e.g. Diwali Heritage Illuminations 2026',
                    hintStyle: const TextStyle(color: Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Target Placement Component', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: component,
                  dropdownColor: const Color(0xFF0F172A),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Hero Slide Banner', child: Text('Hero Slide Banner')),
                    DropdownMenuItem(value: 'Promotional Banner', child: Text('Promotional Banner')),
                    DropdownMenuItem(value: 'Tour Package Feature', child: Text('Tour Package Feature')),
                    DropdownMenuItem(value: 'Notice Alert', child: Text('Notice Alert')),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => component = val);
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Start Date', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF334155)),
                              backgroundColor: const Color(0xFF0F172A),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: start,
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                              );
                              if (picked != null) setModalState(() => start = picked);
                            },
                            child: Text(start.toString().substring(0, 10)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('End Date', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF334155)),
                              backgroundColor: const Color(0xFF0F172A),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: end,
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                              );
                              if (picked != null) setModalState(() => end = picked);
                            },
                            child: Text(end.toString().substring(0, 10)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.emerald),
              onPressed: () {
                final title = titleCtrl.text.trim();
                if (title.isEmpty) return;
                Navigator.of(ctx).pop();

                setState(() {
                  if (isEditing) {
                    final idx = _items.indexWhere((i) => i.id == existing.id);
                    if (idx != -1) {
                      _items[idx] = existing.copyWith(title: title, component: component, startDate: start, endDate: end);
                    }
                  } else {
                    _items.add(ScheduledItem(
                      id: 'sch_${DateTime.now().millisecondsSinceEpoch}',
                      title: title,
                      component: component,
                      startDate: start,
                      endDate: end,
                    ));
                  }
                });
              },
              child: Text(isEditing ? 'Save' : 'Schedule', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = _items.where((item) {
      if (_filter == 'all') return true;
      return item.dynamicStatus.toLowerCase() == _filter.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AdminTheme.scaffoldBgDark : AdminTheme.scaffoldBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scheduled Content & Campaigns',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Automate publication windows for festival banners, seasonal specials, and emergency advisories.',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.emerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('New Scheduled Event', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  onPressed: () => _showAddEditDialog(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Filter Chips
            Row(
              children: [
                _filterChip('All Events (${_items.length})', 'all'),
                const SizedBox(width: 8),
                _filterChip('Active Now', 'active'),
                const SizedBox(width: 8),
                _filterChip('Scheduled Future', 'scheduled'),
                const SizedBox(width: 8),
                _filterChip('Expired', 'expired'),
                const SizedBox(width: 8),
                _filterChip('Drafts', 'draft'),
              ],
            ),

            const SizedBox(height: 20),

            // Content List
            if (filtered.isEmpty)
              const AdminEmptyState(
                title: 'No Scheduled Content',
                message: 'There are no campaigns matching your selected filter.',
                icon: Icons.event_note_rounded,
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(color: Color(0xFF334155), height: 1),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final status = item.dynamicStatus;

                    Color statusColor = AdminTheme.saffron;
                    if (status == 'Active') statusColor = AdminTheme.emerald;
                    if (status == 'Expired') statusColor = Colors.grey;
                    if (status == 'Draft') statusColor = const Color(0xFF3B82F6);

                    return Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.schedule_rounded, color: statusColor, size: 22),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                                      ),
                                      child: Text(
                                        status.toUpperCase(),
                                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Placement: ${item.component} • Window: ${item.startDate.toString().substring(0, 10)} to ${item.endDate.toString().substring(0, 10)}',
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: Color(0xFF94A3B8), size: 18),
                            onPressed: () => _showAddEditDialog(item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AdminTheme.crimson, size: 18),
                            onPressed: () {
                              setState(() => _items.removeWhere((i) => i.id == item.id));
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = _filter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF94A3B8),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      selected: isSelected,
      selectedColor: AdminTheme.emerald,
      backgroundColor: const Color(0xFF0F172A),
      side: BorderSide(color: isSelected ? AdminTheme.emerald : const Color(0xFF334155)),
      onSelected: (_) => setState(() => _filter = value),
    );
  }
}
