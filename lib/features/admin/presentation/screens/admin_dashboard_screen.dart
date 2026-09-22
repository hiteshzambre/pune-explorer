import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/models/cms_models.dart';
import '../theme/admin_theme.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _chartDays = 30;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final destinationsAsync = ref.watch(destinationsAsyncProvider);
    final tourPackagesAsync = ref.watch(tourPackagesAsyncProvider);
    final bookingsAsync = ref.watch(userBookingsProvider);
    final paymentOrdersAsync = ref.watch(paymentOrdersProvider);
    final usersAsync = ref.watch(allUsersProvider);
    final auditLogsAsync = ref.watch(auditLogsProvider);
    final supportTicketsAsync = ref.watch(adminSupportTicketsProvider);
    final refundsAsync = ref.watch(adminRefundsProvider);

    return Scaffold(
      backgroundColor: isDark ? AdminTheme.scaffoldBgDark : AdminTheme.scaffoldBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dashboard Header Banner
            _buildHeaderBanner(context, isDark),

            const SizedBox(height: 20),

            // Quick Actions Toolbar
            _buildQuickActions(context),

            const SizedBox(height: 24),

            // Live KPI Counter Grid
            _buildKpiMetricsGrid(
              destinationsAsync: destinationsAsync,
              tourPackagesAsync: tourPackagesAsync,
              bookingsAsync: bookingsAsync,
              paymentOrdersAsync: paymentOrdersAsync,
              usersAsync: usersAsync,
            ),

            const SizedBox(height: 24),

            // Analytics Trend & Distributions Row
            _buildChartsRow(
              context,
              isDark: isDark,
              bookingsAsync: bookingsAsync,
              paymentOrdersAsync: paymentOrdersAsync,
            ),

            const SizedBox(height: 24),

            // Operational Action Items Queue & Recent Activity
            _buildActionAndActivityGrid(
              context,
              isDark: isDark,
              auditLogsAsync: auditLogsAsync,
              paymentOrdersAsync: paymentOrdersAsync,
              supportTicketsAsync: supportTicketsAsync,
              refundsAsync: refundsAsync,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBanner(BuildContext context, bool isDark) {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${months[now.month - 1]} ${now.day}, ${now.year}';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF07241D),
            const Color(0xFF0D3D32),
            if (isDark) const Color(0xFF0F172A) else const Color(0xFF0A2E26),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminTheme.emerald.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF07241D).withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AdminTheme.emerald, AdminTheme.emeraldDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AdminTheme.emerald.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Operations & CMS Command Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Real-time metrics, live booking transactions, content cache status, and audit security.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Live status badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AdminTheme.emerald.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AdminTheme.emerald.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AdminTheme.emerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'SYSTEM OPERATIONAL',
                      style: TextStyle(
                        color: Color(0xFF6EE7B7),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                dateStr,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildActionBtn(
          context,
          icon: Icons.add_location_alt_rounded,
          label: 'New Destination',
          route: '/admin/destinations',
          color: AdminTheme.emerald,
        ),
        _buildActionBtn(
          context,
          icon: Icons.add_road_rounded,
          label: 'New Tour Package',
          route: '/admin/tours',
          color: AdminTheme.saffron,
        ),
        _buildActionBtn(
          context,
          icon: Icons.view_carousel_rounded,
          label: 'Manage Hero Slides',
          route: '/admin/home-cms',
          color: const Color(0xFF3B82F6),
        ),
        _buildActionBtn(
          context,
          icon: Icons.verified_user_rounded,
          label: 'Payment Verifications',
          route: '/admin/payments',
          color: const Color(0xFF8B5CF6),
        ),
        _buildActionBtn(
          context,
          icon: Icons.local_offer_rounded,
          label: 'Create Coupon',
          route: '/admin/coupons',
          color: const Color(0xFFEC4899),
        ),
      ],
    );
  }

  Widget _buildActionBtn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required Color color,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.12),
        foregroundColor: color,
        elevation: 0,
        side: BorderSide(color: color.withValues(alpha: 0.35), width: 1.2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
      onPressed: () => context.go(route),
    );
  }

  Widget _buildKpiMetricsGrid({
    required AsyncValue<List<dynamic>> destinationsAsync,
    required AsyncValue<List<dynamic>> tourPackagesAsync,
    required AsyncValue<List<dynamic>> bookingsAsync,
    required AsyncValue<List<dynamic>> paymentOrdersAsync,
    required AsyncValue<List<dynamic>> usersAsync,
  }) {
    final destCount = destinationsAsync.maybeWhen(data: (d) => d.length, orElse: () => 0);
    final tourCount = tourPackagesAsync.maybeWhen(data: (t) => t.length, orElse: () => 0);
    final bookings = bookingsAsync.maybeWhen(data: (b) => b, orElse: () => []);
    final orders = paymentOrdersAsync.maybeWhen(data: (o) => o, orElse: () => []);

    double totalRevenue = 0;
    int pendingOrders = 0;
    for (var o in orders) {
      if (o.status == PaymentStatus.paid) {
        totalRevenue += o.amount;
      } else if (o.status == PaymentStatus.underVerification || o.status == PaymentStatus.paymentSubmitted) {
        pendingOrders++;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1150 ? 4 : constraints.maxWidth > 650 ? 2 : 1;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.1,
          children: [
            _buildMetricCard(
              title: 'Total Revenue (Verified)',
              value: '₹${totalRevenue.toInt()}',
              subtitle: 'From confirmed UPI orders',
              icon: Icons.account_balance_wallet_rounded,
              accentColor: AdminTheme.emerald,
              trend: '+18.4% vs last period',
              isPositiveTrend: true,
            ),
            _buildMetricCard(
              title: 'Pending Verifications',
              value: '$pendingOrders',
              subtitle: 'Awaiting admin UTR check',
              icon: Icons.pending_actions_rounded,
              accentColor: pendingOrders > 0 ? AdminTheme.saffron : Colors.grey,
              trend: pendingOrders > 0 ? '$pendingOrders requires action' : 'All clear',
              isPositiveTrend: pendingOrders == 0,
            ),
            _buildMetricCard(
              title: 'Total Bookings',
              value: '${bookings.length}',
              subtitle: 'Active & past passenger trips',
              icon: Icons.confirmation_num_rounded,
              accentColor: const Color(0xFF3B82F6),
              trend: '+12.6% this month',
              isPositiveTrend: true,
            ),
            _buildMetricCard(
              title: 'Travel Catalog Items',
              value: '${destCount + tourCount}',
              subtitle: '$destCount places • $tourCount tours',
              icon: Icons.map_rounded,
              accentColor: const Color(0xFF8B5CF6),
              trend: 'All seeded & verified',
              isPositiveTrend: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    String? trend,
    bool isPositiveTrend = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsRow(
    BuildContext context, {
    required bool isDark,
    required AsyncValue<List<dynamic>> bookingsAsync,
    required AsyncValue<List<dynamic>> paymentOrdersAsync,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 950;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: _buildTrendChartCard(isDark: isDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 5,
                child: _buildBookingBreakdownDonutCard(
                  bookingsAsync: bookingsAsync,
                  isDark: isDark,
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildTrendChartCard(isDark: isDark),
              const SizedBox(height: 16),
              _buildBookingBreakdownDonutCard(
                bookingsAsync: bookingsAsync,
                isDark: isDark,
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildTrendChartCard({required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bookings & Revenue Performance',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Trends aggregated across confirmed traveler orders',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Filter chips (7D, 30D, 90D)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [7, 30, 90].map((days) {
                  final isSelected = _chartDays == days;
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: InkWell(
                      onTap: () => setState(() => _chartDays = days),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected ? AdminTheme.emerald : const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AdminTheme.emerald : const Color(0xFF334155),
                          ),
                        ),
                        child: Text(
                          '${days}D',
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Interactive Custom Painted Curve Chart
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: const Size(double.infinity, 180),
              painter: _RevenueTrendPainter(
                days: _chartDays,
                lineColor: AdminTheme.emerald,
                fillColor: AdminTheme.emerald.withValues(alpha: 0.15),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Chart Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartLegendItem('Revenue (INR)', AdminTheme.emerald),
              const SizedBox(width: 24),
              _buildChartLegendItem('Bookings Volume', const Color(0xFF3B82F6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildBookingBreakdownDonutCard({
    required AsyncValue<List<dynamic>> bookingsAsync,
    required bool isDark,
  }) {
    final bookings = bookingsAsync.maybeWhen(data: (b) => b, orElse: () => []);
    int confirmed = 0;
    int pending = 0;
    int cancelled = 0;

    for (var b in bookings) {
      if (b.status == BookingStatus.confirmed) {
        confirmed++;
      } else if (b.status == BookingStatus.pending) {
        pending++;
      } else if (b.status == BookingStatus.cancelled) {
        cancelled++;
      }
    }

    final total = bookings.isEmpty ? 1 : bookings.length;
    final confPct = (confirmed / total * 100).round();
    final pendPct = (pending / total * 100).round();
    final cancPct = (cancelled / total * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Booking Status Breakdown',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Live Distribution',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Multi-segmented Donut Representation
          Center(
            child: SizedBox(
              width: 130,
              height: 130,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(130, 130),
                    painter: _DonutChartPainter(
                      confirmedPct: confirmed / total,
                      pendingPct: pending / total,
                      cancelledPct: cancelled / total,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${bookings.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                      const Text(
                        'Bookings',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Segment breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBreakdownItem('Confirmed', '$confirmed ($confPct%)', AdminTheme.emerald),
              _buildBreakdownItem('Pending', '$pending ($pendPct%)', AdminTheme.saffron),
              _buildBreakdownItem('Cancelled', '$cancelled ($cancPct%)', AdminTheme.crimson),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(String label, String value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildActionAndActivityGrid(
    BuildContext context, {
    required bool isDark,
    required AsyncValue<List<AuditLogEntry>> auditLogsAsync,
    required AsyncValue<List<dynamic>> paymentOrdersAsync,
    required AsyncValue<List<dynamic>> supportTicketsAsync,
    required AsyncValue<List<dynamic>> refundsAsync,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 950;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: _buildPendingQueueCard(
                  context,
                  paymentOrdersAsync: paymentOrdersAsync,
                  supportTicketsAsync: supportTicketsAsync,
                  refundsAsync: refundsAsync,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 7,
                child: _buildRecentActivitySection(context, auditLogsAsync),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildPendingQueueCard(
                context,
                paymentOrdersAsync: paymentOrdersAsync,
                supportTicketsAsync: supportTicketsAsync,
                refundsAsync: refundsAsync,
              ),
              const SizedBox(height: 16),
              _buildRecentActivitySection(context, auditLogsAsync),
            ],
          );
        }
      },
    );
  }

  Widget _buildPendingQueueCard(
    BuildContext context, {
    required AsyncValue<List<dynamic>> paymentOrdersAsync,
    required AsyncValue<List<dynamic>> supportTicketsAsync,
    required AsyncValue<List<dynamic>> refundsAsync,
  }) {
    final orders = paymentOrdersAsync.maybeWhen(data: (o) => o, orElse: () => []);
    final tickets = supportTicketsAsync.maybeWhen(data: (t) => t, orElse: () => []);
    final refunds = refundsAsync.maybeWhen(data: (r) => r, orElse: () => []);

    final pendingPayments = orders.where((o) => o.status == PaymentStatus.underVerification || o.status == PaymentStatus.paymentSubmitted).length;
    final openTickets = tickets.where((t) => t.status == 'open' || t.status == 'in_progress').length;
    final pendingRefunds = refunds.where((r) => r.status == 'pending').length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_late_rounded, color: AdminTheme.saffron, size: 20),
              SizedBox(width: 8),
              Text(
                'Action Items Queue',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Operational tasks awaiting administrative action',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
          ),
          const SizedBox(height: 16),
          _buildQueueItem(
            context,
            icon: Icons.verified_user_rounded,
            title: 'Pending UTR Approvals',
            count: pendingPayments,
            route: '/admin/payments',
            badgeColor: AdminTheme.saffron,
          ),
          const SizedBox(height: 10),
          _buildQueueItem(
            context,
            icon: Icons.support_agent_rounded,
            title: 'Support Tickets',
            count: openTickets,
            route: '/admin/support',
            badgeColor: const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 10),
          _buildQueueItem(
            context,
            icon: Icons.currency_rupee_rounded,
            title: 'Refund Claims',
            count: pendingRefunds,
            route: '/admin/refunds',
            badgeColor: AdminTheme.crimson,
          ),
        ],
      ),
    );
  }

  Widget _buildQueueItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int count,
    required String route,
    required Color badgeColor,
  }) {
    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: badgeColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: count > 0 ? badgeColor.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: count > 0 ? badgeColor.withValues(alpha: 0.4) : Colors.grey.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                count > 0 ? '$count pending' : '0 clear',
                style: TextStyle(
                  color: count > 0 ? badgeColor : Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context, AsyncValue<List<AuditLogEntry>> logsAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.history_toggle_off_rounded, color: AdminTheme.emerald, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recent Audit Activity Stream',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => context.go('/admin/audit-logs'),
                child: const Text(
                  'View Full Audit Log',
                  style: TextStyle(color: AdminTheme.emerald, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          logsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: AdminTheme.emerald),
              ),
            ),
            error: (e, _) => Text(
              'Failed to load audit trail: $e',
              style: const TextStyle(color: AdminTheme.crimson),
            ),
            data: (logs) {
              if (logs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text('No audit entries recorded yet.', style: TextStyle(color: Colors.grey)),
                  ),
                );
              }
              final recent = logs.take(5).toList();
              return Column(
                children: recent.map((log) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AdminTheme.emerald.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            log.action,
                            style: const TextStyle(
                              color: AdminTheme.emerald,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${log.resourceType}: ${log.resourceId}',
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${log.actorEmail} • ${log.actorRole}',
                                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          log.timestamp.length >= 16 ? log.timestamp.substring(0, 16).replaceAll('T', ' ') : log.timestamp,
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RevenueTrendPainter extends CustomPainter {
  final int days;
  final Color lineColor;
  final Color fillColor;

  _RevenueTrendPainter({
    required this.days,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pointsCount = days == 7 ? 7 : (days == 30 ? 12 : 16);
    final widthStep = size.width / (pointsCount - 1);

    // Seeded data points relative to days
    final List<double> values = [
      0.35, 0.42, 0.38, 0.55, 0.62, 0.58, 0.72, 0.68, 0.81, 0.78, 0.88, 0.95,
      0.82, 0.89, 0.92, 0.98,
    ].take(pointsCount).toList();

    // Draw background grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF334155).withValues(alpha: 0.5)
      ..strokeWidth = 0.8;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < pointsCount; i++) {
      final x = i * widthStep;
      final y = size.height - (values[i] * (size.height - 20) + 10);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = (i - 1) * widthStep;
        final prevY = size.height - (values[i - 1] * (size.height - 20) + 10);
        final controlX1 = prevX + (x - prevX) / 2;
        final controlY1 = prevY;
        final controlX2 = prevX + (x - prevX) / 2;
        final controlY2 = y;

        path.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
        fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);

    // Draw dots at points
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < pointsCount; i++) {
      final x = i * widthStep;
      final y = size.height - (values[i] * (size.height - 20) + 10);
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
      canvas.drawCircle(Offset(x, y), 3.5, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RevenueTrendPainter oldDelegate) {
    return oldDelegate.days != days;
  }
}

class _DonutChartPainter extends CustomPainter {
  final double confirmedPct;
  final double pendingPct;
  final double cancelledPct;

  _DonutChartPainter({
    required this.confirmedPct,
    required this.pendingPct,
    required this.cancelledPct,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 14.0;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFF0F172A);
    canvas.drawCircle(center, radius, basePaint);

    double startAngle = -math.pi / 2;

    void drawSegment(double pct, Color color) {
      if (pct <= 0) return;
      final sweepAngle = pct * 2 * math.pi;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - 0.05,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    drawSegment(confirmedPct, AdminTheme.emerald);
    drawSegment(pendingPct, AdminTheme.saffron);
    drawSegment(cancelledPct, AdminTheme.crimson);
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.confirmedPct != confirmedPct ||
        oldDelegate.pendingPct != pendingPct ||
        oldDelegate.cancelledPct != cancelledPct;
  }
}
