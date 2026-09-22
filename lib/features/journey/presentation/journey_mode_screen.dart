import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../data/models/booking.dart';

class JourneyModeScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const JourneyModeScreen({super.key, required this.bookingId});

  @override
  ConsumerState<JourneyModeScreen> createState() => _JourneyModeScreenState();
}

class _JourneyModeScreenState extends ConsumerState<JourneyModeScreen> {
  final int _currentStopIndex = 1; // Simulated live progress at Stop 2

  final List<Map<String, dynamic>> _stops = [
    {
      'name': 'Swargate Bus Terminal',
      'time': '08:00 AM',
      'status': 'Completed',
      'icon': '🚏',
      'tip': 'Tour bus departure on time.',
    },
    {
      'name': 'Shaniwar Wada Palace',
      'time': '08:45 AM - 10:00 AM',
      'status': 'Current Stop',
      'icon': '🏛️',
      'tip': 'Meet guide near Dilli Darwaza fountain.',
    },
    {
      'name': 'Dagdusheth Halwai Ganpati Temple',
      'time': '10:15 AM - 11:15 AM',
      'status': 'Upcoming',
      'icon': '🛕',
      'tip': 'VIP Darshan passes active for group.',
    },
    {
      'name': 'Aga Khan Palace & Memorial',
      'time': '11:45 AM - 01:00 PM',
      'status': 'Upcoming',
      'icon': '🕊️',
      'tip': 'Italian arches and Gandhi museum galleries.',
    },
    {
      'name': 'Royal Puneri Thali Lunch Break',
      'time': '01:15 PM - 02:30 PM',
      'status': 'Upcoming',
      'icon': '🍛',
      'tip': 'Unlimited thali and fresh Mastani dessert.',
    },
    {
      'name': 'Raja Dinkar Kelkar Museum',
      'time': '02:45 PM - 04:15 PM',
      'status': 'Upcoming',
      'icon': '🎨',
      'tip': 'Mastani Mahal replica exhibit.',
    },
    {
      'name': 'Sarasbaug & Ganpati Lake View',
      'time': '04:30 PM - 06:00 PM',
      'status': 'Upcoming',
      'icon': '🌺',
      'tip': 'Evening lotus garden and sunset return.',
    },
  ];

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Calling $phone...')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bookings = ref.watch(userBookingsProvider).value ?? [];
    final Booking? booking = bookings.where((b) => b.id == widget.bookingId).firstOrNull ??
        (bookings.isNotEmpty ? bookings.first : null);
        
    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Live Tour Journey Mode')),
        body: EmptyStateView(
          icon: '🚌',
          title: 'No Active Journey Found',
          description: 'Book a Pune Darshan tour to access live journey tracking with stop-by-stop navigation.',
          actionText: 'Explore Tours',
          onAction: () => context.go('/darshan'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tour Journey Mode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_rounded, color: AppColors.emerald),
            tooltip: 'View Digital Ticket',
            onPressed: () => context.push('/digital-ticket/${widget.bookingId}'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: MaxWidthWrapper(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Live Status Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [const Color(0xFF064E3B), const Color(0xFF047857)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emerald.withValues(alpha: isDark ? 0.3 : 0.2),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.saffron,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.directions_bus_rounded, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text('LIVE ON TOUR', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                      Text(
                        'Pass: ${booking.id}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    booking.tourTitle,
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Travel Date: ${booking.travelDate} • Pickup: ${booking.pickupPoint}',
                    style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Emergency Contacts Strip
            Text('Quick Helpline & Assistance', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildEmergencyButton(
                    icon: Icons.person_pin_rounded,
                    label: 'Tour Guide',
                    phone: '+919822011223',
                    color: AppColors.emerald,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEmergencyButton(
                    icon: Icons.directions_bus_filled_rounded,
                    label: 'Bus Driver',
                    phone: '+919822044556',
                    color: AppColors.skyBlue,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEmergencyButton(
                    icon: Icons.local_police_rounded,
                    label: 'Police 112',
                    phone: '112',
                    color: AppColors.error,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Route Stops Progression
            Text('Tour Itinerary Progress (${_currentStopIndex + 1} / ${_stops.length} Stops)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),

            ...List.generate(_stops.length, (i) {
              final stop = _stops[i];
              final isCompleted = i < _currentStopIndex;
              final isCurrent = i == _currentStopIndex;

              Color badgeColor = Colors.grey;
              if (isCompleted) badgeColor = AppColors.emerald;
              if (isCurrent) badgeColor = AppColors.saffron;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? (isDark ? AppColors.saffron.withValues(alpha: 0.15) : const Color(0xFFFFF7ED))
                      : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCurrent
                        ? AppColors.saffron
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    width: isCurrent ? 1.5 : 1.0,
                  ),
                  boxShadow: AppColors.cardShadow(isDark),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Text(stop['icon'] as String, style: const TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isCompleted ? 'COMPLETED' : isCurrent ? 'CURRENT STOP' : 'UPCOMING',
                                  style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900),
                                ),
                              ),
                              Text(stop['time'] as String, style: TextStyle(fontSize: 11.5, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(stop['name'] as String, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(stop['tip'] as String, style: TextStyle(fontSize: 11.5, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),
            CustomButton(
              text: 'View Scannable Digital Boarding Pass',
              icon: const Icon(Icons.qr_code_2_rounded, size: 18),
              variant: ButtonVariant.primary,
              height: 48,
              onPressed: () => context.push('/digital-ticket/${widget.bookingId}'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton({
    required IconData icon,
    required String label,
    required String phone,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          _makePhoneCall(phone);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
