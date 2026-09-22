class AdminRefundRequest {
  final String id;
  final String bookingId;
  final String? orderId;
  final String customerName;
  final String customerEmail;
  final double originalAmount;
  final double cancellationFee;
  final double refundAmount;
  final String reason;
  final String date;
  final String status; // 'requested', 'review', 'approved', 'rejected', 'processing', 'completed'
  final String? adminNotes;
  final String? processedBy;
  final String? processedAt;

  const AdminRefundRequest({
    required this.id,
    required this.bookingId,
    this.orderId,
    required this.customerName,
    required this.customerEmail,
    required this.originalAmount,
    this.cancellationFee = 0.0,
    required this.refundAmount,
    required this.reason,
    required this.date,
    this.status = 'requested',
    this.adminNotes,
    this.processedBy,
    this.processedAt,
  });

  String get userEmail => customerEmail;
  String get requestedAt => date;

  AdminRefundRequest copyWith({
    String? id,
    String? bookingId,
    String? orderId,
    String? customerName,
    String? customerEmail,
    double? originalAmount,
    double? cancellationFee,
    double? refundAmount,
    String? reason,
    String? date,
    String? status,
    String? adminNotes,
    String? processedBy,
    String? processedAt,
  }) {
    return AdminRefundRequest(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      orderId: orderId ?? this.orderId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      originalAmount: originalAmount ?? this.originalAmount,
      cancellationFee: cancellationFee ?? this.cancellationFee,
      refundAmount: refundAmount ?? this.refundAmount,
      reason: reason ?? this.reason,
      date: date ?? this.date,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      processedBy: processedBy ?? this.processedBy,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookingId': bookingId,
        'orderId': orderId,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'originalAmount': originalAmount,
        'cancellationFee': cancellationFee,
        'refundAmount': refundAmount,
        'reason': reason,
        'date': date,
        'status': status,
        'adminNotes': adminNotes,
        'processedBy': processedBy,
        'processedAt': processedAt,
      };

  factory AdminRefundRequest.fromJson(Map<String, dynamic> json) => AdminRefundRequest(
        id: json['id'] as String? ?? 'REF-01',
        bookingId: json['bookingId'] as String? ?? '',
        orderId: json['orderId'] as String?,
        customerName: json['customerName'] as String? ?? 'Customer',
        customerEmail: json['customerEmail'] as String? ?? '',
        originalAmount: (json['originalAmount'] as num?)?.toDouble() ?? 0.0,
        cancellationFee: (json['cancellationFee'] as num?)?.toDouble() ?? 0.0,
        refundAmount: (json['refundAmount'] as num?)?.toDouble() ?? 0.0,
        reason: json['reason'] as String? ?? 'Trip cancelled by traveler',
        date: json['date'] as String? ?? DateTime.now().toIso8601String(),
        status: json['status'] as String? ?? 'requested',
        adminNotes: json['adminNotes'] as String?,
        processedBy: json['processedBy'] as String?,
        processedAt: json['processedAt'] as String?,
      );
}
