import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/empty_state_view.dart';
import 'widgets/booking_stepper.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  final String bookingId;

  const BookingConfirmationScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bookingsAsync = ref.watch(userBookingsProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/my-bookings');
            }
          },
        ),
        title: const Text('Complete Booking', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          final booking = bookings.where((b) => b.id == bookingId || b.orderId == bookingId).firstOrNull ??
              (bookings.isNotEmpty ? bookings.first : null);

          if (booking == null) {
            return Center(
              child: EmptyStateView(
                icon: '📋',
                title: 'Booking Not Found',
                description: 'Your booking confirmation could not be located.',
                actionText: 'Go to My Bookings',
                onAction: () => context.go('/my-bookings'),
              ),
            );
          }

          final isUnderVerification = booking.isUnderVerification;

          return MaxWidthWrapper(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Stepper: Step 4 Confirmation
                  const ResponsiveBuilder(
                    mobile: BookingStepper(currentStep: 4, isMobile: true),
                    desktop: BookingStepper(currentStep: 4, isMobile: false),
                  ),
                  const SizedBox(height: 16),

                  if (isUnderVerification)
                    _buildVerificationPendingView(booking, isDark, theme, currencyFormatter, context)
                  else
                    _buildConfirmedView(booking, isDark, theme, currencyFormatter, context),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCREEN 6: PAYMENT UNDER VERIFICATION
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildVerificationPendingView(
    dynamic booking,
    bool isDark,
    ThemeData theme,
    NumberFormat currencyFormatter,
    BuildContext context,
  ) {
    return Column(
      children: [
        // Saffron Hourglass Icon
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: AppColors.saffron.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.saffron.withValues(alpha: 0.3), width: 2),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.hourglass_top_rounded, color: AppColors.saffron, size: 42),
        ),
        const SizedBox(height: 18),

        Text(
          'Payment Submitted',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        const Text(
          'We have received your payment details.\nWe are verifying your payment.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
        ),
        const SizedBox(height: 24),

        // Details Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildReceiptRow('Order ID', booking.orderId ?? booking.id, isMonospace: true),
              _buildReceiptRow('Submitted UTR', booking.transactionId ?? 'Under Review', isMonospace: true),
              _buildReceiptRow('Amount', currencyFormatter.format(booking.totalAmount)),
              _buildReceiptRow(
                'Status',
                'Under Verification',
                statusColor: AppColors.saffron,
                statusBg: AppColors.saffron.withValues(alpha: 0.12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Caution Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.saffron.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.saffron.withValues(alpha: 0.3)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.saffron, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'You\'ll be notified once the payment is verified. If you have already paid, please do NOT pay again.',
                  style: TextStyle(fontSize: 12, height: 1.35),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),

        // Action Button
        CustomButton(
          text: 'View My Bookings',
          variant: ButtonVariant.primary,
          isFullWidth: true,
          height: 48,
          onPressed: () => context.go('/my-bookings'),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCREEN 7: BOOKING CONFIRMED
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildConfirmedView(
    dynamic booking,
    bool isDark,
    ThemeData theme,
    NumberFormat currencyFormatter,
    BuildContext context,
  ) {
    return Column(
      children: [
        // Green Checkmark Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.emerald.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.emerald.withValues(alpha: 0.4), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.emerald.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.check_rounded, color: AppColors.emerald, size: 48),
        ),
        const SizedBox(height: 18),

        Text(
          'Booking Confirmed!',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        const Text(
          'Thank you for choosing PuneExplorer!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 24),

        // Ticket Details Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildReceiptRow('Booking ID', booking.orderId ?? booking.id, isMonospace: true),
              _buildReceiptRow('Tour', booking.tourTitle),
              _buildReceiptRow('Date', booking.travelDate),
              _buildReceiptRow('Travelers', '${booking.passengers.length} Passenger(s)'),
              _buildReceiptRow('Amount Paid', currencyFormatter.format(booking.totalAmount)),
              _buildReceiptRow('Payment Method', 'UPI QR'),
              _buildReceiptRow(
                'Status',
                'Confirmed',
                statusColor: AppColors.emerald,
                statusBg: AppColors.emerald.withValues(alpha: 0.12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Actions
        CustomButton(
          text: 'Download Ticket',
          icon: const Icon(Icons.download_rounded, size: 18),
          variant: ButtonVariant.saffron,
          isFullWidth: true,
          height: 48,
          onPressed: () => context.push('/digital-ticket/${booking.id}'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.go('/my-bookings'),
          icon: const Icon(Icons.confirmation_number_outlined, size: 18),
          label: const Text('View My Bookings', style: TextStyle(fontWeight: FontWeight.w700)),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        if (booking.orderId != null) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => context.push('/payment/receipt/${booking.orderId}'),
            icon: const Icon(Icons.receipt_rounded, size: 16, color: AppColors.emerald),
            label: const Text('Download Official Payment Receipt', style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w700)),
          ),
        ],
        const SizedBox(height: 32),

        // Footer Motto
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.emerald.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.temple_hindu_rounded, size: 20, color: AppColors.emerald),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore Pune',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                Text(
                  'One Journey at a Time',
                  style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    bool isMonospace = false,
    Color? statusColor,
    Color? statusBg,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          if (statusColor != null && statusBg != null)
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            )
          else
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  fontFamily: isMonospace ? 'monospace' : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
