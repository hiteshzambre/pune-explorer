import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_providers.dart';
import '../theme/admin_theme.dart';

/// Interactive global command search modal triggered by Ctrl + K or clicking search bar.
/// Searches across all entities: Destinations, Tours, Bookings, Payments, Users, FAQs.
class AdminGlobalSearchDialog extends ConsumerStatefulWidget {
  const AdminGlobalSearchDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => const AdminGlobalSearchDialog(),
    );
  }

  @override
  ConsumerState<AdminGlobalSearchDialog> createState() => _AdminGlobalSearchDialogState();
}

class _AdminGlobalSearchDialogState extends ConsumerState<AdminGlobalSearchDialog> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.trim().toLowerCase();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final destinations = ref.watch(destinationsAsyncProvider).value ?? [];
    final tours = ref.watch(tourPackagesAsyncProvider).value ?? [];
    final bookings = ref.watch(userBookingsProvider).value ?? [];
    final payments = ref.watch(paymentOrdersProvider).value ?? [];
    final users = ref.watch(allUsersProvider).value ?? [];

    final matchedDestinations = query.isEmpty
        ? []
        : destinations.where((d) => d.name.toLowerCase().contains(query) || d.category.label.toLowerCase().contains(query)).take(4).toList();

    final matchedTours = query.isEmpty
        ? []
        : tours.where((t) => t.title.toLowerCase().contains(query) || t.id.toLowerCase().contains(query)).take(4).toList();

    final matchedBookings = query.isEmpty
        ? []
        : bookings.where((b) => b.id.toLowerCase().contains(query) || b.customerName.toLowerCase().contains(query)).take(4).toList();

    final matchedPayments = query.isEmpty
        ? []
        : payments.where((p) => p.orderId.toLowerCase().contains(query) || (p.transactionId?.toLowerCase().contains(query) ?? false)).take(4).toList();

    final matchedUsers = query.isEmpty
        ? []
        : users.where((u) => u.name.toLowerCase().contains(query) || u.email.toLowerCase().contains(query)).take(4).toList();

    final allMatchesCount = matchedDestinations.length +
        matchedTours.length +
        matchedBookings.length +
        matchedPayments.length +
        matchedUsers.length;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 580),
        child: Column(
          children: [
            // Search Input Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AdminTheme.emerald, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      focusNode: _focusNode,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white : AdminTheme.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search destinations, tours, bookings, UTRs, users...',
                        hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('ESC', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Results List
            Expanded(
              child: query.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search, size: 40, color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                          const SizedBox(height: 12),
                          Text(
                            'Quick Admin Command Search',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white70 : AdminTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Type an order ID (PE-...), customer name, destination, or UTR number',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    )
                  : allMatchesCount == 0
                      ? Center(
                          child: Text(
                            'No admin records found for "$query"',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          children: [
                            if (matchedDestinations.isNotEmpty) ...[
                              _buildCategoryHeader('DESTINATIONS (${matchedDestinations.length})'),
                              ...matchedDestinations.map(
                                (d) => _buildResultItem(
                                  icon: Icons.castle_rounded,
                                  title: d.name,
                                  subtitle: '${d.category.label} • ${d.city}',
                                  route: '/admin/destinations',
                                  badge: 'Catalog',
                                  color: AdminTheme.emerald,
                                ),
                              ),
                            ],
                            if (matchedTours.isNotEmpty) ...[
                              _buildCategoryHeader('TOURS & PACKAGES (${matchedTours.length})'),
                              ...matchedTours.map(
                                (t) => _buildResultItem(
                                  icon: Icons.tour_rounded,
                                  title: t.title,
                                  subtitle: 'ID: ${t.id} • ₹${t.price.toInt()}',
                                  route: '/admin/tours',
                                  badge: 'Package',
                                  color: AdminTheme.sky,
                                ),
                              ),
                            ],
                            if (matchedBookings.isNotEmpty) ...[
                              _buildCategoryHeader('BOOKINGS (${matchedBookings.length})'),
                              ...matchedBookings.map(
                                (b) => _buildResultItem(
                                  icon: Icons.confirmation_number_rounded,
                                  title: '${b.customerName} (${b.id})',
                                  subtitle: '${b.tourTitle} • ₹${b.totalAmount.toInt()} • ${b.status.label}',
                                  route: '/admin/bookings',
                                  badge: b.status.name.toUpperCase(),
                                  color: AdminTheme.saffron,
                                ),
                              ),
                            ],
                            if (matchedPayments.isNotEmpty) ...[
                              _buildCategoryHeader('PAYMENTS & UTR (${matchedPayments.length})'),
                              ...matchedPayments.map(
                                (p) => _buildResultItem(
                                  icon: Icons.verified_user_rounded,
                                  title: 'Order ${p.orderId} • ₹${p.amount.toInt()}',
                                  subtitle: 'UTR: ${p.transactionId ?? "Pending"} • ${p.status.name}',
                                  route: '/admin/payments',
                                  badge: p.status.name.toUpperCase(),
                                  color: AdminTheme.purple,
                                ),
                              ),
                            ],
                            if (matchedUsers.isNotEmpty) ...[
                              _buildCategoryHeader('USERS & ACCOUNTS (${matchedUsers.length})'),
                              ...matchedUsers.map(
                                (u) => _buildResultItem(
                                  icon: Icons.person_rounded,
                                  title: u.name,
                                  subtitle: '${u.email} • ${u.phone}',
                                  route: '/admin/users',
                                  badge: 'User',
                                  color: AdminTheme.indigo,
                                ),
                              ),
                            ],
                          ],
                        ),
            ),

            const Divider(height: 1),

            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Use Enter to navigate • ESC to close',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  Text(
                    'Matches: $allMatchesCount',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AdminTheme.emerald),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildResultItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required String badge,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      dense: true,
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : AdminTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: isDark ? AdminTheme.textSecondaryDark : AdminTheme.textSecondary),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          badge,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        context.go(route);
      },
    );
  }
}
