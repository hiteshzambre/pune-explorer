import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/models/payment_order.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_confirm_dialog.dart';
import '../widgets/admin_empty_state.dart';

class AdminPaymentsScreen extends ConsumerStatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  ConsumerState<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends ConsumerState<AdminPaymentsScreen> {
  String _paymentFilter = 'all';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showVerifyPaymentDialog(BuildContext context, PaymentOrder order, String adminEmail) {
    AdminConfirmDialog.show(
      context: context,
      title: 'Verify Payment Claim',
      message: 'Confirming this transaction will mark order ${order.orderId} as verified, update the traveler\'s booking status to confirmed, and create an immutable audit record.',
      confirmLabel: 'Confirm & Verify',
      confirmIcon: Icons.verified_user_rounded,
      isDestructive: false,
      details: {
        'Order ID': order.orderId,
        'Booking Ref': order.bookingId,
        'Customer': order.userId,
        'Package': order.packageName,
        'Amount': '₹${order.amount.toInt()}',
        'Claimed UTR': order.transactionId ?? 'Not Provided',
        'Submitted': order.createdAt.toLocal().toString().substring(0, 16),
      },
      onConfirm: () async {
        await ref.read(paymentOrdersProvider.notifier).verifyPayment(
              orderId: order.orderId,
              verifiedBy: adminEmail,
              notes: 'Verified via PuneExplorer Admin Payments Console',
            );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment Claim ${order.orderId} verified and confirmed!'),
              backgroundColor: AdminTheme.emerald,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  void _showRejectPaymentDialog(BuildContext context, PaymentOrder order, String adminEmail) {
    final reasonCtrl = TextEditingController(text: 'Transaction reference / UTR not found in bank statement.');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.cancel_rounded, color: AdminTheme.crimson, size: 22),
            const SizedBox(width: 8),
            Text(
              'Reject Payment Claim (${order.orderId})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount: ₹${order.amount.toInt()} • UTR: ${order.transactionId ?? "N/A"}',
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Reason for Rejection:',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Explain why payment verification failed...',
                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.crimson),
            onPressed: () async {
              final reason = reasonCtrl.text.trim();
              Navigator.of(ctx).pop();
              try {
                await ref.read(paymentOrdersProvider.notifier).rejectPayment(
                      orderId: order.orderId,
                      reason: reason.isNotEmpty ? reason : 'Payment claim could not be verified.',
                      rejectedBy: adminEmail,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Payment Claim ${order.orderId} rejected. Reason: $reason'),
                      backgroundColor: AdminTheme.crimson,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.crimson),
                  );
                }
              }
            },
            child: const Text('Confirm Rejection', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showReceiptDialog(BuildContext context, PaymentOrder order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.receipt_long_rounded, color: AdminTheme.emerald, size: 22),
            SizedBox(width: 8),
            Text('Digital Payment Receipt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          ],
        ),
        content: Container(
          width: 440,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('PuneExplorer Travels', style: TextStyle(color: AdminTheme.emerald, fontWeight: FontWeight.w900, fontSize: 14)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AdminTheme.emerald.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('PAID & VERIFIED', style: TextStyle(color: AdminTheme.emerald, fontWeight: FontWeight.w800, fontSize: 10)),
                  ),
                ],
              ),
              const Divider(color: Color(0xFF334155), height: 24),
              _receiptRow('Receipt / Order ID', order.orderId),
              _receiptRow('Booking ID', order.bookingId),
              _receiptRow('Customer', order.userId),
              _receiptRow('Tour Package', order.packageName),
              _receiptRow('Paid Amount', '₹${order.amount.toInt()}'),
              _receiptRow('Bank UTR', order.transactionId ?? 'N/A'),
              _receiptRow('Verified By', order.verifiedBy ?? 'Admin System'),
              _receiptRow('Timestamp', order.updatedAt.toLocal().toString().substring(0, 19)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(color: AdminTheme.emerald)),
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paymentOrdersAsync = ref.watch(paymentOrdersProvider);
    final adminSession = ref.watch(adminSessionProvider);
    final adminEmail = adminSession.email.isNotEmpty ? adminSession.email : 'admin@puneexplorer.in';

    return Scaffold(
      backgroundColor: isDark ? AdminTheme.scaffoldBgDark : AdminTheme.scaffoldBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Screen Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payments & UTR Verification Console',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Real-time UPI reference matching, manual verification, and payment claim moderation.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.emerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Refresh Orders', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                  onPressed: () => ref.refresh(paymentOrdersProvider),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Top Mini-Metrics
            paymentOrdersAsync.when(
              data: (orders) {
                final pending = orders.where((o) => o.status == PaymentStatus.underVerification || o.status == PaymentStatus.paymentSubmitted).length;
                final verified = orders.where((o) => o.status == PaymentStatus.paid).length;
                final totalRev = orders.where((o) => o.status == PaymentStatus.paid).fold<double>(0, (sum, o) => sum + o.amount);

                return Row(
                  children: [
                    Expanded(
                      child: _buildMiniStat(
                        'Total Claims',
                        '${orders.length}',
                        Icons.payments_rounded,
                        const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildMiniStat(
                        'Pending Verification',
                        '$pending',
                        Icons.pending_actions_rounded,
                        pending > 0 ? AdminTheme.saffron : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildMiniStat(
                        'Verified Paid',
                        '$verified',
                        Icons.check_circle_rounded,
                        AdminTheme.emerald,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildMiniStat(
                        'Total Confirmed Rev',
                        '₹${totalRev.toInt()}',
                        Icons.account_balance_wallet_rounded,
                        AdminTheme.emerald,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 20),

            // Search & Filter Controls
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                        hintText: 'Search by Order ID (PE-...), UTR reference, or User Email...',
                        hintStyle: const TextStyle(color: Color(0xFF64748B)),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip('All Claims', 'all'),
                      _buildFilterChip('Under Verification', 'underVerification'),
                      _buildFilterChip('Paid (Verified)', 'paid'),
                      _buildFilterChip('Failed / Rejected', 'failed'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Payment Orders List
            paymentOrdersAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AdminTheme.emerald),
                ),
              ),
              error: (e, _) => Text('Error loading payment orders: $e', style: const TextStyle(color: AdminTheme.crimson)),
              data: (orders) {
                final query = _searchCtrl.text.trim().toLowerCase();
                final filtered = orders.where((o) {
                  final matchesQuery = query.isEmpty ||
                      o.orderId.toLowerCase().contains(query) ||
                      (o.transactionId?.toLowerCase().contains(query) ?? false) ||
                      o.userId.toLowerCase().contains(query);

                  if (!matchesQuery) return false;
                  if (_paymentFilter == 'all') return true;
                  if (_paymentFilter == 'underVerification') {
                    return o.status == PaymentStatus.underVerification || o.status == PaymentStatus.paymentSubmitted;
                  }
                  if (_paymentFilter == 'paid') return o.status == PaymentStatus.paid;
                  if (_paymentFilter == 'failed') return o.status == PaymentStatus.failed || o.status == PaymentStatus.expired;
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return const AdminEmptyState(
                    title: 'No Payment Claims Found',
                    message: 'There are no payment claims matching your search query or selected filter tab.',
                    icon: Icons.receipt_long_rounded,
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final order = filtered[index];
                    final isPending = order.status == PaymentStatus.underVerification || order.status == PaymentStatus.paymentSubmitted;
                    final isPaid = order.status == PaymentStatus.paid;
                    final isFailed = order.status == PaymentStatus.failed;

                    Color statusColor = AdminTheme.saffron;
                    String statusLabel = 'UNDER VERIFICATION';
                    if (isPaid) {
                      statusColor = AdminTheme.emerald;
                      statusLabel = 'PAID (VERIFIED)';
                    } else if (isFailed) {
                      statusColor = AdminTheme.crimson;
                      statusLabel = 'REJECTED / FAILED';
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isPending ? AdminTheme.saffron.withValues(alpha: 0.5) : const Color(0xFF334155),
                          width: isPending ? 1.5 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    order.orderId,
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                                    ),
                                    child: Text(
                                      statusLabel,
                                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '₹${order.amount.toInt()}',
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            order.packageName,
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'User: ${order.userId} • Created: ${order.createdAt.toLocal().toString().substring(0, 16)} • Booking Ref: ${order.bookingId}',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF334155)),
                            ),
                            child: Row(
                              children: [
                                const Text('Claimed UTR / Ref: ', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                                Text(
                                  order.transactionId != null && order.transactionId!.isNotEmpty ? order.transactionId! : 'No UTR submitted yet',
                                  style: TextStyle(
                                    color: order.transactionId != null && order.transactionId!.isNotEmpty ? AdminTheme.saffron : Colors.grey,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (order.verifiedBy != null && order.verifiedBy!.isNotEmpty) ...[
                                  const Spacer(),
                                  Text(
                                    'Verified by ${order.verifiedBy}',
                                    style: const TextStyle(color: AdminTheme.emerald, fontSize: 11.5, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isPending) ...[
                                TextButton.icon(
                                  icon: const Icon(Icons.info_outline, size: 16),
                                  label: const Text('Request Info'),
                                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF94A3B8)),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Information request sent to ${order.userId}'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.close_rounded, size: 16, color: AdminTheme.crimson),
                                  label: const Text('Reject', style: TextStyle(color: AdminTheme.crimson, fontWeight: FontWeight.w700)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AdminTheme.crimson),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  ),
                                  onPressed: () => _showRejectPaymentDialog(context, order, adminEmail),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                                  label: const Text('Verify Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AdminTheme.emerald,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                  onPressed: () => _showVerifyPaymentDialog(context, order, adminEmail),
                                ),
                              ] else if (isPaid) ...[
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.receipt_long_rounded, size: 16, color: AdminTheme.emerald),
                                  label: const Text('View Receipt', style: TextStyle(color: AdminTheme.emerald, fontWeight: FontWeight.w700)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AdminTheme.emerald),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  ),
                                  onPressed: () => _showReceiptDialog(context, order),
                                ),
                              ],
                            ],
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

  Widget _buildMiniStat(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _paymentFilter == value;
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
      onSelected: (_) => setState(() => _paymentFilter = value),
    );
  }
}
