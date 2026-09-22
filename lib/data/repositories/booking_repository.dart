import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking.dart';
import '../../core/constants/app_constants.dart';
import '../../core/enums/app_enums.dart';

abstract class BookingRepository {
  Future<List<Booking>> getBookings();
  Future<Booking?> getBookingById(String id);
  Future<void> saveBooking(Booking booking);
  Future<void> updateBookingStatus(String bookingId, BookingStatus status);
}

class LocalBookingRepository implements BookingRepository {
  final List<Booking> _inMemoryBookings = [];
  bool _isLoaded = false;

  Future<void> _loadFromStorage() async {
    if (_isLoaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(AppConstants.keyBookings);
      if (raw != null) {
        final List<dynamic> list = jsonDecode(raw);
        _inMemoryBookings.clear();
        for (var item in list) {
          _inMemoryBookings.add(Booking.fromJson(item as Map<String, dynamic>));
        }
      } else {
        _inMemoryBookings.add(
          const Booking(
            id: 'PUNE-2026-8941',
            tourId: 'PNE-DAR-01',
            tourTitle: 'Classic Pune Darshan',
            travelDate: 'Tomorrow (08:00 AM)',
            pickupPoint: 'Swargate Bus Stand (08:20 AM)',
            passengers: [
              Passenger(fullName: 'Rahul Deshmukh', age: 28, gender: 'Male', seatNumber: '4A'),
              Passenger(fullName: 'Pooja Deshmukh', age: 26, gender: 'Female', seatNumber: '4B'),
            ],
            selectedSeats: ['4A', '4B'],
            basePrice: 998.0,
            seatExtraPrice: 100.0,
            discountAmount: 200.0,
            appliedCoupon: 'PUNEPASS20',
            gstAmount: 44.9,
            platformFee: 99.0,
            totalAmount: 1041.9,
            status: BookingStatus.confirmed,
            createdAt: '2026-08-28T09:30:00Z',
            paymentId: 'pay_UPI_PUNE_994182',
            customerName: 'Rahul Deshmukh',
            customerEmail: 'rahul.deshmukh@gmail.com',
            customerPhone: '+91 98220 12345',
            verificationHash: 'PUNEPASS',
          ),
        );
      }
    } catch (_) {}
    _isLoaded = true;
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _inMemoryBookings.map((b) => b.toJson()).toList();
      await prefs.setString(AppConstants.keyBookings, jsonEncode(data));
    } catch (_) {}
  }

  @override
  Future<List<Booking>> getBookings() async {
    await _loadFromStorage();
    return List.unmodifiable(_inMemoryBookings);
  }

  @override
  Future<Booking?> getBookingById(String id) async {
    await _loadFromStorage();
    try {
      return _inMemoryBookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveBooking(Booking booking) async {
    await _loadFromStorage();
    final existingIndex = _inMemoryBookings.indexWhere((b) => b.id == booking.id);
    if (existingIndex >= 0) {
      _inMemoryBookings[existingIndex] = booking;
    } else {
      _inMemoryBookings.insert(0, booking);
    }
    await _saveToStorage();
  }

  @override
  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    await _loadFromStorage();
    final index = _inMemoryBookings.indexWhere((b) => b.id == bookingId);
    if (index >= 0) {
      final old = _inMemoryBookings[index];
      _inMemoryBookings[index] = Booking(
        id: old.id,
        tourId: old.tourId,
        tourTitle: old.tourTitle,
        travelDate: old.travelDate,
        pickupPoint: old.pickupPoint,
        passengers: old.passengers,
        selectedSeats: old.selectedSeats,
        basePrice: old.basePrice,
        seatExtraPrice: old.seatExtraPrice,
        discountAmount: old.discountAmount,
        appliedCoupon: old.appliedCoupon,
        gstAmount: old.gstAmount,
        platformFee: old.platformFee,
        totalAmount: old.totalAmount,
        status: status,
        createdAt: old.createdAt,
        paymentId: old.paymentId,
        customerName: old.customerName,
        customerEmail: old.customerEmail,
        customerPhone: old.customerPhone,
        verificationHash: old.verificationHash,
      );
      await _saveToStorage();
    }
  }
}
