import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/models/booking.dart';

class AdminBookingsScreen extends ConsumerStatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  ConsumerState<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends ConsumerState<AdminBookingsScreen> {
  final _searchCtrl = TextEditingController();
  BookingStatus? _selectedStatus;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showBookingDetailsModal(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.confirmation_number_rounded, color: AppColors.emerald, size: 22),
            const SizedBox(width: 10),
            Text('Booking: ${booking.id}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Tour / Experience', booking.tourTitle),
              _buildDetailRow('Travel Date & Time', booking.travelDate),
              _buildDetailRow('Boarding Point', booking.pickupPoint),
              _buildDetailRow('Primary Traveler', '${booking.customerName} (${booking.customerPhone})'),
              _buildDetailRow('Email', booking.customerEmail),
              _buildDetailRow('Total Paid', '₹${booking.totalAmount.toInt()}'),
              _buildDetailRow('Status', booking.status.name.toUpperCase()),
              const SizedBox(height: 12),
              const Text('PASSENGERS & SEATS', style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              ...booking.passengers.map((p) => Text('• ${p.fullName} (Seat ${p.seatNumber}, Age ${p.age}, ${p.gender})', style: const TextStyle(color: Colors.white, fontSize: 12.5))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
          if (booking.status == BookingStatus.pending)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(ctx).pop();
                await ref.read(bookingRepositoryProvider).updateBookingStatus(booking.id, BookingStatus.confirmed);
                ref.invalidate(userBookingsProvider);

                final admin = ref.read(adminSessionProvider);
                await ref.read(auditLogsProvider.notifier).log(
                  actorEmail: admin.email.isNotEmpty ? admin.email : 'admin@puneexplorer.in',
                  actorRole: admin.role,
                  action: 'CONFIRM_BOOKING',
                  resourceType: 'BOOKING',
                  resourceId: booking.id,
                  metadata: {'customer': booking.customerName, 'tour': booking.tourTitle},
                );

                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('✅ Booking ${booking.id} confirmed successfully!'),
                      backgroundColor: AppColors.emerald,
                    ),
                  );
                }
              },
              child: const Text('Confirm Booking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          if (booking.status == BookingStatus.confirmed)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.skyBlue),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(ctx).pop();
                await ref.read(bookingRepositoryProvider).updateBookingStatus(booking.id, BookingStatus.completed);
                ref.invalidate(userBookingsProvider);

                final admin = ref.read(adminSessionProvider);
                await ref.read(auditLogsProvider.notifier).log(
                  actorEmail: admin.email.isNotEmpty ? admin.email : 'admin@puneexplorer.in',
                  actorRole: admin.role,
                  action: 'COMPLETE_BOOKING',
                  resourceType: 'BOOKING',
                  resourceId: booking.id,
                  metadata: {'customer': booking.customerName, 'tour': booking.tourTitle},
                );

                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Tour completed for booking ${booking.id}!'),
                      backgroundColor: AppColors.skyBlue,
                    ),
                  );
                }
              },
              child: const Text('Mark Completed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          if (booking.status != BookingStatus.cancelled)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(ctx).pop();
                await ref.read(bookingRepositoryProvider).updateBookingStatus(booking.id, BookingStatus.cancelled);
                ref.invalidate(userBookingsProvider);

                final admin = ref.read(adminSessionProvider);
                await ref.read(auditLogsProvider.notifier).log(
                  actorEmail: admin.email.isNotEmpty ? admin.email : 'admin@puneexplorer.in',
                  actorRole: admin.role,
                  action: 'CANCEL_BOOKING',
                  resourceType: 'BOOKING',
                  resourceId: booking.id,
                  metadata: {'customer': booking.customerName, 'tour': booking.tourTitle},
                );

                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('⚠️ Booking ${booking.id} cancelled! Passenger seat released.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: const Text('Cancel Booking', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(userBookingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bookings Operations CRM', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text('Real-time passenger manifests, seat allocation, and cancellation processing.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                      hintText: 'Search by booking ID, traveler name, phone, or tour...',
                      hintStyle: const TextStyle(color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<BookingStatus?>(
                      value: _selectedStatus,
                      hint: const Text('All Statuses', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Statuses')),
                        ...BookingStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase()))),
                      ],
                      onChanged: (s) => setState(() => _selectedStatus = s),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            bookingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.emerald)),
              error: (e, _) => Text('Error loading bookings: $e', style: const TextStyle(color: AppColors.error)),
              data: (bookings) {
                final query = _searchCtrl.text.trim().toLowerCase();
                final filtered = bookings.where((b) {
                  final matchesQuery = query.isEmpty ||
                      b.id.toLowerCase().contains(query) ||
                      b.customerName.toLowerCase().contains(query) ||
                      b.tourTitle.toLowerCase().contains(query);
                  final matchesStatus = _selectedStatus == null || b.status == _selectedStatus;
                  return matchesQuery && matchesStatus;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No bookings match your filter criteria.', style: TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final b = filtered[index];
                    Color statusColor = AppColors.emerald;
                    if (b.status == BookingStatus.pending) statusColor = AppColors.saffron;
                    if (b.status == BookingStatus.cancelled) statusColor = AppColors.error;

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
                          CircleAvatar(
                            backgroundColor: statusColor.withValues(alpha: 0.2),
                            child: Icon(Icons.confirmation_num, color: statusColor, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(b.id, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                                      child: Text(b.status.name.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('${b.tourTitle} • ${b.customerName}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5)),
                                const SizedBox(height: 4),
                                Text('Date: ${b.travelDate} • Total: ₹${b.totalAmount.toInt()}', style: const TextStyle(color: AppColors.saffron, fontSize: 11.5, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => _showBookingDetailsModal(context, b),
                            child: const Text('View Details', style: TextStyle(color: AppColors.emerald, fontSize: 12, fontWeight: FontWeight.w700)),
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
