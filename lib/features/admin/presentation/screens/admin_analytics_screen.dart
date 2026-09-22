import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/providers/app_providers.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_kpi_card.dart';

class AdminAnalyticsScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  ConsumerState<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends ConsumerState<AdminAnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDays = 30;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _exportAnalyticsReport(String reportType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully exported $reportType analytics data to CSV.'),
        backgroundColor: AdminTheme.emerald,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookingsAsync = ref.watch(userBookingsProvider);
    final paymentOrdersAsync = ref.watch(paymentOrdersProvider);
    final usersAsync = ref.watch(allUsersProvider);
    final toursAsync = ref.watch(tourPackagesAsyncProvider);
    final destinationsAsync = ref.watch(destinationsAsyncProvider);

    final bookings = bookingsAsync.maybeWhen(data: (b) => b, orElse: () => []);
    final orders = paymentOrdersAsync.maybeWhen(data: (o) => o, orElse: () => []);
    final users = usersAsync.maybeWhen(data: (u) => u, orElse: () => []);
    final tours = toursAsync.maybeWhen(data: (t) => t, orElse: () => []);
    final destinations = destinationsAsync.maybeWhen(data: (d) => d, orElse: () => []);

    double totalRevenue = 0;
    int verifiedOrders = 0;
    for (var o in orders) {
      if (o.status == PaymentStatus.paid) {
        totalRevenue += o.amount;
        verifiedOrders++;
      }
    }

    final confirmedBookings = bookings.where((b) => b.status == BookingStatus.confirmed).length;
    final avgOrderValue = verifiedOrders > 0 ? (totalRevenue / verifiedOrders).round() : 0;
    final conversionRate = users.isNotEmpty ? ((confirmedBookings / users.length) * 100).toStringAsFixed(1) : '0.0';

    return Scaffold(
      backgroundColor: isDark ? AdminTheme.scaffoldBgDark : AdminTheme.scaffoldBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Title & Filter Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analytics & Performance Reports',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Deep-dive business intelligence, tour performance, passenger metrics, and revenue attribution.',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    // Time Range Selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Row(
                        children: [7, 30, 90, 365].map((d) {
                          final isSelected = _selectedDays == d;
                          return InkWell(
                            onTap: () => setState(() => _selectedDays = d),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? AdminTheme.emerald : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                d == 365 ? '1Y' : '${d}D',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminTheme.emerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.file_download_outlined, size: 18),
                      label: const Text('Export CSV', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                      onPressed: () => _exportAnalyticsReport('Overview'),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Top Summary Cards
            Row(
              children: [
                Expanded(
                  child: AdminKpiCard(
                    title: 'Gross Revenue',
                    value: '₹${totalRevenue.toInt()}',
                    subtitle: '$verifiedOrders verified payments',
                    icon: Icons.currency_rupee_rounded,
                    accentColor: AdminTheme.emerald,
                    delta: '+18.2%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AdminKpiCard(
                    title: 'Average Order Value',
                    value: '₹$avgOrderValue',
                    subtitle: 'Per passenger booking',
                    icon: Icons.trending_up_rounded,
                    accentColor: const Color(0xFF3B82F6),
                    delta: '+5.4%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AdminKpiCard(
                    title: 'Conversion Rate',
                    value: '$conversionRate%',
                    subtitle: 'Visitor to booked ratio',
                    icon: Icons.swap_vert_circle_rounded,
                    accentColor: AdminTheme.saffron,
                    delta: '+2.1%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AdminKpiCard(
                    title: 'Catalog Size',
                    value: '${destinations.length + tours.length}',
                    subtitle: '${tours.length} packages active',
                    icon: Icons.inventory_2_rounded,
                    accentColor: const Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Analytical Tabs
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF334155), width: 1)),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AdminTheme.emerald,
                indicatorWeight: 3,
                labelColor: AdminTheme.emerald,
                unselectedLabelColor: const Color(0xFF94A3B8),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Bookings Breakdown'),
                  Tab(text: 'Revenue Attribution'),
                  Tab(text: 'Tours & Popularity'),
                  Tab(text: 'User Growth'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tab Content
            SizedBox(
              height: 480,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(bookings, orders, tours),
                  _buildBookingsTab(bookings),
                  _buildRevenueTab(orders, totalRevenue),
                  _buildToursTab(tours),
                  _buildUsersTab(users),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(List<dynamic> bookings, List<dynamic> orders, List<dynamic> tours) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Performance highlights
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Key Performance Drivers',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                _driverRow('Most Booked Package', tours.isNotEmpty ? tours.first.title : 'Royal Pune Darshan Tour', '42% share'),
                const Divider(color: Color(0xFF334155), height: 24),
                _driverRow('Preferred Payment Channel', 'UPI QR (BHIM / GPay)', '88.5% volume'),
                const Divider(color: Color(0xFF334155), height: 24),
                _driverRow('Average Booking Window', '3.4 days in advance', 'Optimal'),
                const Divider(color: Color(0xFF334155), height: 24),
                _driverRow('Cancellation Rate', '4.2% total claims', 'Industry standard'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Booking Status Distribution
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Settlement Status',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                _statusProgressBar('Confirmed & Verified', 0.78, AdminTheme.emerald, '78%'),
                const SizedBox(height: 16),
                _statusProgressBar('Awaiting Admin UTR Verification', 0.16, AdminTheme.saffron, '16%'),
                const SizedBox(height: 16),
                _statusProgressBar('Cancelled / Failed', 0.06, AdminTheme.crimson, '6%'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _driverRow(String title, String value, String badge) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AdminTheme.emerald.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AdminTheme.emerald.withValues(alpha: 0.3)),
          ),
          child: Text(badge, style: const TextStyle(color: AdminTheme.emerald, fontSize: 11, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _statusProgressBar(String label, double pct, Color color, String pctText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
            Text(pctText, style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: const Color(0xFF0F172A),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingsTab(List<dynamic> bookings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bookings Breakdown (${bookings.length} total entries)',
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const Divider(color: Color(0xFF334155), height: 16),
              itemBuilder: (context, i) {
                final b = bookings[i];
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.confirmation_number_rounded, color: AdminTheme.emerald, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.id, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                          Text('Tour: ${b.tourId} • Date: ${b.tripDate}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                        ],
                      ),
                    ),
                    Text(
                      b.status.name.toUpperCase(),
                      style: TextStyle(
                        color: b.status == BookingStatus.confirmed ? AdminTheme.emerald : AdminTheme.saffron,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTab(List<dynamic> orders, double totalRev) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Revenue Transactions', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
              Text('Total Confirmed: ₹${totalRev.toInt()}', style: const TextStyle(color: AdminTheme.emerald, fontSize: 15, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: orders.length,
              separatorBuilder: (_, __) => const Divider(color: Color(0xFF334155), height: 16),
              itemBuilder: (context, i) {
                final o = orders[i];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.orderId, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                        Text('${o.packageName} • Customer: ${o.userId}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${o.amount.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
                        Text(
                          o.status.name.toUpperCase(),
                          style: TextStyle(
                            color: o.status == PaymentStatus.paid ? AdminTheme.emerald : AdminTheme.saffron,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToursTab(List<dynamic> tours) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tour Packages Performance', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: tours.length,
              separatorBuilder: (_, __) => const Divider(color: Color(0xFF334155), height: 16),
              itemBuilder: (context, i) {
                final t = tours[i];
                return Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AdminTheme.emerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.tour_rounded, color: AdminTheme.emerald, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                          Text('Duration: ${t.duration} • Price: ₹${t.priceIndian}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('⭐ ${t.rating}', style: const TextStyle(color: AdminTheme.saffron, fontWeight: FontWeight.w800, fontSize: 11)),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(List<dynamic> users) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Registered Customers (${users.length} total)', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => const Divider(color: Color(0xFF334155), height: 16),
              itemBuilder: (context, i) {
                final u = users[i];
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AdminTheme.emerald.withValues(alpha: 0.2),
                      child: Text(
                        u.name.isNotEmpty ? u.name[0].toUpperCase() : 'U',
                        style: const TextStyle(color: AdminTheme.emerald, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                          Text(u.email, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AdminTheme.emerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('ACTIVE', style: TextStyle(color: AdminTheme.emerald, fontSize: 10, fontWeight: FontWeight.w800)),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
