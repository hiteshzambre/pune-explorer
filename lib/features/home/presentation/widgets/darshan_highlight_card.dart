import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';

class DarshanHighlightCard extends StatelessWidget {
  const DarshanHighlightCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFF064E3B), const Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.emerald.withValues(alpha: 0.3) : Colors.transparent,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald.withValues(alpha: isDark ? 0.35 : 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background subtle bus graphic
          const Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.12,
              child: Text('🚌', style: TextStyle(fontSize: 150)),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 360 ? 16.0 : 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.saffron,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: AppColors.glowShadow(AppColors.saffron),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Official Pune Darshan',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Text(
                        '⚡ 28-Seat AC Volvo',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Title
                const Text(
                  'Royal Pune City Darshan\nDaily Guided Bus Tour',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                const Text(
                  'Shaniwar Wada • Dagdusheth Ganpati (VIP Pass) • Aga Khan Palace • Sarasbaug • Raja Kelkar Museum',
                  style: TextStyle(color: Color(0xFFD1FAE5), fontSize: 12.5, height: 1.45),
                ),
                const SizedBox(height: 20),

                // Pricing & CTA
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 420) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('All-Inclusive Ticket', style: TextStyle(color: Color(0xFFA7F3D0), fontSize: 11, fontWeight: FontWeight.w600)),
                              Text(
                                '₹499 / person',
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          CustomButton(
                            text: 'Select Seats & Book',
                            icon: const Icon(Icons.event_seat_rounded, size: 16),
                            variant: ButtonVariant.saffron,
                            isFullWidth: true,
                            height: 48,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              context.go('/darshan');
                            },
                          ),
                        ],
                      );
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('All-Inclusive Ticket', style: TextStyle(color: Color(0xFFA7F3D0), fontSize: 11, fontWeight: FontWeight.w600)),
                              Text(
                                '₹499 / person',
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: CustomButton(
                            text: 'Select Seats & Book',
                            icon: const Icon(Icons.event_seat_rounded, size: 16),
                            variant: ButtonVariant.saffron,
                            height: 48,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              context.go('/darshan');
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
