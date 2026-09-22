import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coupon.dart';

abstract class CouponRepository {
  Future<List<Coupon>> getCoupons();
  Future<void> addCoupon(Coupon coupon);
  Future<void> updateCoupon(Coupon coupon);
  Future<void> deleteCoupon(String code);
  Future<void> toggleCouponStatus(String code);
}

class LocalCouponRepository implements CouponRepository {
  static const String keyCoupons = 'pune_explorer_coupons';
  List<Coupon>? _inMemoryCache;

  Future<void> _initFromStorage() async {
    if (_inMemoryCache != null) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(keyCoupons);
    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(raw);
        _inMemoryCache = list.map((e) => Coupon.fromJson(e as Map<String, dynamic>)).toList();
        return;
      } catch (_) {
        // Fallback to seeds
      }
    }

    // Default seeds
    _inMemoryCache = [
      const Coupon(
        code: 'DARSHAN50',
        title: 'Pune Darshan 50% Off',
        description: 'Enjoy 50% off on all guided Pune Darshan AC bus bookings.',
        type: 'percent',
        discountValue: 50,
        maxDiscount: 500,
        minBookingAmount: 800,
        minTravelers: 1,
        expiry: '31 Dec 2026',
        badge: 'Popular',
      ),
      const Coupon(
        code: 'TREK15',
        title: 'Sahyadri Fort Treks 15%',
        description: 'Flat 15% discount for Sinhagad, Rajgad, and Torna weekend group treks.',
        type: 'percent',
        discountValue: 15,
        maxDiscount: 350,
        minBookingAmount: 500,
        minTravelers: 2,
        expiry: '15 Nov 2026',
        badge: 'Trekker VIP',
      ),
      const Coupon(
        code: 'PUNE2026',
        title: 'Pune Heritage Pass ₹100',
        description: 'Flat ₹100 off on all heritage walks and museum passes.',
        type: 'fixed',
        discountValue: 100,
        maxDiscount: 100,
        minBookingAmount: 300,
        minTravelers: 1,
        expiry: '31 Dec 2026',
        badge: 'Official',
      ),
      const Coupon(
        code: 'PUNERI99',
        title: 'First Trip Bonus ₹99',
        description: 'Welcome credit for new explorers registering on PuneExplorer.',
        type: 'fixed',
        discountValue: 99,
        maxDiscount: 99,
        minBookingAmount: 250,
        minTravelers: 1,
        expiry: '31 Dec 2026',
        badge: 'New User',
      ),
    ];
    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (_inMemoryCache != null) {
      final raw = jsonEncode(_inMemoryCache!.map((c) => c.toJson()).toList());
      await prefs.setString(keyCoupons, raw);
    }
  }

  @override
  Future<List<Coupon>> getCoupons() async {
    await _initFromStorage();
    return List.unmodifiable(_inMemoryCache!);
  }

  @override
  Future<void> addCoupon(Coupon coupon) async {
    await _initFromStorage();
    final exists = _inMemoryCache!.any((c) => c.code.toUpperCase() == coupon.code.toUpperCase());
    if (exists) {
      throw Exception('A coupon with code "${coupon.code}" already exists.');
    }
    _inMemoryCache!.insert(0, coupon);
    await _saveToStorage();
  }

  @override
  Future<void> updateCoupon(Coupon coupon) async {
    await _initFromStorage();
    final idx = _inMemoryCache!.indexWhere((c) => c.code.toUpperCase() == coupon.code.toUpperCase());
    if (idx >= 0) {
      _inMemoryCache![idx] = coupon;
      await _saveToStorage();
    }
  }

  @override
  Future<void> deleteCoupon(String code) async {
    await _initFromStorage();
    _inMemoryCache!.removeWhere((c) => c.code.toUpperCase() == code.toUpperCase());
    await _saveToStorage();
  }

  @override
  Future<void> toggleCouponStatus(String code) async {
    await _initFromStorage();
    final idx = _inMemoryCache!.indexWhere((c) => c.code.toUpperCase() == code.toUpperCase());
    if (idx >= 0) {
      final old = _inMemoryCache![idx];
      // Toggle expiry string or badge
      final isCurrentlyActive = !old.badge.toLowerCase().contains('inactive');
      final updated = Coupon(
        code: old.code,
        title: old.title,
        description: old.description,
        type: old.type,
        discountValue: old.discountValue,
        maxDiscount: old.maxDiscount,
        minBookingAmount: old.minBookingAmount,
        minTravelers: old.minTravelers,
        expiry: old.expiry,
        badge: isCurrentlyActive ? 'Inactive' : 'Active',
      );
      _inMemoryCache![idx] = updated;
      await _saveToStorage();
    }
  }
}
