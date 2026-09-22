import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/coupon.dart';
import '../../../../core/providers/app_providers.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_confirm_dialog.dart';
import '../widgets/admin_empty_state.dart';

class AdminCouponsScreen extends ConsumerStatefulWidget {
  const AdminCouponsScreen({super.key});

  @override
  ConsumerState<AdminCouponsScreen> createState() => _AdminCouponsScreenState();
}

class _AdminCouponsScreenState extends ConsumerState<AdminCouponsScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  void _showAddEditCouponDialog([Coupon? existing]) {
    final isEditing = existing != null;
    final codeCtrl = TextEditingController(text: existing?.code ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final discountValCtrl = TextEditingController(text: existing != null ? existing.discountValue.toString() : '');
    final minOrderCtrl = TextEditingController(text: existing != null ? existing.minOrderAmount.toString() : '0');
    final maxDiscountCtrl = TextEditingController(text: existing?.maxDiscount != null ? existing!.maxDiscount.toString() : '');
    final usageLimitCtrl = TextEditingController(text: existing?.usageLimit != null ? existing!.usageLimit.toString() : '100');
    CouponDiscountType discountType = existing?.discountType ?? CouponDiscountType.percentage;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(isEditing ? Icons.edit_rounded : Icons.add_circle_outline_rounded, color: AdminTheme.emerald, size: 22),
              const SizedBox(width: 8),
              Text(
                isEditing ? 'Edit Promo Coupon' : 'Create New Promotional Coupon',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
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
                  const Text('Coupon Code', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: codeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1),
                    decoration: InputDecoration(
                      hintText: 'e.g. DARSHAN50, PUNE2026',
                      hintStyle: const TextStyle(color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Description', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'e.g. Flat 50% off on all Darshan circuits',
                      hintStyle: const TextStyle(color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Discount Type', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<CouponDiscountType>(
                              initialValue: discountType,
                              dropdownColor: const Color(0xFF0F172A),
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              items: const [
                                DropdownMenuItem(value: CouponDiscountType.percentage, child: Text('Percentage (%)')),
                                DropdownMenuItem(value: CouponDiscountType.flat, child: Text('Flat Amount (₹)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setModalState(() => discountType = val);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              discountType == CouponDiscountType.percentage ? 'Discount (%)' : 'Amount (₹)',
                              style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: discountValCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: discountType == CouponDiscountType.percentage ? 'e.g. 15' : 'e.g. 200',
                                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Min Order Amount (₹)', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: minOrderCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'e.g. 500',
                                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                            const Text('Usage Limit', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: usageLimitCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'e.g. 100',
                                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                final code = codeCtrl.text.trim().toUpperCase();
                final desc = descCtrl.text.trim();
                final discountVal = double.tryParse(discountValCtrl.text.trim()) ?? 0;
                final minOrder = double.tryParse(minOrderCtrl.text.trim()) ?? 0;
                final maxDisc = double.tryParse(maxDiscountCtrl.text.trim());
                final limit = int.tryParse(usageLimitCtrl.text.trim()) ?? 100;

                if (code.isEmpty || discountVal <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide a valid code and discount value.')),
                  );
                  return;
                }

                Navigator.of(ctx).pop();

                final coupon = Coupon(
                  id: existing?.id ?? 'cpn_${DateTime.now().millisecondsSinceEpoch}',
                  code: code,
                  description: desc.isNotEmpty ? desc : 'Promotional discount',
                  discountType: discountType,
                  discountValue: discountVal,
                  minOrderAmount: minOrder,
                  maxDiscount: maxDisc ?? 500.0,
                  validUntil: DateTime.now().add(const Duration(days: 90)),
                  usageLimit: limit,
                  usedCount: existing?.usedCount ?? 0,
                  isActive: existing?.isActive ?? true,
                );

                await ref.read(couponsProvider.notifier).saveCoupon(coupon);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Coupon $code ${isEditing ? "updated" : "created"} successfully!'),
                      backgroundColor: AdminTheme.emerald,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Text(isEditing ? 'Save Changes' : 'Create Coupon', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteCoupon(Coupon coupon) {
    AdminConfirmDialog.show(
      context: context,
      title: 'Delete Coupon',
      message: 'Are you sure you want to delete coupon "${coupon.code}"? Customers will no longer be able to use this promotional code.',
      confirmLabel: 'Delete Coupon',
      confirmIcon: Icons.delete_forever_rounded,
      isDestructive: true,
      details: {
        'Code': coupon.code,
        'Discount': coupon.discountType == CouponDiscountType.percentage ? '${coupon.discountValue}%' : '₹${coupon.discountValue}',
        'Times Used': '${coupon.usedCount}',
      },
      onConfirm: () async {
        await ref.read(couponsProvider.notifier).deleteCoupon(coupon.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Coupon ${coupon.code} deleted.'),
              backgroundColor: AdminTheme.crimson,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final couponsAsync = ref.watch(couponsProvider);

    return Scaffold(
      backgroundColor: isDark ? AdminTheme.scaffoldBgDark : AdminTheme.scaffoldBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Coupons & Promotional Offers',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Configure discount vouchers, seasonal promo campaigns, and usage redemption caps.',
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
                  label: const Text('Add Coupon', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  onPressed: () => _showAddEditCouponDialog(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Search and Status Filters
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
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                        hintText: 'Search promo coupons by code or description...',
                        hintStyle: const TextStyle(color: Color(0xFF64748B)),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
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
                      _filterChip('All Coupons', 'all'),
                      _filterChip('Active Only', 'active'),
                      _filterChip('Inactive', 'inactive'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Coupons Table Card
            couponsAsync.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AdminTheme.emerald))),
              error: (e, _) => Text('Error loading coupons: $e', style: const TextStyle(color: AdminTheme.crimson)),
              data: (coupons) {
                final filtered = coupons.where((c) {
                  final matchesQuery = _searchQuery.isEmpty ||
                      c.code.toLowerCase().contains(_searchQuery) ||
                      c.description.toLowerCase().contains(_searchQuery);
                  if (!matchesQuery) return false;
                  if (_statusFilter == 'active') return c.isActive;
                  if (_statusFilter == 'inactive') return !c.isActive;
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return const AdminEmptyState(
                    title: 'No Coupons Found',
                    message: 'Create your first promotional discount voucher or adjust your search filter.',
                    icon: Icons.local_offer_rounded,
                  );
                }

                return Container(
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
                      final c = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AdminTheme.emerald.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AdminTheme.emerald.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                c.code,
                                style: const TextStyle(
                                  color: AdminTheme.emerald,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.description,
                                    style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Discount: ${c.discountType == CouponDiscountType.percentage ? "${c.discountValue.toInt()}%" : "₹${c.discountValue.toInt()}"} • Min Order: ₹${c.minOrderAmount.toInt()} • Used: ${c.usedCount}/${c.usageLimit ?? "∞"}',
                                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: c.isActive,
                              activeThumbColor: AdminTheme.emerald,
                              onChanged: (val) async {
                                await ref.read(couponsProvider.notifier).toggleCouponStatus(c.id, val);
                              },
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit_rounded, color: Color(0xFF94A3B8), size: 18),
                              onPressed: () => _showAddEditCouponDialog(c),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AdminTheme.crimson, size: 18),
                              onPressed: () => _confirmDeleteCoupon(c),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
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
