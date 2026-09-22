import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../data/models/booking.dart';
import '../../../data/models/payment_order.dart';
import '../../../services/payment_service.dart';
import '../../booking/presentation/widgets/booking_stepper.dart';

class QRPaymentScreen extends ConsumerStatefulWidget {
  final String orderId;

  const QRPaymentScreen({super.key, required this.orderId});

  @override
  ConsumerState<QRPaymentScreen> createState() => _QRPaymentScreenState();
}

class _QRPaymentScreenState extends ConsumerState<QRPaymentScreen> {
  final TextEditingController _utrController = TextEditingController();
  Timer? _countdownTimer;
  Duration _remainingTime = const Duration(minutes: 10);
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _isExpired = false;
  int _selectedPaymentTab = 0;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final order = ref.read(paymentOrderByIdProvider(widget.orderId));
      if (order != null) {
        final remaining = order.remainingDuration;
        if (remaining == Duration.zero) {
          timer.cancel();
          if (mounted) {
            setState(() {
              _remainingTime = Duration.zero;
              _isExpired = true;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _remainingTime = remaining;
              _isExpired = false;
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _utrController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _handleOpenUpiApp(String upiUri) async {
    try {
      final uri = Uri.parse(upiUri);
      final launched = await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No dedicated UPI app detected. Please scan the QR code using Google Pay, PhonePe, or Paytm.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scan the QR code with any UPI app on your device.'),
          ),
        );
      }
    }
  }

  void _handleCopyUpiId(String upiId) {
    Clipboard.setData(ClipboardData(text: upiId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('UPI ID copied: $upiId'),
          ],
        ),
        backgroundColor: AppColors.emerald,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && data!.text!.isNotEmpty) {
      setState(() {
        _utrController.text = data.text!.trim();
        _errorMessage = null;
      });
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _handleSubmitUtr(PaymentOrder order) async {
    if (_isSubmitting) return;

    final validationError = UpiPaymentEngine.validateUtr(_utrController.text);
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    try {
      final trimmedUtr = _utrController.text.trim();

      // Submit the transaction reference to move order to UNDER_VERIFICATION
      await ref.read(paymentOrdersProvider.notifier).submitTransactionId(
            orderId: order.orderId,
            transactionId: trimmedUtr,
          );

      // Refresh bookings provider so that user profile / history is synced
      ref.invalidate(userBookingsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment details submitted successfully! Awaiting verification.'),
            backgroundColor: AppColors.saffron,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleRegenerateQR(PaymentOrder order) async {
    setState(() => _isSubmitting = true);
    try {
      final refreshed = await ref.read(paymentOrdersProvider.notifier).regenerateOrder(order.orderId);
      if (mounted) {
        _startCountdown();
        setState(() {
          _errorMessage = null;
          _isExpired = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New QR session generated: ${refreshed.orderId}'),
            backgroundColor: AppColors.emerald,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to regenerate QR: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final order = ref.watch(paymentOrderByIdProvider(widget.orderId));
    final bookingsAsync = ref.watch(userBookingsProvider);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('UPI QR Payment')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.receipt_long_outlined, size: 56, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Payment Order Not Found', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Order Ref: ${widget.orderId}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Go to My Bookings',
                variant: ButtonVariant.primary,
                onPressed: () => context.go('/my-bookings'),
              ),
            ],
          ),
        ),
      );
    }

    // Find associated booking
    final booking = bookingsAsync.value?.where((b) => b.id == order.bookingId || b.orderId == order.orderId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay by UPI QR'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/my-bookings');
            }
          },
        ),
      ),
      body: MaxWidthWrapper(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SingleChildScrollView(
          child: ResponsiveBuilder(
            mobile: _buildMobileLayout(order, booking, isDark, theme),
            desktop: _buildDesktopLayout(order, booking, isDark, theme),
          ),
        ),
      ),
    );
  }

  // ── DESKTOP SPLIT LAYOUT ───────────────────────────────────────────────────
  Widget _buildDesktopLayout(PaymentOrder order, Booking? booking, bool isDark, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BookingStepper(currentStep: 3, isMobile: false),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBookingSummaryCard(order, booking, isDark, theme),
                  const SizedBox(height: 16),
                  _buildPaymentInstructionsCard(order, isDark, theme),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 6,
              child: _buildQRAndVerificationSection(order, isDark, theme),
            ),
          ],
        ),
      ],
    );
  }

  // ── MOBILE VERTICAL LAYOUT ─────────────────────────────────────────────────
  Widget _buildMobileLayout(PaymentOrder order, Booking? booking, bool isDark, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BookingStepper(currentStep: 3, isMobile: true),
        const SizedBox(height: 12),
        _buildBookingSummaryCard(order, booking, isDark, theme),
        const SizedBox(height: 16),
        _buildQRAndVerificationSection(order, isDark, theme),
        const SizedBox(height: 16),
        _buildPaymentInstructionsCard(order, isDark, theme),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── 1. BOOKING SUMMARY CARD ────────────────────────────────────────────────
  Widget _buildBookingSummaryCard(PaymentOrder order, Booking? booking, bool isDark, ThemeData theme) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    // Compute breakdown values if booking is available, else derived
    final double basePrice = booking != null
        ? booking.basePrice
        : (order.amount > 359 ? ((order.amount - 99) / 1.05).roundToDouble() : (order.amount * 0.95).roundToDouble());
    final double platformFee = booking != null
        ? booking.platformFee
        : (order.amount > 359 ? 99.0 : 0.0);
    final double gstAmount = booking != null
        ? booking.gstAmount
        : (order.amount - basePrice - platformFee > 0 ? (order.amount - basePrice - platformFee).roundToDouble() : 0.0);

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
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Flexible(
                      child: Text(
                        'Booking Summary',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'SECURE',
                        style: TextStyle(color: AppColors.emerald, fontSize: 9.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/booking/${order.packageId}');
                  }
                },
                icon: const Icon(Icons.edit_outlined, size: 14, color: AppColors.emerald),
                label: const Text(
                  'Edit',
                  style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w700, fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            order.packageName,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (booking != null) ...[
            _buildInfoRow('Date', booking.travelDate.toString()),
            _buildInfoRow('Travelers', '${booking.passengers.length} Traveler(s)'),
            if (booking.customization != null) ...[
              _buildInfoRow('Transport', booking.customization!.transportMode),
              _buildInfoRow('Meal Plan', booking.customization!.mealOption),
            ],
          ] else ...[
            _buildInfoRow('Order Ref', order.orderId, isMonospace: true),
            _buildInfoRow('Booking Ref', order.bookingId),
          ],
          const Divider(height: 20),
          _buildInfoRow('Base Tour Fare', currencyFormatter.format(basePrice)),
          if (booking != null && booking.seatExtraPrice > 0)
            _buildInfoRow('Seat Selection', '+${currencyFormatter.format(booking.seatExtraPrice)}'),
          if (booking != null && booking.discountAmount > 0)
            _buildInfoRow('Discount', '-${currencyFormatter.format(booking.discountAmount)}', color: AppColors.emerald),
          if (gstAmount > 0)
            _buildInfoRow('GST (5%)', currencyFormatter.format(gstAmount)),
          if (platformFee > 0)
            _buildInfoRow('Platform Fee', currencyFormatter.format(platformFee)),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Total Amount to Pay',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                currencyFormatter.format(order.amount),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.emerald),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── PAYMENT METHOD TABS ───────────────────────────────────────────────────
  Widget _buildPaymentMethodTabs(bool isDark) {
    final methods = [
      {'name': 'UPI QR', 'icon': Icons.qr_code_2_rounded},
      {'name': 'UPI ID', 'icon': Icons.alternate_email_rounded},
      {'name': 'Card', 'icon': Icons.credit_card_rounded},
      {'name': 'Net Banking', 'icon': Icons.account_balance_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(methods.length, (idx) {
            final isSelected = _selectedPaymentTab == idx;
            final m = methods[idx];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                onTap: () => setState(() => _selectedPaymentTab = idx),
                borderRadius: BorderRadius.circular(9),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppColors.darkSurface : Colors.white)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        m['icon'] as IconData,
                        size: 15,
                        color: isSelected ? AppColors.emerald : Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        m['name'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? AppColors.emerald : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── 2. QR CODE & VERIFICATION STATUS SECTION ───────────────────────────────
  Widget _buildQRAndVerificationSection(PaymentOrder order, bool isDark, ThemeData theme) {
    // If order is PAID
    if (order.isPaid) {
      return _buildPaidSuccessCard(order, isDark, theme);
    }

    // If order is UNDER VERIFICATION (Critical double-payment guard!)
    if (order.isUnderVerification) {
      return _buildUnderVerificationCard(order, isDark, theme);
    }

    // If payment session has EXPIRED
    if (_isExpired || order.isExpired) {
      return _buildExpiredCard(order, isDark, theme);
    }

    // Active checkout with tabs
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPaymentMethodTabs(isDark),
        const SizedBox(height: 14),
        if (_selectedPaymentTab == 0)
          _buildActivePaymentCard(order, isDark, theme)
        else if (_selectedPaymentTab == 1)
          _buildUpiIdTab(order, isDark, theme)
        else if (_selectedPaymentTab == 2)
          _buildCardTab(order, isDark, theme)
        else
          _buildNetBankingTab(order, isDark, theme),
      ],
    );
  }

  // ── 2A. ACTIVE PAYMENT CARD (QR + TIMER + INPUT) ───────────────────────────
  Widget _buildActivePaymentCard(PaymentOrder order, bool isDark, ThemeData theme) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header: UPI QR Payment + Secure & Encrypted
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_scanner_rounded, color: AppColors.emerald, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'UPI QR Payment',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline_rounded, size: 12, color: AppColors.emerald),
                    SizedBox(width: 4),
                    Text(
                      'Secure & Encrypted',
                      style: TextStyle(color: AppColors.emerald, fontSize: 10.5, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // QR Code Frame
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.emerald.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                QrImageView(
                  data: order.upiUri,
                  version: QrVersions.auto,
                  size: 190,
                  gapless: true,
                  embeddedImage: null,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF0F3E2E), // Deep Pune emerald
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF134E3F),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormatter.format(order.amount),
                  style: const TextStyle(
                    color: Color(0xFF0F3E2E),
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const Text(
                  'Scan with any UPI app',
                  style: TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Supported UPI Apps Branding Strip
          const Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text('Google Pay', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
              Text('•', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('PhonePe', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
              Text('•', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('Paytm', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
              Text('•', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('BHIM', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
              Text('•', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('Any UPI', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 14),

          // Quick Action Buttons (Open App / Copy UPI ID)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _handleOpenUpiApp(order.upiUri),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('Open UPI App', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.emerald,
                  side: const BorderSide(color: AppColors.emerald),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _handleCopyUpiId(order.merchantUpiId),
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy UPI ID', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : Colors.black87,
                  side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Expiry Countdown Badge (UI-003 Contrast and Visibility Fix)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: _isExpired
                  ? (isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7))
                  : (_remainingTime.inSeconds <= 60
                      ? (isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7))
                      : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isExpired || _remainingTime.inSeconds <= 60
                    ? const Color(0xFFF59E0B)
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isExpired ? Icons.error_outline_rounded : Icons.timer_outlined,
                  size: 15,
                  color: const Color(0xFFF59E0B),
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    _isExpired
                        ? 'Payment window ended. Please generate a new QR session.'
                        : 'Payment window expires in ${_formatDuration(_remainingTime)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 28),

          // Transaction ID / UTR Input
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter Transaction Details',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Enter the 12-digit UTR / Transaction ID from your UPI app receipt.',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _utrController,
                  enabled: !_isSubmitting,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Enter UTR / Transaction ID',
                    hintText: 'e.g. 425619842011',
                    errorText: _errorMessage,
                    prefixIcon: const Icon(Icons.tag_rounded, size: 18),
                    suffixIcon: IconButton(
                      tooltip: 'Paste from clipboard',
                      icon: const Icon(Icons.content_paste_rounded, size: 18),
                      onPressed: _isSubmitting ? null : _pasteFromClipboard,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                CustomButton(
                  text: _isSubmitting ? 'Verifying Details...' : 'Submit Payment Details',
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  variant: ButtonVariant.saffron,
                  isLoading: _isSubmitting,
                  isFullWidth: true,
                  height: 48,
                  onPressed: _isSubmitting || _isExpired ? null : () => _handleSubmitUtr(order),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Do not pay twice. Verification takes 1-2 minutes.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 2A-1. UPI ID TAB ────────────────────────────────────────────────────────
  Widget _buildUpiIdTab(PaymentOrder order, bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.alternate_email_rounded, color: AppColors.emerald, size: 20),
              const SizedBox(width: 8),
              Text('Pay using UPI ID / VPA', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Transfer directly to PuneExplorer Official Merchant UPI ID:',
            style: TextStyle(fontSize: 12.5, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.merchantUpiId,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.emerald),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _handleCopyUpiId(order.merchantUpiId),
                  icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.emerald),
                  label: const Text('Copy', style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Enter 12-digit UTR below after completing transfer:'),
          const SizedBox(height: 8),
          TextField(
            controller: _utrController,
            decoration: InputDecoration(
              labelText: '12-digit UTR / Reference ID',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 14),
          CustomButton(
            text: 'Submit Payment Details',
            variant: ButtonVariant.saffron,
            isFullWidth: true,
            isLoading: _isSubmitting,
            onPressed: () => _handleSubmitUtr(order),
          ),
        ],
      ),
    );
  }

  // ── 2A-2. CARD TAB ──────────────────────────────────────────────────────────
  Widget _buildCardTab(PaymentOrder order, bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card_rounded, color: AppColors.emerald, size: 20),
              const SizedBox(width: 8),
              Text('Debit / Credit Card', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.saffron.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.saffron.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  'COMING SOON',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.saffron, letterSpacing: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.saffron.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.saffron, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Card payments are coming soon. Please use UPI QR for instant secure payments.',
                    style: TextStyle(fontSize: 11.5, color: AppColors.saffron, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Card Number',
              hintText: '4111 2222 3333 4444',
              prefixIcon: const Icon(Icons.credit_card),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Valid Thru (MM/YY)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.saffron.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '💡 Tip: UPI QR payments have 0% gateway fees and instant verification.',
              style: TextStyle(fontSize: 11.5, color: AppColors.saffron, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => setState(() => _selectedPaymentTab = 0),
            icon: const Icon(Icons.qr_code_2_rounded, size: 16, color: AppColors.emerald),
            label: const Text('Pay by UPI QR Instead (Recommended)', style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              side: const BorderSide(color: AppColors.emerald),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // ── 2A-3. NET BANKING TAB ───────────────────────────────────────────────────
  Widget _buildNetBankingTab(PaymentOrder order, bool isDark, ThemeData theme) {
    final banks = ['State Bank of India', 'HDFC Bank', 'ICICI Bank', 'Axis Bank', 'Bank of Maharashtra', 'Kotak Mahindra'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_rounded, color: AppColors.emerald, size: 20),
              const SizedBox(width: 8),
              Text('Net Banking', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.saffron.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.saffron.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  'COMING SOON',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.saffron, letterSpacing: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.saffron.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.saffron, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Net banking is coming soon. Please use UPI QR for instant secure payments.',
                    style: TextStyle(fontSize: 11.5, color: AppColors.saffron, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const Text('Popular Banks in Maharashtra:', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: banks
                .map((b) => ActionChip(
                      label: Text(b, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Redirecting to $b net banking gateway...')),
                        );
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => setState(() => _selectedPaymentTab = 0),
            icon: const Icon(Icons.qr_code_2_rounded, size: 16, color: AppColors.emerald),
            label: const Text('Pay by UPI QR Instead (Instant)', style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              side: const BorderSide(color: AppColors.emerald),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // ── 2B. UNDER VERIFICATION CARD (DOUBLE-PAYMENT GUARD) ─────────────────────
  Widget _buildUnderVerificationCard(PaymentOrder order, bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.saffron.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.saffron.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.saffron.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.hourglass_top_rounded, color: AppColors.saffron, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            'Payment Verification Pending',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'We have received your payment claim and reference details.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              children: [
                _buildInfoRow('Order ID', order.orderId),
                _buildInfoRow('Submitted UTR', order.transactionId ?? 'N/A', isMonospace: true),
                _buildInfoRow('Amount', '₹${order.amount.toInt()}'),
                _buildInfoRow('Status', 'Under Verification', color: AppColors.saffron),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.saffron.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.saffron, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your booking will be confirmed automatically once verified by our team. If you have already paid, please do NOT pay again.',
                    style: TextStyle(fontSize: 11.5, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Check Status',
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  variant: ButtonVariant.outline,
                  onPressed: () {
                    ref.invalidate(paymentOrdersProvider);
                    ref.invalidate(userBookingsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Refreshed payment status.')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomButton(
                  text: 'My Bookings',
                  icon: const Icon(Icons.confirmation_number_outlined, size: 16),
                  variant: ButtonVariant.primary,
                  onPressed: () => context.go('/my-bookings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 2C. PAID SUCCESS CARD ──────────────────────────────────────────────────
  Widget _buildPaidSuccessCard(PaymentOrder order, bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            'Payment Verified & Confirmed!',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Booking Ref: ${order.orderId}',
            style: const TextStyle(color: AppColors.saffron, fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Amount Paid', '₹${order.amount.toInt()}'),
          _buildInfoRow('UTR Reference', order.transactionId ?? 'VERIFIED', isMonospace: true),
          _buildInfoRow('Verified At', order.verifiedAt != null ? DateFormat('dd MMM yyyy, hh:mm a').format(order.verifiedAt!) : 'Just now'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'View Receipt',
                  icon: const Icon(Icons.receipt_rounded, size: 16),
                  variant: ButtonVariant.outline,
                  onPressed: () => context.push('/payment/receipt/${order.orderId}'),
                ),
              ),
              const SizedBox(width: 10),
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
        ],
      ),
    );
  }

  // ── 2D. EXPIRED CARD ───────────────────────────────────────────────────────
  Widget _buildExpiredCard(PaymentOrder order, bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.timer_off_rounded, color: AppColors.error, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            'Payment Session Expired',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'For security reasons, UPI QR payment sessions expire after 10 minutes. Please generate a new QR code to proceed.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'Generate New QR Code',
            icon: const Icon(Icons.refresh_rounded, size: 16),
            variant: ButtonVariant.primary,
            isLoading: _isSubmitting,
            isFullWidth: true,
            height: 48,
            onPressed: () => _handleRegenerateQR(order),
          ),
        ],
      ),
    );
  }

  // ── 3. 4-STEP PAYMENT INSTRUCTIONS ─────────────────────────────────────────
  Widget _buildPaymentInstructionsCard(PaymentOrder order, bool isDark, ThemeData theme) {
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
          Text('After Payment', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          _buildInstructionStep(
            step: '1',
            title: 'Scan the QR code and authorize',
            desc: 'Use Google Pay, PhonePe, Paytm, BHIM, or any UPI app to pay ₹${order.amount.toInt()}.',
          ),
          _buildInstructionStep(
            step: '2',
            title: 'Enter the 12-digit UTR / Transaction ID',
            desc: 'Find the transaction reference number from your UPI app receipt.',
          ),
          _buildInstructionStep(
            step: '3',
            title: 'Submit payment details for verification',
            desc: 'Tap Submit Payment Details below to register your payment claim.',
          ),
          _buildInstructionStep(
            step: '4',
            title: 'Get booking confirmation after verification',
            desc: 'Your digital ticket and invoice will be generated automatically.',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep({
    required String step,
    required String title,
    required String desc,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.emerald,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                step,
                style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: AppColors.emerald.withValues(alpha: 0.2),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isMonospace = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12.5, color: Colors.grey)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                fontFamily: isMonospace ? 'monospace' : null,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
