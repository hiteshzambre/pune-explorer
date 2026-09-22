import '../../core/enums/app_enums.dart';

class PaymentOrder {
  final String id;
  final String orderId; // e.g. PE-2026-000184
  final String bookingId;
  final String userId;
  final String packageId;
  final String packageName;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String merchantUpiId;
  final String merchantName;
  final String upiUri;
  final String? transactionId; // User-submitted UTR / reference number
  final PaymentStatus status;
  final String? verificationSource; // 'admin', 'sandbox', 'gateway_webhook'
  final DateTime? verifiedAt;
  final String? verifiedBy; // admin email or 'system'
  final String? failureReason;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime expiresAt;

  const PaymentOrder({
    required this.id,
    required this.orderId,
    required this.bookingId,
    required this.userId,
    required this.packageId,
    required this.packageName,
    required this.amount,
    this.currency = 'INR',
    this.paymentMethod = 'upi_qr',
    this.merchantUpiId = 'pay.puneexplorer@upi',
    this.merchantName = 'PuneExplorer Tours & Travels',
    required this.upiUri,
    this.transactionId,
    required this.status,
    this.verificationSource,
    this.verifiedAt,
    this.verifiedBy,
    this.failureReason,
    this.adminNotes,
    required this.createdAt,
    required this.updatedAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get remainingDuration {
    final diff = expiresAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  bool get isPaid => status == PaymentStatus.paid;

  bool get isUnderVerification =>
      status == PaymentStatus.underVerification ||
      status == PaymentStatus.paymentSubmitted;

  bool get canSubmitUtr =>
      (status == PaymentStatus.pendingPayment || status == PaymentStatus.failed) &&
      !isExpired;

  PaymentOrder copyWith({
    String? id,
    String? orderId,
    String? bookingId,
    String? userId,
    String? packageId,
    String? packageName,
    double? amount,
    String? currency,
    String? paymentMethod,
    String? merchantUpiId,
    String? merchantName,
    String? upiUri,
    String? transactionId,
    PaymentStatus? status,
    String? verificationSource,
    DateTime? verifiedAt,
    String? verifiedBy,
    String? failureReason,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
  }) {
    return PaymentOrder(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      packageId: packageId ?? this.packageId,
      packageName: packageName ?? this.packageName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      merchantUpiId: merchantUpiId ?? this.merchantUpiId,
      merchantName: merchantName ?? this.merchantName,
      upiUri: upiUri ?? this.upiUri,
      transactionId: transactionId ?? this.transactionId,
      status: status ?? this.status,
      verificationSource: verificationSource ?? this.verificationSource,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      failureReason: failureReason ?? this.failureReason,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'bookingId': bookingId,
        'userId': userId,
        'packageId': packageId,
        'packageName': packageName,
        'amount': amount,
        'currency': currency,
        'paymentMethod': paymentMethod,
        'merchantUpiId': merchantUpiId,
        'merchantName': merchantName,
        'upiUri': upiUri,
        'transactionId': transactionId,
        'status': status.name,
        'verificationSource': verificationSource,
        'verifiedAt': verifiedAt?.toIso8601String(),
        'verifiedBy': verifiedBy,
        'failureReason': failureReason,
        'adminNotes': adminNotes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      };

  factory PaymentOrder.fromJson(Map<String, dynamic> json) {
    return PaymentOrder(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      bookingId: json['bookingId'] as String,
      userId: json['userId'] as String? ?? 'guest_user',
      packageId: json['packageId'] as String? ?? '',
      packageName: json['packageName'] as String? ?? 'Pune Tour Package',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      paymentMethod: json['paymentMethod'] as String? ?? 'upi_qr',
      merchantUpiId: json['merchantUpiId'] as String? ?? 'pay.puneexplorer@upi',
      merchantName: json['merchantName'] as String? ?? 'PuneExplorer Tours & Travels',
      upiUri: json['upiUri'] as String? ?? '',
      transactionId: json['transactionId'] as String?,
      status: PaymentStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => PaymentStatus.pendingPayment,
      ),
      verificationSource: json['verificationSource'] as String?,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.tryParse(json['verifiedAt'] as String)
          : null,
      verifiedBy: json['verifiedBy'] as String?,
      failureReason: json['failureReason'] as String?,
      adminNotes: json['adminNotes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : DateTime.now().add(const Duration(minutes: 10)),
    );
  }
}
