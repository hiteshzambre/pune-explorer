import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../data/models/booking.dart';
import '../data/models/coupon.dart';
import '../data/models/tour_customization.dart';
import '../../core/constants/app_constants.dart';
import '../../core/enums/app_enums.dart';

class PricingBreakdown {
  final double basePrice;
  final double customizationCost;
  final double seatExtraPrice;
  final double subtotal;
  final double discountAmount;
  final double netAmount;
  final double gstAmount;
  final double platformFee;
  final double totalAmount;

  const PricingBreakdown({
    required this.basePrice,
    this.customizationCost = 0.0,
    required this.seatExtraPrice,
    required this.subtotal,
    required this.discountAmount,
    required this.netAmount,
    required this.gstAmount,
    required this.platformFee,
    required this.totalAmount,
  });
}

class SeatLockInfo {
  final String seatNumber;
  final String userId;
  final DateTime lockedAt;
  final Duration expiryDuration;

  SeatLockInfo({
    required this.seatNumber,
    required this.userId,
    required this.lockedAt,
    this.expiryDuration = const Duration(minutes: 10),
  });

  bool get isExpired => DateTime.now().difference(lockedAt) > expiryDuration;
  Duration get remainingTime {
    final diff = expiryDuration - DateTime.now().difference(lockedAt);
    return diff.isNegative ? Duration.zero : diff;
  }
}

class CancellationRefundQuote {
  final double originalTotal;
  final double refundPercentage;
  final double refundAmount;
  final double cancellationFee;
  final String tierDescription;

  const CancellationRefundQuote({
    required this.originalTotal,
    required this.refundPercentage,
    required this.refundAmount,
    required this.cancellationFee,
    required this.tierDescription,
  });
}

class BookingService {
  static const _uuid = Uuid();
  static final Map<String, SeatLockInfo> _activeSeatLocks = {};

  // ── 1. Pricing Engine ───────────────────────────────────────────────────────
  static PricingBreakdown calculatePricing({
    required double tourPrice,
    required int travelers,
    required double seatExtraPrice,
    TourCustomization? customization,
    Coupon? coupon,
  }) {
    final basePrice = tourPrice * travelers;
    final customizationCost = customization?.totalCustomizationCost ?? 0.0;
    final subtotal = basePrice + customizationCost + seatExtraPrice;
    final discountAmount = coupon != null ? coupon.calculateDiscount(subtotal, travelers) : 0.0;
    final netAmount = (subtotal - discountAmount) > 0 ? (subtotal - discountAmount) : 0.0;
    final gstAmount = netAmount * AppConstants.gstRate;
    const platformFee = AppConstants.platformFee;
    final totalAmount = netAmount + gstAmount + platformFee;

    return PricingBreakdown(
      basePrice: basePrice,
      customizationCost: customizationCost,
      seatExtraPrice: seatExtraPrice,
      subtotal: subtotal,
      discountAmount: discountAmount,
      netAmount: netAmount,
      gstAmount: gstAmount,
      platformFee: platformFee,
      totalAmount: totalAmount,
    );
  }

  // ── 2. Seat Locking Simulation ──────────────────────────────────────────────
  static bool acquireSeatLock(String seatNumber, String userId) {
    _cleanExpiredLocks();
    final existing = _activeSeatLocks[seatNumber];
    if (existing != null && !existing.isExpired && existing.userId != userId) {
      return false; // Already locked by someone else
    }
    _activeSeatLocks[seatNumber] = SeatLockInfo(
      seatNumber: seatNumber,
      userId: userId,
      lockedAt: DateTime.now(),
    );
    return true;
  }

  static void releaseSeatLock(String seatNumber, String userId) {
    final existing = _activeSeatLocks[seatNumber];
    if (existing != null && existing.userId == userId) {
      _activeSeatLocks.remove(seatNumber);
    }
  }

  static void releaseAllUserLocks(String userId) {
    _activeSeatLocks.removeWhere((_, lock) => lock.userId == userId);
  }

  static bool isSeatLocked(String seatNumber, String currentUserId) {
    _cleanExpiredLocks();
    final existing = _activeSeatLocks[seatNumber];
    if (existing == null || existing.isExpired) return false;
    return existing.userId != currentUserId;
  }

  static void _cleanExpiredLocks() {
    _activeSeatLocks.removeWhere((_, lock) => lock.isExpired);
  }

  // ── 3. Razorpay Signature Verification ──────────────────────────────────────
  static String generateRazorpaySignature({
    required String orderId,
    required String paymentId,
    String secret = 'pune_live_secret_key_2026',
  }) {
    final payload = '$orderId|$paymentId';
    final key = utf8.encode(secret);
    final bytes = utf8.encode(payload);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyRazorpaySignature({
    required String orderId,
    required String paymentId,
    required String signature,
    String secret = 'pune_live_secret_key_2026',
  }) {
    final expected = generateRazorpaySignature(
      orderId: orderId,
      paymentId: paymentId,
      secret: secret,
    );
    return expected == signature;
  }

  // ── 4. Cancellation & Refund Rules Engine ───────────────────────────────────
  static CancellationRefundQuote calculateRefundQuote(Booking booking, {DateTime? simulatedDeparture}) {
    final now = DateTime.now();
    // Default departure estimate (e.g. 24h from created or travelDate)
    final departure = simulatedDeparture ?? now.add(const Duration(hours: 36));
    final hoursRemaining = departure.difference(now).inHours;

    double refundPct;
    String tier;

    if (hoursRemaining >= 24) {
      refundPct = 0.90; // 90% refund (10% cancellation fee)
      tier = 'Standard Tier (Canceled > 24 hours before departure - 90% Refund)';
    } else if (hoursRemaining >= 12) {
      refundPct = 0.50; // 50% refund
      tier = 'Late Cancellation Tier (12-24 hours before departure - 50% Refund)';
    } else {
      refundPct = 0.0; // Non-refundable
      tier = 'Last-Minute Cancellation (< 12 hours before departure - Non-refundable)';
    }

    final refundAmount = booking.totalAmount * refundPct;
    final cancellationFee = booking.totalAmount - refundAmount;

    return CancellationRefundQuote(
      originalTotal: booking.totalAmount,
      refundPercentage: refundPct * 100,
      refundAmount: refundAmount,
      cancellationFee: cancellationFee,
      tierDescription: tier,
    );
  }

  // ── 5. Booking Generator ────────────────────────────────────────────────────
  static Booking createBooking({
    required String tourId,
    required String tourTitle,
    required String travelDate,
    required String pickupPoint,
    required List<Passenger> passengers,
    required List<String> selectedSeats,
    required PricingBreakdown pricing,
    TourCustomization? customization,
    String? appliedCoupon,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    String? paymentId,
    BookingStatus status = BookingStatus.confirmed,
  }) {
    final bookingId = _uuid.v4().substring(0, 8).toUpperCase();
    final hash = Booking.generatePassHash(bookingId, customerPhone);

    return Booking(
      id: bookingId,
      tourId: tourId,
      tourTitle: tourTitle,
      travelDate: travelDate,
      pickupPoint: pickupPoint,
      passengers: passengers,
      selectedSeats: selectedSeats,
      basePrice: pricing.basePrice,
      seatExtraPrice: pricing.seatExtraPrice,
      discountAmount: pricing.discountAmount,
      appliedCoupon: appliedCoupon,
      gstAmount: pricing.gstAmount,
      platformFee: pricing.platformFee,
      totalAmount: pricing.totalAmount,
      status: status,
      createdAt: DateTime.now().toIso8601String(),
      paymentId: paymentId,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      verificationHash: hash,
      customization: customization,
    );
  }
}
