import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/models/cms_models.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_confirm_dialog.dart';
import '../widgets/admin_empty_state.dart';

class AdminNotificationsScreen extends ConsumerStatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  ConsumerState<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends ConsumerState<AdminNotificationsScreen> {
  void _showAnnouncementDialog(BuildContext context, {AnnouncementItem? item}) {
    final isNew = item == null;
    final titleCtrl = TextEditingController(text: item?.title ?? '');
    final msgCtrl = TextEditingController(text: item?.message ?? '');
    final badgeCtrl = TextEditingController(text: item?.badgeText ?? 'ALERT');
    final linkCtrl = TextEditingController(text: item?.linkUrl ?? '/explore');
    String priority = item?.priority ?? 'info';
    String audience = 'All Registered Travelers';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(isNew ? Icons.campaign_rounded : Icons.edit_note_rounded, color: AdminTheme.emerald, size: 22),
              const SizedBox(width: 8),
              Text(
                isNew ? 'Broadcast New Notice' : 'Edit Notice',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ],
          ),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildField('Announcement Title', titleCtrl),
                  const SizedBox(height: 12),
                  _buildField('Detailed Message', msgCtrl, maxLines: 2),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildField('Badge Tag', badgeCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField('Link URL / Route', linkCtrl)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Priority Level', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: priority,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF1E293B),
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                  items: const [
                                    DropdownMenuItem(value: 'info', child: Text('INFO (Blue)')),
                                    DropdownMenuItem(value: 'warning', child: Text('WARNING (Saffron)')),
                                    DropdownMenuItem(value: 'urgent', child: Text('URGENT (Red)')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setDialogState(() => priority = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Target Audience', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: audience,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF1E293B),
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                  items: const [
                                    DropdownMenuItem(value: 'All Registered Travelers', child: Text('All Travelers')),
                                    DropdownMenuItem(value: 'Recent Bookers', child: Text('Recent Bookers')),
                                    DropdownMenuItem(value: 'Staff & Admins', child: Text('Staff & Admins')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setDialogState(() => audience = val);
                                  },
                                ),
                              ),
                            ),
                          ],
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
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.emerald),
              onPressed: () async {
                final newItem = AnnouncementItem(
                  id: item?.id ?? 'ann_${DateTime.now().millisecondsSinceEpoch}',
                  title: titleCtrl.text.trim(),
                  message: msgCtrl.text.trim(),
                  badgeText: badgeCtrl.text.trim(),
                  linkUrl: linkCtrl.text.trim(),
                  priority: priority,
                  createdAt: DateTime.now().toIso8601String(),
                );

                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(ctx).pop();
                await ref.read(cmsRepositoryProvider).saveAnnouncement(newItem);
                setState(() {});

                final admin = ref.read(adminSessionProvider);
                await ref.read(auditLogsProvider.notifier).log(
                  actorEmail: admin.email.isNotEmpty ? admin.email : 'admin@puneexplorer.in',
                  actorRole: admin.role,
                  action: 'BROADCAST_ANNOUNCEMENT',
                  resourceType: 'ANNOUNCEMENT',
                  resourceId: newItem.id,
                  metadata: {'title': newItem.title, 'priority': newItem.priority, 'audience': audience},
                );

                if (mounted) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Notice broadcasted to live application!'),
                      backgroundColor: AdminTheme.emerald,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Broadcast Notice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<AnnouncementItem>>(
      future: ref.read(cmsRepositoryProvider).getAnnouncements(),
      builder: (context, snapshot) {
        final announcements = snapshot.data ?? [];

        return Scaffold(
          backgroundColor: isDark ? AdminTheme.scaffoldBgDark : AdminTheme.scaffoldBg,
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
                        Text(
                          'Emergency Advisories & Announcements',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Publish live weather warnings, monsoon trekking advisories, and festival notifications.',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminTheme.emerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.campaign, size: 18),
                      label: const Text('Broadcast Notice', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      onPressed: () => _showAnnouncementDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (announcements.isEmpty)
                  const AdminEmptyState(
                    title: 'No Active Broadcasts',
                    message: 'There are no announcements currently published on the live application.',
                    icon: Icons.campaign_rounded,
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      final item = announcements[index];
                      Color badgeColor = const Color(0xFF3B82F6);
                      if (item.priority == 'warning') badgeColor = AdminTheme.saffron;
                      if (item.priority == 'urgent') badgeColor = AdminTheme.crimson;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                              child: Icon(Icons.campaign_rounded, color: badgeColor, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w800),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                                        child: Text(item.badgeText, style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.w900)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(item.message, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Link: ${item.linkUrl} • Broadcast: ${item.createdAt.length >= 10 ? item.createdAt.substring(0, 10) : item.createdAt}',
                                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AdminTheme.crimson, size: 20),
                              onPressed: () {
                                AdminConfirmDialog.show(
                                  context: context,
                                  title: 'Delete Announcement',
                                  message: 'Are you sure you want to remove announcement "${item.title}" from the live application?',
                                  confirmLabel: 'Delete Broadcast',
                                  confirmIcon: Icons.delete_forever_rounded,
                                  isDestructive: true,
                                  onConfirm: () async {
                                    await ref.read(cmsRepositoryProvider).deleteAnnouncement(item.id);
                                    setState(() {});
                                  },
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
          ),
        );
      },
    );
  }
}
