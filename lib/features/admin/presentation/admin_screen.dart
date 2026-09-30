import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/destination.dart';
import '../../../data/models/tour_package.dart';
import '../../../data/models/coupon.dart';
import '../../../data/models/branding_model.dart';
import '../../../data/models/payment_order.dart';
import '../../../data/models/booking.dart';
import '../../../data/repositories/destination_repository.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/app_network_image.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final TextEditingController _appNameCtrl;
  late final TextEditingController _hotlineCtrl;
  late final TextEditingController _noticeCtrl;
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    final initialBranding = ref.read(brandingConfigProvider);
    _appNameCtrl = TextEditingController(text: initialBranding.siteName);
    _hotlineCtrl = TextEditingController(text: initialBranding.contactPhone);
    _noticeCtrl = TextEditingController(text: initialBranding.noticeBanner);
    _controllersInitialized = true;
  }

  String _paymentFilter = 'all'; // 'all', 'pending', 'paid', 'failed'
  final TextEditingController _paymentSearchCtrl = TextEditingController();

  @override
  void dispose() {
    _tabController.dispose();
    _appNameCtrl.dispose();
    _hotlineCtrl.dispose();
    _noticeCtrl.dispose();
    _paymentSearchCtrl.dispose();
    super.dispose();
  }

  void _showRejectPaymentDialog(BuildContext context, PaymentOrder order, String adminEmail) {
    final reasonCtrl = TextEditingController(text: 'Transaction reference / UTR not found in bank statement.');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.cancel_rounded, color: AppColors.error, size: 22),
            const SizedBox(width: 8),
            Text('Reject Payment Claim (${order.orderId})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: ₹${order.amount.toInt()} • UTR: ${order.transactionId ?? "N/A"}', style: const TextStyle(fontSize: 12.5, color: Colors.grey)),
            const SizedBox(height: 12),
            const Text('Reason for Rejection:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Explain why payment verification failed...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final reason = reasonCtrl.text.trim();
              Navigator.of(ctx).pop();
              try {
                await ref.read(paymentOrdersProvider.notifier).rejectPayment(
                      orderId: order.orderId,
                      reason: reason.isNotEmpty ? reason : 'Payment claim could not be verified.',
                      rejectedBy: adminEmail,
                    );
                ref.invalidate(userBookingsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Payment claim for Order #${order.orderId} rejected.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Confirm Rejection'),
          ),
        ],
      ),
    );
  }

  void _showRequestInfoDialog(BuildContext context, PaymentOrder order, dynamic booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.help_outline_rounded, color: AppColors.saffron, size: 22),
            SizedBox(width: 8),
            Text('Request More Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${booking?.customerName ?? order.userId}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 4),
            Text('Contact: ${booking?.customerPhone ?? ""} • ${booking?.customerEmail ?? order.userId}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const Divider(height: 18),
            const Text(
              'A notification will be logged to request the customer to re-check their bank account or share a screenshot of the UPI transaction.',
              style: TextStyle(fontSize: 12.5),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Information request sent to ${booking?.customerName ?? order.userId}.'),
                  backgroundColor: AppColors.saffron,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.saffron, foregroundColor: Colors.white),
            child: const Text('Send Inquiry'),
          ),
        ],
      ),
    );
  }

  void _showAddDestinationModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final stateCtrl = TextEditingController(text: 'Pune City Center');
    final descCtrl = TextEditingController();
    final feeCtrl = TextEditingController(text: '50');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add New Destination'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Destination Name')),
              const SizedBox(height: 8),
              TextField(controller: stateCtrl, decoration: const InputDecoration(labelText: 'Region / Taluka')),
              const SizedBox(height: 8),
              TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Short Description')),
              const SizedBox(height: 8),
              TextField(controller: feeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Entry Fee (₹)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isNotEmpty) {
                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(ctx);
                final newDest = Destination(
                  id: 'dest_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  city: stateCtrl.text.trim(),
                  state: 'Maharashtra',
                  category: DestinationCategory.forts,
                  description: descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : 'Newly added heritage site in Pune region.',
                  longDescription: descCtrl.text.trim(),
                  images: const ['https://images.unsplash.com/photo-1590050752117-238cb0fb12b1?w=800&auto=format&fit=crop&q=80'],
                  rating: 4.8,
                  reviewCount: 1,
                  latitude: 18.5204,
                  longitude: 73.8567,
                  entryFeeIndian: double.tryParse(feeCtrl.text) ?? 50.0,
                  entryFeeForeign: 300.0,
                  bestTime: 'October to February',
                  openingHours: '06:00 AM - 06:00 PM',
                  recommendedDuration: '2-3 Hours',
                  famousFor: 'Historical Significance',
                  difficulty: DifficultyLevel.moderate,
                  distanceFromPuneKm: 25.0,
                  isTrending: true,
                );

                await ref.read(destinationsCatalogProvider.notifier).addDestination(newDest);
                nav.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text('${newDest.name} added to catalog! Live across app.')),
                );
              }
            },
            child: const Text('Save Destination'),
          ),
        ],
      ),
    );
  }

  void _showAddTourModal(BuildContext context) {
    final titleCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '1 Day (8:00 AM - 7:00 PM)');
    final priceCtrl = TextEditingController(text: '499');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Guided Tour Package'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tour Title')),
              const SizedBox(height: 8),
              TextField(controller: durationCtrl, decoration: const InputDecoration(labelText: 'Tour Duration')),
              const SizedBox(height: 8),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price Per Person (₹)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isNotEmpty) {
                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(ctx);
                final newTour = TourPackage(
                  id: 'tour_${DateTime.now().millisecondsSinceEpoch}',
                  title: titleCtrl.text.trim(),
                  subtitle: 'Guided Pune Heritage Tour',
                  destinationId: 'dest_pune_all',
                  destinationName: 'Pune City',
                  duration: durationCtrl.text.trim(),
                  price: double.tryParse(priceCtrl.text) ?? 499.0,
                  originalPrice: 799.0,
                  rating: 4.9,
                  reviewCount: 1,
                  badge: 'New Package',
                  category: 'Heritage Tour',
                  images: const ['https://images.unsplash.com/photo-1590050752117-238cb0fb12b1?w=800&auto=format&fit=crop&q=80'],
                  inclusions: const ['AC Bus', 'Live Guide', 'Entry Passes'],
                  exclusions: const ['Personal Expenses'],
                  highlights: const ['Iconic Landmarks', 'Puneri Lunch'],
                  itinerary: const [],
                  pickupPoints: const ['Swargate', 'Pune Station', 'Shivajinagar'],
                  hasAccommodation: false,
                  accommodationDiscount: 0,
                );

                await ref.read(toursCatalogProvider.notifier).addTourPackage(newTour);
                nav.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text('Tour Package "${newTour.title}" published! Live across app.')),
                );
              }
            },
            child: const Text('Publish Tour'),
          ),
        ],
      ),
    );
  }

  void _showAddCouponModal(BuildContext context) {
    final codeCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final discountCtrl = TextEditingController(text: '20');
    final minAmountCtrl = TextEditingController(text: '500');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Discount Coupon'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Coupon Code (e.g. FESTIVE25)')),
              const SizedBox(height: 8),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Offer Title')),
              const SizedBox(height: 8),
              TextField(controller: discountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Discount Percentage (%)')),
              const SizedBox(height: 8),
              TextField(controller: minAmountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Min Booking Amount (₹)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (codeCtrl.text.trim().isNotEmpty) {
                final newCoupon = Coupon(
                  code: codeCtrl.text.trim().toUpperCase(),
                  title: titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : 'Special Promo',
                  description: 'Seasonal discount code',
                  type: 'percent',
                  discountValue: double.tryParse(discountCtrl.text) ?? 20.0,
                  minBookingAmount: double.tryParse(minAmountCtrl.text) ?? 500.0,
                  minTravelers: 1,
                  expiry: 'Valid till 31 Dec 2026',
                  badge: 'Special Offer',
                );

                ref.read(destinationRepositoryProvider).addCoupon(newCoupon);
                ref.invalidate(couponsAsyncProvider);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Coupon ${newCoupon.code} created!')),
                );
              }
            },
            child: const Text('Save Coupon'),
          ),
        ],
      ),
    );
  }

  void _handleSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_person_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Lock & Sign Out Portal'),
          ],
        ),
        content: const Text('Are you sure you want to terminate the Admin session and return to the public application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(adminSessionProvider.notifier).logout();
              if (context.mounted) {
                context.go('/home');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Admin session terminated. Portal locked.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Confirm Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final destinationsAsync = ref.watch(destinationsAsyncProvider);
    final tourPackagesAsync = ref.watch(tourPackagesAsyncProvider);
    final bookingsAsync = ref.watch(userBookingsProvider);
    final couponsAsync = ref.watch(couponsAsyncProvider);
    final branding = ref.watch(brandingConfigProvider);
    final adminSession = ref.watch(adminSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PuneExplorer Admin Command Hub'),
            Text(
              'Super Admin • ${adminSession.email.isNotEmpty ? adminSession.email : "admin@puneexplorer.in"}',
              style: const TextStyle(fontSize: 11, color: AppColors.saffron, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_rounded, color: AppColors.error),
            tooltip: 'Lock & Sign Out Admin Portal',
            onPressed: () => _handleSignOut(context),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.emerald,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.emerald,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Destinations'),
            Tab(text: 'Tour Packages'),
            Tab(text: 'Payments & Bookings'),
            Tab(text: 'Coupons CMS'),
            Tab(text: 'Branding & Notice'),
          ],
        ),
      ),
      body: MaxWidthWrapper(
        padding: const EdgeInsets.all(16),
        child: TabBarView(
          controller: _tabController,
          children: [
            // 1. Dashboard Metrics
            _buildMetricsTab(destinationsAsync, tourPackagesAsync, bookingsAsync, isDark, theme),

            // 2. Destinations CMS
            _buildDestinationsCMSTab(destinationsAsync, isDark, theme),

            // 3. Tour Packages CMS
            _buildTourPackagesCMSTab(tourPackagesAsync, isDark, theme),

            // 4. Bookings CRM
            _buildBookingsCMSTab(bookingsAsync, isDark, theme),

            // 5. Coupons CMS
            _buildCouponsCMSTab(couponsAsync, isDark, theme),

            // 6. Branding & Notice CMS
            _buildBrandingCMSTab(branding, isDark, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsTab(
    AsyncValue<List<Destination>> destinationsAsync,
    AsyncValue<List<TourPackage>> tourPackagesAsync,
    AsyncValue<List<dynamic>> bookingsAsync,
    bool isDark,
    ThemeData theme,
  ) {
    final destCount = destinationsAsync.value?.length ?? 0;
    final packageCount = tourPackagesAsync.value?.length ?? 0;
    final bookings = bookingsAsync.value ?? [];
    final totalRevenue = bookings.fold<double>(0, (sum, b) => sum + (b.totalAmount as num).toDouble());

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Platform Executive Metrics', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildMetricCard('Total Revenue', '₹${totalRevenue.toInt()}', Icons.currency_rupee_rounded, AppColors.emerald, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard('Total Bookings', '${bookings.length}', Icons.confirmation_number_rounded, AppColors.saffron, isDark)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMetricCard('Destinations', '$destCount Active', Icons.location_city_rounded, Colors.blue, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard('Tour Packages', '$packageCount Available', Icons.directions_bus_rounded, Colors.purple, isDark)),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 20),
          Text('Data Management & Reset Controls', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Reset Catalog to Seed Data',
            icon: const Icon(Icons.restore_rounded, size: 16),
            variant: ButtonVariant.outline,
            onPressed: () {
              final repo = ref.read(destinationRepositoryProvider);
              if (repo is LocalDestinationRepository) {
                repo.resetToSeed();
              }
              ref.invalidate(destinationsAsyncProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Catalog reset to initial seed state.')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String val, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _buildDestinationsCMSTab(AsyncValue<List<Destination>> destinationsAsync, bool isDark, ThemeData theme) {
    return destinationsAsync.when(
      data: (list) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${list.length} Landmarks in Catalog', style: const TextStyle(fontWeight: FontWeight.w700)),
                CustomButton(
                  text: '+ Add Destination',
                  variant: ButtonVariant.primary,
                  height: 38,
                  onPressed: () => _showAddDestinationModal(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final dest = list[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AppCardImage(
                            imageUrl: dest.primaryImage,
                            width: 48,
                            height: 48,
                            categoryIcon: dest.category.icon,
                            categoryLabel: dest.category.label,
                            title: dest.name,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dest.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                              Text('${dest.category.label} • ₹${dest.entryFeeIndian.toInt()} Entry', style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey),
                          tooltip: 'Delete Destination',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Destination?'),
                                content: Text('Are you sure you want to permanently delete "${dest.name}" from Supabase?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                    child: const Text('Delete Permanently', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              if (!context.mounted) return;
                              final messenger = ScaffoldMessenger.of(context);
                              try {
                                await ref.read(destinationsCatalogProvider.notifier).deleteDestination(dest.id);
                                await ref.read(favoritesProvider.notifier).remove(dest.id);
                                messenger.showSnackBar(
                                  SnackBar(content: Text('Deleted "${dest.name}" from database.'), backgroundColor: AppColors.emerald),
                                );
                              } catch (e) {
                                messenger.showSnackBar(
                                  SnackBar(content: Text('Failed to delete: $e'), backgroundColor: AppColors.error),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildTourPackagesCMSTab(AsyncValue<List<TourPackage>> tourPackagesAsync, bool isDark, ThemeData theme) {
    return tourPackagesAsync.when(
      data: (packages) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${packages.length} Tour Packages Active', style: const TextStyle(fontWeight: FontWeight.w700)),
                CustomButton(
                  text: '+ Add Tour Package',
                  variant: ButtonVariant.primary,
                  height: 38,
                  onPressed: () => _showAddTourModal(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: packages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final pkg = packages[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    child: Row(
                      children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AppCardImage(
                      imageUrl: pkg.primaryImage,
                      width: 54,
                      height: 54,
                      categoryIcon: '🚌',
                      categoryLabel: pkg.title,
                      title: pkg.title,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.saffron, borderRadius: BorderRadius.circular(4)),
                          child: Text(pkg.badge, style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(height: 4),
                        Text(pkg.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                        Text('₹${pkg.price.toInt()}/person • ${pkg.duration}', style: const TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w700, fontSize: 11.5)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ],
  );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildBookingsCMSTab(AsyncValue<List<dynamic>> bookingsAsync, bool isDark, ThemeData theme) {
    final bookings = (bookingsAsync.value ?? []).cast<Booking>();
    final paymentOrdersAsync = ref.watch(paymentOrdersProvider);
    final allOrders = paymentOrdersAsync.value ?? [];
    final adminSession = ref.watch(adminSessionProvider);
    final adminEmail = adminSession.email.isNotEmpty ? adminSession.email : 'admin@puneexplorer.in';

    // Calculate metrics
    final pendingOrders = allOrders.where((o) => o.status == PaymentStatus.underVerification || o.status == PaymentStatus.paymentSubmitted).toList();
    final paidOrders = allOrders.where((o) => o.status == PaymentStatus.paid).toList();
    final failedOrders = allOrders.where((o) => o.status == PaymentStatus.failed).toList();

    // Filter orders based on active tab
    List<PaymentOrder> displayedOrders;
    if (_paymentFilter == 'pending') {
      displayedOrders = pendingOrders;
    } else if (_paymentFilter == 'paid') {
      displayedOrders = paidOrders;
    } else if (_paymentFilter == 'failed') {
      displayedOrders = failedOrders;
    } else {
      displayedOrders = allOrders;
    }

    // Apply search filter if query is present
    final query = _paymentSearchCtrl.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      displayedOrders = displayedOrders.where((o) {
        final orderMatch = o.orderId.toLowerCase().contains(query);
        final bookingMatch = o.bookingId.toLowerCase().contains(query);
        final utrMatch = (o.transactionId ?? '').toLowerCase().contains(query);
        final userMatch = o.userId.toLowerCase().contains(query);
        final pkgMatch = o.packageName.toLowerCase().contains(query);
        return orderMatch || bookingMatch || utrMatch || userMatch || pkgMatch;
      }).toList();
    }

    return Column(
      children: [
        // Filter Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: Text('All Orders (${allOrders.length})'),
                selected: _paymentFilter == 'all',
                onSelected: (val) => setState(() => _paymentFilter = 'all'),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (pendingOrders.isNotEmpty) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: AppColors.saffron, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text('Pending Verification (${pendingOrders.length})'),
                  ],
                ),
                selected: _paymentFilter == 'pending',
                selectedColor: AppColors.saffron.withValues(alpha: 0.25),
                onSelected: (val) => setState(() => _paymentFilter = 'pending'),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text('Verified / Paid (${paidOrders.length})'),
                selected: _paymentFilter == 'paid',
                selectedColor: AppColors.emerald.withValues(alpha: 0.25),
                onSelected: (val) => setState(() => _paymentFilter = 'paid'),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text('Rejected (${failedOrders.length})'),
                selected: _paymentFilter == 'failed',
                onSelected: (val) => setState(() => _paymentFilter = 'failed'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Search Bar
        TextField(
          controller: _paymentSearchCtrl,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search by Order ID, UTR, Booking ID, or Customer...',
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: _paymentSearchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _paymentSearchCtrl.clear();
                      setState(() {});
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),

        // Orders List
        Expanded(
          child: displayedOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _paymentFilter == 'pending' ? Icons.task_alt_rounded : Icons.receipt_long_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _paymentFilter == 'pending'
                            ? 'No payment claims awaiting verification.'
                            : 'No payment orders found matching criteria.',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: displayedOrders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = displayedOrders[index];
                    final booking = bookings.where((b) => b.id == order.bookingId || b.orderId == order.orderId).firstOrNull;

                    // Duplicate UTR check across all orders
                    final hasDuplicateUtr = order.transactionId != null &&
                        allOrders.any((o) =>
                            o.orderId != order.orderId &&
                            o.transactionId != null &&
                            o.transactionId!.trim().toUpperCase() == order.transactionId!.trim().toUpperCase());

                    final isUnderVerification = order.status == PaymentStatus.underVerification || order.status == PaymentStatus.paymentSubmitted;
                    final isPaid = order.status == PaymentStatus.paid;
                    final isFailed = order.status == PaymentStatus.failed;

                    Color statusColor = AppColors.saffron;
                    String statusLabel = 'PENDING PAYMENT';
                    if (isPaid) {
                      statusColor = AppColors.emerald;
                      statusLabel = 'PAID (VERIFIED)';
                    } else if (isUnderVerification) {
                      statusColor = AppColors.saffron;
                      statusLabel = 'UNDER VERIFICATION';
                    } else if (isFailed) {
                      statusColor = AppColors.error;
                      statusLabel = 'REJECTED / FAILED';
                    }

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isUnderVerification
                              ? AppColors.saffron.withValues(alpha: 0.7)
                              : isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                          width: isUnderVerification ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Order ID + Status Pill
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    order.orderId,
                                    style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w800, fontSize: 13.5),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '• Booking #${order.bookingId}',
                                    style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 10.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Package & Amount
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  order.packageName,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '₹${order.amount.toInt()}',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.emerald),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Customer Details
                          Text(
                            'User: ${booking?.customerName ?? order.userId} • Phone: ${booking?.customerPhone ?? "N/A"}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            'Created: ${DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt)}',
                            style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                          ),
                          const SizedBox(height: 10),

                          // Transaction ID / UTR Highlight Box
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.tag_rounded, size: 16, color: AppColors.saffron),
                                    const SizedBox(width: 6),
                                    const Text('UTR / Txn Ref: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    Text(
                                      order.transactionId ?? 'Awaiting User Submission',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12.5,
                                        color: order.transactionId != null ? null : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                if (order.transactionId != null)
                                  IconButton(
                                    icon: const Icon(Icons.copy_rounded, size: 16),
                                    tooltip: 'Copy UTR',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: order.transactionId!));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Copied UTR: ${order.transactionId}')),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),

                          // Duplicate UTR Alert Warning Banner
                          if (hasDuplicateUtr) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 16),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'WARNING: Duplicate UTR detected! This transaction ID is tied to multiple orders.',
                                      style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          if (order.failureReason != null) ...[
                            const SizedBox(height: 6),
                            Text('Rejection Reason: ${order.failureReason}', style: const TextStyle(color: AppColors.error, fontSize: 11.5)),
                          ],

                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 10),

                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isUnderVerification) ...[
                                TextButton.icon(
                                  onPressed: () => _showRequestInfoDialog(context, order, booking),
                                  icon: const Icon(Icons.help_outline, size: 15),
                                  label: const Text('Request Info', style: TextStyle(fontSize: 12)),
                                  style: TextButton.styleFrom(foregroundColor: AppColors.saffron),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: () => _showRejectPaymentDialog(context, order, adminEmail),
                                  icon: const Icon(Icons.close_rounded, size: 15),
                                  label: const Text('Reject', style: TextStyle(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    side: const BorderSide(color: AppColors.error),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    try {
                                      await ref.read(paymentOrdersProvider.notifier).verifyPayment(
                                            orderId: order.orderId,
                                            verifiedBy: adminEmail,
                                          );
                                      ref.invalidate(userBookingsProvider);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Payment for Order #${order.orderId} verified! Booking confirmed.'),
                                            backgroundColor: AppColors.emerald,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Verification failed: $e')),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.check_circle_rounded, size: 16),
                                  label: const Text('Verify Payment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald, foregroundColor: Colors.white),
                                ),
                              ] else if (isPaid) ...[
                                Text(
                                  'Verified by ${order.verifiedBy ?? "Admin"}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                                ),
                                const Spacer(),
                                OutlinedButton.icon(
                                  onPressed: () => context.push('/payment/receipt/${order.orderId}'),
                                  icon: const Icon(Icons.receipt_rounded, size: 14),
                                  label: const Text('View Receipt', style: TextStyle(fontSize: 11.5)),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCouponsCMSTab(AsyncValue<List<Coupon>> couponsAsync, bool isDark, ThemeData theme) {
    final coupons = couponsAsync.value ?? [];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${coupons.length} Active Promo Codes', style: const TextStyle(fontWeight: FontWeight.w700)),
            CustomButton(
              text: '+ Create Coupon',
              variant: ButtonVariant.primary,
              height: 38,
              onPressed: () => _showAddCouponModal(context),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: coupons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final c = coupons[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.code, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.saffron, fontSize: 14)),
                        Text('${c.title} • Min ₹${c.minBookingAmount.toInt()}', style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.emerald.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: Text('${c.discountValue.toInt()}% OFF', style: const TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBrandingCMSTab(BrandingConfig branding, bool isDark, ThemeData theme) {
    if (_controllersInitialized && _appNameCtrl.text != branding.siteName && !FocusScope.of(context).hasFocus) {
      _appNameCtrl.text = branding.siteName;
      _hotlineCtrl.text = branding.contactPhone;
      _noticeCtrl.text = branding.noticeBanner;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Branding & Notice Management', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          TextField(
            controller: _appNameCtrl,
            decoration: const InputDecoration(labelText: 'Platform Brand Name', prefixIcon: Icon(Icons.badge_rounded)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _hotlineCtrl,
            decoration: const InputDecoration(labelText: '24x7 Tourist Support Hotline', prefixIcon: Icon(Icons.phone_in_talk_rounded)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noticeCtrl,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Platform Alert / Notice Banner Text', prefixIcon: Icon(Icons.campaign_rounded)),
          ),
          const SizedBox(height: 14),
          SwitchListTile(
            title: const Text('Show Announcement Banner App-Wide', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
            value: branding.showNoticeBanner,
            activeThumbColor: AppColors.emerald,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) {
              ref.read(brandingConfigProvider.notifier).updateConfig(branding.copyWith(showNoticeBanner: val));
            },
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'Save & Broadcast Changes',
            variant: ButtonVariant.primary,
            onPressed: () {
              final updated = branding.copyWith(
                siteName: _appNameCtrl.text.trim(),
                contactPhone: _hotlineCtrl.text.trim(),
                noticeBanner: _noticeCtrl.text.trim(),
              );
              ref.read(brandingConfigProvider.notifier).updateConfig(updated);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Branding and broadcast banner updated!')),
              );
            },
          ),
        ],
      ),
    );
  }
}
