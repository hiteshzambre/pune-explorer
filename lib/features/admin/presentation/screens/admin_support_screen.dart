import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/models/admin_support_ticket.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_empty_state.dart';

class AdminSupportScreen extends ConsumerStatefulWidget {
  const AdminSupportScreen({super.key});

  @override
  ConsumerState<AdminSupportScreen> createState() => _AdminSupportScreenState();
}

class _AdminSupportScreenState extends ConsumerState<AdminSupportScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  AdminSupportTicket? _selectedTicket;
  final _replyCtrl = TextEditingController();

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  void _sendReply(String adminEmail) async {
    final text = _replyCtrl.text.trim();
    if (text.isEmpty || _selectedTicket == null) return;

    final updated = _selectedTicket!.copyWith(
      status: 'in_progress',
      updatedAt: DateTime.now().toIso8601String(),
      messages: [
        ..._selectedTicket!.messages,
        SupportMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          sender: 'agent',
          senderName: 'Support Agent',
          message: text,
          timestamp: DateTime.now().toIso8601String(),
        ),
      ],
    );

    await ref.read(adminSupportTicketsProvider.notifier).saveTicket(updated);
    _replyCtrl.clear();
    setState(() => _selectedTicket = updated);
  }

  void _updateStatus(String newStatus) async {
    if (_selectedTicket == null) return;
    await ref.read(adminSupportTicketsProvider.notifier).updateStatus(_selectedTicket!.id, newStatus);
    setState(() {
      _selectedTicket = _selectedTicket!.copyWith(status: newStatus, updatedAt: DateTime.now().toIso8601String());
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ticketsAsync = ref.watch(adminSupportTicketsProvider);
    final adminSession = ref.watch(adminSessionProvider);
    final adminEmail = adminSession.email.isNotEmpty ? adminSession.email : 'support@puneexplorer.in';

    return Scaffold(
      backgroundColor: isDark ? AdminTheme.scaffoldBgDark : AdminTheme.scaffoldBg,
      body: Padding(
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
                        'Customer Support & Help Desk',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Triage traveler questions, handle pickup rescheduling requests, and resolve booking inquiries.',
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Refresh Tickets', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                  onPressed: () => ref.refresh(adminSupportTicketsProvider),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Search and Status Filters
            Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                      hintText: 'Search tickets by subject, user email, or ID...',
                      hintStyle: const TextStyle(color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  ),
                ),
                const SizedBox(width: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    _filterChip('All Tickets', 'all'),
                    _filterChip('Open', 'open'),
                    _filterChip('In Progress', 'in_progress'),
                    _filterChip('Resolved', 'resolved'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Content Area: Split View (Ticket List + Details / Conversation Pane)
            Expanded(
              child: ticketsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AdminTheme.emerald)),
                error: (e, _) => Text('Error loading tickets: $e', style: const TextStyle(color: AdminTheme.crimson)),
                data: (tickets) {
                  final filtered = tickets.where((t) {
                    final matches = _searchQuery.isEmpty ||
                        t.subject.toLowerCase().contains(_searchQuery) ||
                        t.userEmail.toLowerCase().contains(_searchQuery) ||
                        t.id.toLowerCase().contains(_searchQuery);
                    if (!matches) return false;
                    if (_selectedFilter == 'all') return true;
                    return t.status == _selectedFilter;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const AdminEmptyState(
                      title: 'No Support Tickets Found',
                      message: 'There are no customer inquiries matching your current filter.',
                      icon: Icons.support_agent_rounded,
                    );
                  }

                  if (_selectedTicket == null && filtered.isNotEmpty) {
                    _selectedTicket = filtered.first;
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Tickets List
                      Expanded(
                        flex: 5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const Divider(color: Color(0xFF334155), height: 1),
                            itemBuilder: (context, idx) {
                              final t = filtered[idx];
                              final isCurrent = _selectedTicket?.id == t.id;

                              Color statusCol = AdminTheme.saffron;
                              if (t.status == 'resolved') statusCol = AdminTheme.emerald;
                              if (t.status == 'open') statusCol = const Color(0xFF3B82F6);

                              return InkWell(
                                onTap: () => setState(() => _selectedTicket = t),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  color: isCurrent ? AdminTheme.emerald.withValues(alpha: 0.1) : Colors.transparent,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(t.id, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: statusCol.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(t.status.toUpperCase(), style: TextStyle(color: statusCol, fontSize: 9.5, fontWeight: FontWeight.w800)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        t.subject,
                                        style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'From: ${t.userName} (${t.userEmail})',
                                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Ticket Conversation & Action Details
                      Expanded(
                        flex: 7,
                        child: _selectedTicket != null ? _buildTicketDetailsPane(adminEmail) : const SizedBox.shrink(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketDetailsPane(String adminEmail) {
    final ticket = _selectedTicket!;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Pane Header
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ticket.subject, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('Category: ${ticket.category} • Priority: ${ticket.priority.toUpperCase()}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    ],
                  ),
                ),
                // Status Dropdown
                DropdownButton<String>(
                  value: ticket.status,
                  dropdownColor: const Color(0xFF0F172A),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  items: const [
                    DropdownMenuItem(value: 'open', child: Text('Open')),
                    DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                    DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                    DropdownMenuItem(value: 'closed', child: Text('Closed')),
                  ],
                  onChanged: (val) {
                    if (val != null) _updateStatus(val);
                  },
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF334155), height: 1),

          // Messages Thread
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ticket.messages.length,
              itemBuilder: (context, idx) {
                final msg = ticket.messages[idx];
                return Align(
                  alignment: msg.isAgent ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: const BoxConstraints(maxWidth: 440),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: msg.isAgent ? AdminTheme.emerald.withValues(alpha: 0.2) : const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: msg.isAgent ? AdminTheme.emerald.withValues(alpha: 0.4) : const Color(0xFF334155),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              msg.senderName,
                              style: TextStyle(
                                color: msg.isAgent ? AdminTheme.emerald : Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 11.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              msg.timestamp.toString().substring(11, 16),
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          msg.content,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(color: Color(0xFF334155), height: 1),

          // Quick Reply Box
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Type reply to traveler...',
                      hintStyle: const TextStyle(color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendReply(adminEmail),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.emerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Reply', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                  onPressed: () => _sendReply(adminEmail),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
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
      backgroundColor: const Color(0xFF1E293B),
      side: BorderSide(color: isSelected ? AdminTheme.emerald : const Color(0xFF334155)),
      onSelected: (_) => setState(() => _selectedFilter = value),
    );
  }
}
