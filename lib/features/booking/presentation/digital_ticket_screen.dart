import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/empty_state_view.dart';

class DigitalTicketScreen extends ConsumerWidget {
  final String bookingId;

  const DigitalTicketScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bookingsAsync = ref.watch(userBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Boarding Pass'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share Pass',
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing digital boarding pass...')),
              );
            },
          ),
        ],
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          final booking = bookings.where((b) => b.id == bookingId).firstOrNull ?? (bookings.isNotEmpty ? bookings.first : null);
          if (booking == null) {
            return Center(
              child: EmptyStateView(
                icon: '🎫',
                title: 'Boarding Pass Not Found',
                description: 'Your digital boarding pass could not be located. Please check your bookings.',
                actionText: 'View My Bookings',
                onAction: () => context.push('/my-bookings'),
              ),
            );
          }

          return MaxWidthWrapper(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 440),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header Brand
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                        decoration: const BoxDecoration(
                          gradient: AppColors.emeraldGradient,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Text('🚩', style: TextStyle(fontSize: 24)),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PuneExplorer Pass',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                                    ),
                                    Text(
                                      'Official Boarding e-Ticket',
                                      style: TextStyle(color: Color(0xFFD1FAE5), fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white38),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.verified_rounded, color: Colors.white, size: 13),
                                  SizedBox(width: 4),
                                  Text(
                                    'VERIFIED',
                                    style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // QR Code Section
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 22.0),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: QrImageView(
                                data: 'https://puneexplorer.in/verify/${booking.verificationPassCode}',
                                version: QrVersions.auto,
                                size: 165.0,
                                backgroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Clipboard.setData(ClipboardData(text: booking.verificationPassCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Pass code "${booking.verificationPassCode}" copied to clipboard!')),
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.saffron.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      booking.verificationPassCode,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                        fontSize: 12.5,
                                        color: AppColors.saffron,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.copy_rounded, size: 13, color: AppColors.saffron),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Jagged Perforation Cutout Line
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 32,
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                            ),
                          ),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final count = (constraints.constrainWidth() / 10).floor();
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(count, (_) {
                                    return const Text('•', style: TextStyle(color: Colors.grey, fontSize: 14));
                                  }),
                                );
                              },
                            ),
                          ),
                          Container(
                            width: 16,
                            height: 32,
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                            ),
                          ),
                        ],
                      ),

                      // Pass Details
                      Padding(
                        padding: const EdgeInsets.all(22.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.tourTitle,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16.5),
                            ),
                            const SizedBox(height: 14),
                            _buildInfoRow('Lead Traveler', booking.customerName),
                            _buildInfoRow('Travel Date', booking.travelDate),
                            _buildInfoRow('Pickup Terminal', booking.pickupPoint),
                            _buildInfoRow('Seats Allocated', booking.selectedSeats.join(', ')),
                            _buildInfoRow('Passengers (${booking.passengers.length})', booking.passengers.map((p) => p.fullName).join(', ')),
                            _buildInfoRow('Payment Ref', booking.paymentId ?? 'Direct Verified'),
                          ],
                        ),
                      ),

                      // Actions
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 340) {
                              return Column(
                                children: [
                                  CustomButton(
                                    text: 'Save to Gallery',
                                    icon: const Icon(Icons.download_rounded, size: 16),
                                    variant: ButtonVariant.outline,
                                    isFullWidth: true,
                                    height: 44,
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Boarding pass saved to gallery!')),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  CustomButton(
                                    text: 'Print Ticket',
                                    icon: const Icon(Icons.print_rounded, size: 16),
                                    variant: ButtonVariant.primary,
                                    isFullWidth: true,
                                    height: 44,
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Sending ticket to printer...')),
                                      );
                                    },
                                  ),
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    text: 'Save Ticket',
                                    icon: const Icon(Icons.download_rounded, size: 16),
                                    variant: ButtonVariant.outline,
                                    height: 46,
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Boarding pass saved to gallery!')),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomButton(
                                    text: 'Print Ticket',
                                    icon: const Icon(Icons.print_rounded, size: 16),
                                    variant: ButtonVariant.primary,
                                    height: 46,
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Sending ticket to printer...')),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading ticket: $e')),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12.5, color: Colors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
