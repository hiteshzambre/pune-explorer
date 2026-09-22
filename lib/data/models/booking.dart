import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../core/enums/app_enums.dart';
import 'tour_customization.dart';

class Passenger {
  final String fullName;
  final int age;
  final String gender;
  final String? seatNumber;

  const Passenger({
    required this.fullName,
    required this.age,
    required this.gender,
    this.seatNumber,
  });

  factory Passenger.fromJson(Map<String, dynamic> json) => Passenger(
        fullName: json['fullName'] as String? ?? json['name'] as String? ?? 'Traveler',
        age: (json['age'] as num?)?.toInt() ?? 25,
        gender: json['gender'] as String? ?? 'Not Specified',
        seatNumber: json['seatNumber'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'age': age,
        'gender': gender,
        'seatNumber': seatNumber,
      };
}

class Booking {
  final String id;
  final String tourId;
  final String tourTitle;
  final String travelDate;
  final String pickupPoint;
  final List<Passenger> passengers;
  final List<String> selectedSeats;
  final double basePrice;
  final double seatExtraPrice;
  final double discountAmount;
  final String? appliedCoupon;
  final double gstAmount;
  final double platformFee;
  final double totalAmount;
  final BookingStatus status;
  final String createdAt;
  final String? paymentId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String verificationHash;
  final TourCustomization? customization;
  final double refundAmount;
  final String? cancellationReason;
  final String? cancellationDate;
  final String? orderId;
  final String? transactionId;
  final PaymentStatus? paymentStatus;
  final String? paymentMethod;
  final String? verifiedAt;
  final String? verifiedBy;

  const Booking({
    required this.id,
    required this.tourId,
    required this.tourTitle,
    required this.travelDate,
    required this.pickupPoint,
    required this.passengers,
    required this.selectedSeats,
    required this.basePrice,
    required this.seatExtraPrice,
    required this.discountAmount,
    this.appliedCoupon,
    required this.gstAmount,
    required this.platformFee,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.paymentId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.verificationHash,
    this.customization,
    this.refundAmount = 0.0,
    this.cancellationReason,
    this.cancellationDate,
    this.orderId,
    this.transactionId,
    this.paymentStatus,
    this.paymentMethod,
    this.verifiedAt,
    this.verifiedBy,
  });

  Booking copyWith({
    String? id,
    String? tourId,
    String? tourTitle,
    String? travelDate,
    String? pickupPoint,
    List<Passenger>? passengers,
    List<String>? selectedSeats,
    double? basePrice,
    double? seatExtraPrice,
    double? discountAmount,
    String? appliedCoupon,
    double? gstAmount,
    double? platformFee,
    double? totalAmount,
    BookingStatus? status,
    String? createdAt,
    String? paymentId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? verificationHash,
    TourCustomization? customization,
    double? refundAmount,
    String? cancellationReason,
    String? cancellationDate,
    String? orderId,
    String? transactionId,
    PaymentStatus? paymentStatus,
    String? paymentMethod,
    String? verifiedAt,
    String? verifiedBy,
  }) {
    return Booking(
      id: id ?? this.id,
      tourId: tourId ?? this.tourId,
      tourTitle: tourTitle ?? this.tourTitle,
      travelDate: travelDate ?? this.travelDate,
      pickupPoint: pickupPoint ?? this.pickupPoint,
      passengers: passengers ?? this.passengers,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      basePrice: basePrice ?? this.basePrice,
      seatExtraPrice: seatExtraPrice ?? this.seatExtraPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      gstAmount: gstAmount ?? this.gstAmount,
      platformFee: platformFee ?? this.platformFee,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      paymentId: paymentId ?? this.paymentId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      verificationHash: verificationHash ?? this.verificationHash,
      customization: customization ?? this.customization,
      refundAmount: refundAmount ?? this.refundAmount,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancellationDate: cancellationDate ?? this.cancellationDate,
      orderId: orderId ?? this.orderId,
      transactionId: transactionId ?? this.transactionId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
    );
  }

  /// Generate a unique verification code: PUNEPASS-{bookingId}-{hash}
  String get verificationPassCode => 'PUNEPASS-$id-$verificationHash';

  bool get isPaid =>
      paymentStatus == PaymentStatus.paid ||
      status == BookingStatus.confirmed ||
      status == BookingStatus.paid;

  bool get isUnderVerification =>
      paymentStatus == PaymentStatus.underVerification ||
      paymentStatus == PaymentStatus.paymentSubmitted ||
      status == BookingStatus.underVerification ||
      status == BookingStatus.paymentSubmitted;

  bool get isPaymentFailed =>
      paymentStatus == PaymentStatus.failed ||
      status == BookingStatus.paymentFailed;

  static String generatePassHash(String bookingId, String customerPhone) {
    final bytes = utf8.encode('$bookingId:$customerPhone:PUNE_SECRET_2026');
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 6).toUpperCase();
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      tourId: json['tourId'] as String? ?? '',
      tourTitle: json['tourTitle'] as String? ?? 'Pune Tour Experience',
      travelDate: json['travelDate'] as String? ?? '',
      pickupPoint: json['pickupPoint'] as String? ?? 'Pune Station',
      passengers: (json['passengers'] as List<dynamic>?)
              ?.map((e) => Passenger.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      selectedSeats: (json['selectedSeats'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      seatExtraPrice: (json['seatExtraPrice'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      appliedCoupon: json['appliedCoupon'] as String?,
      gstAmount: (json['gstAmount'] as num?)?.toDouble() ?? 0.0,
      platformFee: (json['platformFee'] as num?)?.toDouble() ?? 99.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: BookingStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => BookingStatus.confirmed,
      ),
      createdAt: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      paymentId: json['paymentId'] as String?,
      customerName: json['customerName'] as String? ?? 'Traveler',
      customerEmail: json['customerEmail'] as String? ?? '',
      customerPhone: json['customerPhone'] as String? ?? '',
      verificationHash: json['verificationHash'] as String? ?? 'PASS26',
      customization: json['customization'] != null
          ? TourCustomization.fromJson(json['customization'] as Map<String, dynamic>)
          : null,
      refundAmount: (json['refundAmount'] as num?)?.toDouble() ?? 0.0,
      cancellationReason: json['cancellationReason'] as String?,
      cancellationDate: json['cancellationDate'] as String?,
      orderId: json['orderId'] as String?,
      transactionId: json['transactionId'] as String?,
      paymentStatus: json['paymentStatus'] != null
          ? PaymentStatus.values.firstWhere(
              (p) => p.name == json['paymentStatus'],
              orElse: () => PaymentStatus.pendingPayment,
            )
          : null,
      paymentMethod: json['paymentMethod'] as String?,
      verifiedAt: json['verifiedAt'] as String?,
      verifiedBy: json['verifiedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tourId': tourId,
        'tourTitle': tourTitle,
        'travelDate': travelDate,
        'pickupPoint': pickupPoint,
        'passengers': passengers.map((p) => p.toJson()).toList(),
        'selectedSeats': selectedSeats,
        'basePrice': basePrice,
        'seatExtraPrice': seatExtraPrice,
        'discountAmount': discountAmount,
        'appliedCoupon': appliedCoupon,
        'gstAmount': gstAmount,
        'platformFee': platformFee,
        'totalAmount': totalAmount,
        'status': status.name,
        'createdAt': createdAt,
        'paymentId': paymentId,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'customerPhone': customerPhone,
        'verificationHash': verificationHash,
        'customization': customization?.toJson(),
        'refundAmount': refundAmount,
        'cancellationReason': cancellationReason,
        'cancellationDate': cancellationDate,
        'orderId': orderId,
        'transactionId': transactionId,
        'paymentStatus': paymentStatus?.name,
        'paymentMethod': paymentMethod,
        'verifiedAt': verifiedAt,
        'verifiedBy': verifiedBy,
      };
}

