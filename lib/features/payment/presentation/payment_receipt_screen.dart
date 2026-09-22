import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../data/models/payment_order.dart';

class PaymentReceiptScreen extends ConsumerWidget {
  final String orderId;

  const PaymentReceiptScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final order = ref.watch(paymentOrderByIdProvider(orderId));
    final bookingsAsync = ref.watch(userBookingsProvider);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment Receipt')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.receipt_long_outlined, size: 56, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Receipt Not Found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text('Order Ref: $orderId', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/my-bookings'),
                child: const Text('Go to My Bookings'),
              ),
            ],
          ),
        ),
      );
    }

    final booking = bookingsAsync.value?.where((b) => b.id == order.bookingId || b.orderId == order.orderId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Receipt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Receipt',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Receipt link copied to clipboard.')),
              );
            },
          ),
        ],
      ),
      body: MaxWidthWrapper(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildReceiptCard(order, booking, isDark, theme, context),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Download Receipt',
                      icon: const Icon(Icons.download_rounded, size: 16),
                      variant: ButtonVariant.outline,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Receipt #${order.orderId} saved to your device.'),
                            backgroundColor: AppColors.emerald,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Digital Ticket',
                      icon: const Icon(Icons.airplane_ticket_outlined, size: 16),
                      variant: ButtonVariant.primary,
                      onPressed: () => context.go('/booking-confirmation/${order.bookingId}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptCard(
    PaymentOrder order,
    dynamic booking,
    bool isDark,
    ThemeData theme,
    BuildContext context,
  ) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final isPaid = order.status == PaymentStatus.paid;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Receipt Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.emerald,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.explore_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'PuneExplorer',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Official Tour Payment Receipt', style: TextStyle(fontSize: 11.5, color: Colors.grey)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isPaid
                      ? AppColors.emerald.withValues(alpha: 0.15)
                      : AppColors.saffron.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isPaid ? AppColors.emerald : AppColors.saffron,
                  ),
                ),
                child: Text(
                  isPaid ? 'PAID' : 'UNDER VERIFICATION',
                  style: TextStyle(
                    color: isPaid ? AppColors.emerald : AppColors.saffron,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Metadata Grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ORDER NUMBER', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(order.orderId, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, fontFamily: 'monospace')),
                    const SizedBox(height: 10),
                    const Text('BOOKING REFERENCE', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(order.bookingId, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DATE & TIME', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    const Text('PAYMENT METHOD', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    const Text('UPI QR (Instant Transfer)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Package & Traveler Details
          Text(order.packageName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          if (booking != null) ...[
            const SizedBox(height: 6),
            Text(
              'Travel Date: ${booking.travelDate}',
              style: const TextStyle(fontSize: 12.5, color: Colors.grey),
            ),
            Text(
              'Boarding: ${booking.pickupPoint} • Seats: ${booking.selectedSeats.join(', ')}',
              style: const TextStyle(fontSize: 12.5, color: Colors.grey),
            ),
            Text(
              'Customer: ${booking.customerName} (${booking.customerPhone})',
              style: const TextStyle(fontSize: 12.5, color: Colors.grey),
            ),
          ],
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Financial Breakdown
          const Text('PAYMENT BREAKDOWN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey)),
          const SizedBox(height: 10),
          if (booking != null) ...[
            _buildReceiptRow('Base Package Fare', currencyFormatter.format(booking.basePrice)),
            if (booking.seatExtraPrice > 0)
              _buildReceiptRow('Add-ons & Extras', '+${currencyFormatter.format(booking.seatExtraPrice)}'),
            if (booking.discountAmount > 0)
              _buildReceiptRow('Coupon Discount', '-${currencyFormatter.format(booking.discountAmount)}', color: AppColors.emerald),
            _buildReceiptRow('GST (5%)', currencyFormatter.format(booking.gstAmount)),
            _buildReceiptRow('Platform Fee', currencyFormatter.format(booking.platformFee)),
          ] else ...[
            _buildReceiptRow('Total Amount', currencyFormatter.format(order.amount)),
          ],
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount Paid', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              Text(
                currencyFormatter.format(order.amount),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.emerald),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Transaction / UTR Verification Details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReceiptRow('Transaction ID / UTR', order.transactionId ?? 'Awaiting Submission', isMonospace: true),
                _buildReceiptRow('Merchant Payee', order.merchantUpiId),
                if (order.verifiedAt != null)
                  _buildReceiptRow('Verification Timestamp', DateFormat('dd MMM yyyy, hh:mm a').format(order.verifiedAt!)),
                if (order.verifiedBy != null)
                  _buildReceiptRow('Verified By Authority', order.verifiedBy!),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Center(
            child: Text(
              'Thank you for traveling with PuneExplorer. Have a wonderful experience!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isMonospace = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: isMonospace ? 'monospace' : null,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
