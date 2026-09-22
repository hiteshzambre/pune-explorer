enum CouponDiscountType { percentage, flat }

class Coupon {
  final String code;
  final String title;
  final String description;
  final String type; // 'percent' or 'fixed'
  final double discountValue; // percentage (e.g. 20) or flat amount (e.g. 500)
  final double maxDiscount;
  final double minBookingAmount;
  final int minTravelers;
  final String expiry;
  final String badge;
  final bool isActive;
  final int usedCount;
  final int? usageLimit;
  final DateTime? validUntil;
  final String applicableCategory;

  const Coupon({
    required this.code,
    this.title = '',
    required this.description,
    this.type = 'percent',
    required this.discountValue,
    this.maxDiscount = 500,
    this.minBookingAmount = 0,
    this.minTravelers = 1,
    this.expiry = 'Valid till 31 Dec 2026',
    this.badge = 'Special Offer',
    this.isActive = true,
    this.usedCount = 0,
    this.usageLimit,
    this.validUntil,
    this.applicableCategory = 'ALL',
    String? id,
    CouponDiscountType? discountType,
    double? minOrderAmount,
  });

  String get id => code;
  double get minOrderAmount => minBookingAmount;
  CouponDiscountType get discountType =>
      (type == 'fixed' || type == 'flat') ? CouponDiscountType.flat : CouponDiscountType.percentage;

  Coupon copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    String? type,
    CouponDiscountType? discountType,
    double? discountValue,
    double? maxDiscount,
    double? minBookingAmount,
    double? minOrderAmount,
    int? minTravelers,
    String? expiry,
    DateTime? validUntil,
    String? badge,
    bool? isActive,
    int? usedCount,
    int? usageLimit,
    String? applicableCategory,
  }) {
    return Coupon(
      code: code ?? this.code,
      title: title ?? (this.title.isNotEmpty ? this.title : (code ?? this.code)),
      description: description ?? this.description,
      type: discountType != null
          ? (discountType == CouponDiscountType.flat ? 'fixed' : 'percent')
          : (type ?? this.type),
      discountValue: discountValue ?? this.discountValue,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      minBookingAmount: minOrderAmount ?? minBookingAmount ?? this.minBookingAmount,
      minTravelers: minTravelers ?? this.minTravelers,
      expiry: validUntil != null
          ? 'Valid till ${validUntil.day}/${validUntil.month}/${validUntil.year}'
          : (expiry ?? this.expiry),
      badge: badge ?? this.badge,
      isActive: isActive ?? this.isActive,
      usedCount: usedCount ?? this.usedCount,
      usageLimit: usageLimit ?? this.usageLimit,
      validUntil: validUntil ?? this.validUntil,
      applicableCategory: applicableCategory ?? this.applicableCategory,
    );
  }

  /// Calculate discount amount given base booking total and traveler count
  double calculateDiscount(double subtotal, int travelerCount) {
    if (subtotal < minBookingAmount) return 0.0;
    if (travelerCount < minTravelers) return 0.0;

    if (type == 'percent') {
      final calculated = (subtotal * (discountValue / 100));
      return calculated > maxDiscount ? maxDiscount : calculated;
    } else {
      return discountValue > subtotal ? subtotal : discountValue;
    }
  }

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
        code: json['code'] as String,
        title: json['title'] as String? ?? json['code'] as String,
        description: json['desc'] as String? ?? json['description'] as String? ?? '',
        type: json['type'] as String? ?? 'percent',
        discountValue: (json['discountPercent'] as num?)?.toDouble() ??
            (json['discountAmount'] as num?)?.toDouble() ??
            (json['discountValue'] as num?)?.toDouble() ??
            10.0,
        maxDiscount: (json['maxDiscount'] as num?)?.toDouble() ?? 500.0,
        minBookingAmount: (json['minBooking'] as num?)?.toDouble() ??
            (json['minBookingAmount'] as num?)?.toDouble() ??
            0.0,
        minTravelers: (json['minTravelers'] as num?)?.toInt() ?? 1,
        expiry: json['expiry'] as String? ?? 'Valid till 31 Dec 2026',
        badge: json['badge'] as String? ?? 'Special Offer',
        isActive: json['isActive'] as bool? ?? true,
        usedCount: (json['usedCount'] as num?)?.toInt() ?? 0,
        usageLimit: (json['usageLimit'] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'title': title,
        'description': description,
        'type': type,
        'discountValue': discountValue,
        'maxDiscount': maxDiscount,
        'minBookingAmount': minBookingAmount,
        'minTravelers': minTravelers,
        'expiry': expiry,
        'badge': badge,
        'isActive': isActive,
        'usedCount': usedCount,
        'usageLimit': usageLimit,
      };
}
