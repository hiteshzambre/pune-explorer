import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../data/models/booking.dart';

/// 'Recent Activity' card matching reference media_1789362379350.jpg
class RecentActivityCard extends StatelessWidget {
  final List<Booking> bookings;
  final bool isDark;
  final VoidCallback onViewAll;

  const RecentActivityCard({
    super.key,
    required this.bookings,
    required this.isDark,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    // If real bookings are present, use them; otherwise use default curated items from reference
    final items = _getActivityItems();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFEDF2F7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.saffron.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.access_time_filled_rounded,
                          size: 16,
                          color: AppColors.saffron,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Recent Activity',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onViewAll();
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.emerald,
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(Icons.arrow_forward_rounded, size: 13, color: AppColors.emerald),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // List of Activities
          Column(
            children: items.map((item) => _buildActivityRow(item)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(_ActivityItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onViewAll();
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: item.badgeColor.withValues(alpha: 0.15),
              ),
              clipBehavior: Clip.antiAlias,
              child: Center(
                child: Icon(
                  item.icon,
                  size: 24,
                  color: item.badgeColor,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Title & Meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 11,
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${item.date} • ${item.travelers}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: item.badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                item.status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: item.badgeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_ActivityItem> _getActivityItems() {
    if (bookings.isNotEmpty) {
      return bookings.take(3).map((b) {
        final dateStr = b.travelDate;
        final travelersStr = '${b.passengers.length} ${b.passengers.length == 1 ? "Traveler" : "Travelers"}';
        String statusLabel;
        Color statusColor;
        IconData icon;

        switch (b.status) {
          case BookingStatus.confirmed:
          case BookingStatus.paid:
            statusLabel = 'Confirmed';
            statusColor = const Color(0xFF10B981);
            icon = Icons.confirmation_number_rounded;
            break;
          case BookingStatus.pendingPayment:
          case BookingStatus.pending:
          case BookingStatus.underVerification:
          case BookingStatus.paymentSubmitted:
            statusLabel = 'Pending';
            statusColor = const Color(0xFFF59E0B);
            icon = Icons.pending_actions_rounded;
            break;
          default:
            statusLabel = 'Completed';
            statusColor = const Color(0xFF3B82F6);
            icon = Icons.task_alt_rounded;
        }

        return _ActivityItem(
          title: b.tourTitle,
          date: dateStr,
          travelers: travelersStr,
          status: statusLabel,
          badgeColor: statusColor,
          icon: icon,
        );
      }).toList();
    }

    // Default matching reference media_1789362379350.jpg
    return const [
      _ActivityItem(
        title: 'Classic Pune Darshan',
        date: 'Tomorrow',
        travelers: '2 Travelers',
        status: 'Confirmed',
        badgeColor: Color(0xFF10B981),
        icon: Icons.temple_hindu_rounded,
      ),
      _ActivityItem(
        title: 'Sinhagad Fort Sunrise Trek',
        date: '15 Dec 2026',
        travelers: '4 Travelers',
        status: 'Pending',
        badgeColor: Color(0xFFF59E0B),
        icon: Icons.fort_rounded,
      ),
      _ActivityItem(
        title: 'Aga Khan Palace Visit',
        date: '21 Dec 2026',
        travelers: '1 Traveler',
        status: 'Completed',
        badgeColor: Color(0xFF3B82F6),
        icon: Icons.account_balance_rounded,
      ),
    ];
  }
}

class _ActivityItem {
  final String title;
  final String date;
  final String travelers;
  final String status;
  final Color badgeColor;
  final IconData icon;

  const _ActivityItem({
    required this.title,
    required this.date,
    required this.travelers,
    required this.status,
    required this.badgeColor,
    required this.icon,
  });
}
