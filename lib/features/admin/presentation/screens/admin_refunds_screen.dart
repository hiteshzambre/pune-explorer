import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/models/admin_refund_request.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_empty_state.dart';

class AdminRefundsScreen extends ConsumerStatefulWidget {
  const AdminRefundsScreen({super.key});

  @override
  ConsumerState<AdminRefundsScreen> createState() => _AdminRefundsScreenState();
}

class _AdminRefundsScreenState extends ConsumerState<AdminRefundsScreen> {
  String _statusFilter = 'all';

  void _showApproveDialog(AdminRefundRequest refund, String adminEmail) {
    double fee = refund.cancellationFee;
    final feeCtrl = TextEditingController(text: fee.toString());

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final original = refund.originalAmount;
          final refundAmount = (original - fee).clamp(0, original);

          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.currency_rupee_rounded, color: AdminTheme.emerald, size: 22),
                SizedBox(width: 8),
                Text('Approve Cancellation Refund', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
              ],
            ),
            content: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Claim ID: ${refund.id} • Order: ${refund.orderId}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  const SizedBox(height: 12),
                  _summaryRow('Customer Email', refund.userEmail),
                  _summaryRow('Original Paid Amount', '₹${refund.originalAmount.toInt()}'),
                  const SizedBox(height: 12),
                  const Text('Cancellation Deductions (₹):', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: feeCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        fee = double.tryParse(val) ?? 0;
                      });
                    },
                  ),
                  const Divider(color: Color(0xFF334155), height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Net Refundable Amount:', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                      Text('₹${refundAmount.toInt()}', style: const TextStyle(color: AdminTheme.emerald, fontSize: 18, fontWeight: FontWeight.w900)),
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
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await ref.read(adminRefundsProvider.notifier).approveRefund(
                        refundId: refund.id,
                        cancellationFee: fee,
                        processedBy: adminEmail,
                      );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Refund claim ${refund.id} approved for ₹${refundAmount.toInt()}.'),
                        backgroundColor: AdminTheme.emerald,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: const Text('Confirm Approval', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRejectDialog(AdminRefundRequest refund, String adminEmail) {
    final reasonCtrl = TextEditingController(text: 'Cancellation requested past permissible window.');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reject Refund Request', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order ID: ${refund.orderId} • Amount: ₹${refund.originalAmount.toInt()}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              const SizedBox(height: 12),
              const Text('Rejection Justification:', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: reasonCtrl,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.crimson),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(adminRefundsProvider.notifier).rejectRefund(
                    refundId: refund.id,
                    reason: reasonCtrl.text.trim(),
                    processedBy: adminEmail,
                  );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Refund claim ${refund.id} rejected.'),
                    backgroundColor: AdminTheme.crimson,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Confirm Reject', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final refundsAsync = ref.watch(adminRefundsProvider);
    final adminSession = ref.watch(adminSessionProvider);
    final adminEmail = adminSession.email.isNotEmpty ? adminSession.email : 'finance@puneexplorer.in';

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
                        'Refunds & Cancellation Claims',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Process traveler tour cancellation requests, apply policy penalty deductions, and audit payouts.',
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
                  label: const Text('Refresh Claims', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                  onPressed: () => ref.refresh(adminRefundsProvider),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Filters
            Row(
              children: [
                _filterChip('All Claims', 'all'),
                const SizedBox(width: 8),
                _filterChip('Pending Review', 'pending'),
                const SizedBox(width: 8),
                _filterChip('Approved', 'approved'),
                const SizedBox(width: 8),
                _filterChip('Processed', 'processed'),
                const SizedBox(width: 8),
                _filterChip('Rejected', 'rejected'),
              ],
            ),

            const SizedBox(height: 20),

            // Refunds List
            refundsAsync.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AdminTheme.emerald))),
              error: (e, _) => Text('Error loading refunds: $e', style: const TextStyle(color: AdminTheme.crimson)),
              data: (refunds) {
                final filtered = refunds.where((r) {
                  if (_statusFilter == 'all') return true;
                  return r.status == _statusFilter;
                }).toList();

                if (filtered.isEmpty) {
                  return const AdminEmptyState(
                    title: 'No Refund Claims',
                    message: 'There are no cancellation refund requests matching your selected filter tab.',
                    icon: Icons.currency_rupee_rounded,
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final r = filtered[index];
                    final isPending = r.status == 'pending';

                    Color statusCol = AdminTheme.saffron;
                    if (r.status == 'approved' || r.status == 'processed') statusCol = AdminTheme.emerald;
                    if (r.status == 'rejected') statusCol = AdminTheme.crimson;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isPending ? AdminTheme.saffron.withValues(alpha: 0.5) : const Color(0xFF334155),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(r.id, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusCol.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: statusCol.withValues(alpha: 0.4)),
                                    ),
                                    child: Text(r.status.toUpperCase(), style: TextStyle(color: statusCol, fontSize: 10.5, fontWeight: FontWeight.w800)),
                                  ),
                                ],
                              ),
                              Text('₹${r.refundAmount.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Order: ${r.orderId} • Booking Ref: ${r.bookingId} • User: ${r.userEmail}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('Reason: "${r.reason}"', style: const TextStyle(color: Colors.white70, fontSize: 12.5, fontStyle: FontStyle.italic)),
                          const SizedBox(height: 8),
                          Text(
                            'Original: ₹${r.originalAmount.toInt()} | Deductions: ₹${r.cancellationFee.toInt()} | Requested: ${r.requestedAt.toString().substring(0, 16)}',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                          ),
                          if (isPending) ...[
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AdminTheme.crimson),
                                    foregroundColor: AdminTheme.crimson,
                                  ),
                                  onPressed: () => _showRejectDialog(r, adminEmail),
                                  child: const Text('Reject Claim'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.emerald),
                                  onPressed: () => _showApproveDialog(r, adminEmail),
                                  child: const Text('Approve Refund', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ],
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

  Widget _filterChip(String label, String value) {
    final isSelected = _statusFilter == value;
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
      onSelected: (_) => setState(() => _statusFilter = value),
    );
  }
}
