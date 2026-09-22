import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/booking.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../services/booking_service.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  void _showCancellationModal(BuildContext context, WidgetRef ref, Booking booking) {
    final quote = BookingService.calculateRefundQuote(booking);
    String reason = 'Schedule changed / Personal emergency';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
              SizedBox(width: 8),
              Text('Cancel Tour Booking', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.tourTitle,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text('Booking ID: ${booking.id}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const Divider(height: 20),

                // Refund Policy Breakdown
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(quote.tierDescription, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.emerald)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Original Total Paid:', style: TextStyle(fontSize: 12)),
                          Text('₹${quote.originalTotal.toInt()}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Cancellation Fee:', style: TextStyle(fontSize: 12)),
                          Text('-₹${quote.cancellationFee.toInt()}', style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 12)),
                        ],
                      ),
                      const Divider(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Eligible Refund Amount:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                          Text('₹${quote.refundAmount.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.emerald)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  initialValue: reason,
                  decoration: const InputDecoration(labelText: 'Reason for Cancellation'),
                  items: const [
                    DropdownMenuItem(value: 'Schedule changed / Personal emergency', child: Text('Schedule changed / Personal', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'Weather conditions / Monsoon alert', child: Text('Weather conditions', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'Booked another tour package', child: Text('Booked another tour package', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'Other reason', child: Text('Other reason', style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => reason = val);
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Refund will be processed back to original UPI/Card account within 2-3 business days.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Keep Booking'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedBooking = booking.copyWith(
                  status: BookingStatus.cancelled,
                  refundAmount: quote.refundAmount,
                  cancellationReason: reason,
                  cancellationDate: DateTime.now().toIso8601String(),
                );
                ref.read(userBookingsProvider.notifier).addBooking(updatedBooking);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Booking cancelled. ₹${quote.refundAmount.toInt()} refund initiated.')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
              child: const Text('Confirm Cancellation'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bookingsAsync = ref.watch(userBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tour Bookings & Passes'),
      ),
      body: MaxWidthWrapper(
        child: bookingsAsync.when(
          data: (bookings) {
            if (bookings.isEmpty) {
              return EmptyStateView(
                icon: '🎟️',
                title: 'No Bookings Yet',
                description: 'You have not booked any Pune Darshan or tour packages yet. Book a tour to get your digital boarding pass.',
                actionText: 'Browse Pune Darshan Tours',
                onAction: () => context.go('/darshan'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return _buildBookingCard(booking, isDark, theme, context, ref);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading bookings: $e')),
        ),
      ),
    );
  }

  Widget _buildBookingCard(
    Booking booking,
    bool isDark,
    ThemeData theme,
    BuildContext context,
    WidgetRef ref,
  ) {
    final isCancelled = booking.status == BookingStatus.cancelled;
    final isUnderVerification = booking.isUnderVerification;
    final isPaymentFailed = booking.isPaymentFailed;
    final isPaid = booking.isPaid && !isCancelled;

    String statusText = 'CONFIRMED';
    Color statusColor = AppColors.emerald;
    if (isCancelled) {
      statusText = 'CANCELLED';
      statusColor = AppColors.error;
    } else if (isUnderVerification) {
      statusText = 'VERIFYING PAYMENT';
      statusColor = AppColors.saffron;
    } else if (isPaymentFailed) {
      statusText = 'PAYMENT FAILED';
      statusColor = AppColors.error;
    } else if (isPaid) {
      statusText = 'PAID';
      statusColor = AppColors.emerald;
    } else {
      statusText = 'PENDING PAYMENT';
      statusColor = AppColors.saffron;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
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
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                booking.orderId != null ? '#${booking.orderId}' : booking.verificationPassCode,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.saffron),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(booking.tourTitle, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 4),
          Text('Travel Date: ${booking.travelDate} • ${booking.pickupPoint}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text('Seats: ${booking.selectedSeats.join(', ')} • ${booking.passengers.length} Passenger(s)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          if (booking.transactionId != null) ...[
            const SizedBox(height: 4),
            Text(
              'UTR Ref: ${booking.transactionId}',
              style: const TextStyle(fontSize: 11.5, fontFamily: 'monospace', color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ],
          if (booking.customization != null && booking.customization!.totalAddOnPerPerson > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Add-ons: ${booking.customization!.transportMode} • ${booking.customization!.mealOption}',
              style: const TextStyle(fontSize: 11.5, color: AppColors.emerald, fontWeight: FontWeight.w600),
            ),
          ],
          if (isCancelled && booking.refundAmount > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Refund of ₹${booking.refundAmount.toInt()} initiated to original payment source.',
              style: const TextStyle(fontSize: 11.5, color: AppColors.error, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final priceWidget = Text(
                '₹${booking.totalAmount.toInt()}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.emerald),
              );

              final actionsWidget = Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (!isCancelled && isPaid)
                    TextButton(
                      onPressed: () => _showCancellationModal(context, ref, booking),
                      child: const Text('Cancel Tour', style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  if (isUnderVerification && booking.orderId != null)
                    ElevatedButton.icon(
                      onPressed: () => context.push('/payment/qr/${booking.orderId}'),
                      icon: const Icon(Icons.refresh_rounded, size: 14),
                      label: const Text('Check Status'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.saffron,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  if (!isPaid && !isUnderVerification && !isCancelled && booking.orderId != null)
                    ElevatedButton.icon(
                      onPressed: () => context.push('/payment/qr/${booking.orderId}'),
                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 14),
                      label: const Text('Pay via QR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.saffron,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  if (isPaid && booking.orderId != null)
                    OutlinedButton.icon(
                      onPressed: () => context.push('/payment/receipt/${booking.orderId}'),
                      icon: const Icon(Icons.receipt_rounded, size: 14),
                      label: const Text('Receipt'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        textStyle: const TextStyle(fontSize: 11.5),
                      ),
                    ),
                  if (isPaid)
                    ElevatedButton.icon(
                      onPressed: () => context.push('/journey/${booking.id}'),
                      icon: const Icon(Icons.navigation_rounded, size: 14),
                      label: const Text('Journey'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.saffron,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ),
                  if (isPaid)
                    ElevatedButton.icon(
                      onPressed: () => context.push('/digital-ticket/${booking.id}'),
                      icon: const Icon(Icons.qr_code_rounded, size: 14),
                      label: const Text('Digital Pass'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        textStyle: const TextStyle(fontSize: 11.5),
                      ),
                    ),
                ],
              );

              if (constraints.maxWidth < 360) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    priceWidget,
                    const SizedBox(height: 10),
                    actionsWidget,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  priceWidget,
                  actionsWidget,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

