import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/coupon.dart';
import '../coupon_repository.dart';
import '../../../core/supabase/supabase_config.dart';

class SupabaseCouponRepository implements CouponRepository {
  final SupabaseClient? _client;
  final LocalCouponRepository _fallback = LocalCouponRepository();

  SupabaseCouponRepository([SupabaseClient? client])
      : _client = client ?? SupabaseConfig.client;

  SupabaseClient get client {
    final c = _client ?? SupabaseConfig.client;
    if (c == null) throw StateError('Supabase is not initialized.');
    return c;
  }

  @override
  Future<List<Coupon>> getCoupons() async {
    try {
      final res = await client
          .from(SupabaseConfig.tableCoupons)
          .select()
          .order('created_at', ascending: false);

      final list = res as List<dynamic>;
      if (list.isEmpty) return await _fallback.getCoupons();

      return list.map((item) {
        final val = (item['discount_value'] as num?)?.toDouble() ?? 10.0;
        final type = item['discount_type'] as String? ?? 'percent';
        final maxD = (item['max_discount_amount'] as num?)?.toDouble() ?? 500.0;
        final minB = (item['min_booking_amount'] as num?)?.toDouble() ?? 0.0;
        final isActive = item['is_active'] as bool? ?? true;

        return Coupon(
          code: item['code'] as String,
          title: item['title'] as String,
          description: item['description'] as String? ?? '',
          type: type,
          discountValue: val,
          maxDiscount: maxD,
          minBookingAmount: minB,
          minTravelers: 1,
          expiry: item['valid_until']?.toString() ?? '31 Dec 2026',
          badge: isActive ? 'Active' : 'Inactive',
          validUntil: DateTime.tryParse(item['valid_until']?.toString() ?? ''),
          applicableCategory: item['applicable_category'] as String? ?? 'ALL',
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseCouponRepository] getCoupons error: $e');
      return await _fallback.getCoupons();
    }
  }

  @override
  Future<void> addCoupon(Coupon coupon) async {
    try {
      await client.from(SupabaseConfig.tableCoupons).insert({
        'id': 'coup_${coupon.code.toLowerCase()}',
        'code': coupon.code.toUpperCase(),
        'title': coupon.title,
        'description': coupon.description,
        'discount_type': coupon.type,
        'discount_value': coupon.discountValue,
        'min_booking_amount': coupon.minBookingAmount,
        'max_discount_amount': coupon.maxDiscount,
        'valid_from': DateTime.now().toIso8601String(),
        'valid_until': coupon.validUntil?.toIso8601String() ??
            DateTime.now().add(const Duration(days: 180)).toIso8601String(),
        'applicable_category': coupon.applicableCategory,
        'is_active': true,
      });
      await _fallback.addCoupon(coupon);
    } catch (e) {
      debugPrint('[SupabaseCouponRepository] addCoupon error: $e');
      await _fallback.addCoupon(coupon);
    }
  }

  @override
  Future<void> updateCoupon(Coupon coupon) async {
    try {
      await client.from(SupabaseConfig.tableCoupons).update({
        'title': coupon.title,
        'description': coupon.description,
        'discount_type': coupon.type,
        'discount_value': coupon.discountValue,
        'min_booking_amount': coupon.minBookingAmount,
        'max_discount_amount': coupon.maxDiscount,
      }).eq('code', coupon.code.toUpperCase());
      await _fallback.updateCoupon(coupon);
    } catch (e) {
      debugPrint('[SupabaseCouponRepository] updateCoupon error: $e');
      await _fallback.updateCoupon(coupon);
    }
  }

  @override
  Future<void> deleteCoupon(String code) async {
    try {
      await client.from(SupabaseConfig.tableCoupons).delete().eq('code', code.toUpperCase());
      await _fallback.deleteCoupon(code);
    } catch (e) {
      debugPrint('[SupabaseCouponRepository] deleteCoupon error: $e');
      await _fallback.deleteCoupon(code);
    }
  }

  @override
  Future<void> toggleCouponStatus(String code) async {
    try {
      final res = await client
          .from(SupabaseConfig.tableCoupons)
          .select('is_active')
          .eq('code', code.toUpperCase())
          .maybeSingle();

      if (res != null) {
        final current = res['is_active'] as bool? ?? true;
        await client
            .from(SupabaseConfig.tableCoupons)
            .update({'is_active': !current})
            .eq('code', code.toUpperCase());
      }
      await _fallback.toggleCouponStatus(code);
    } catch (e) {
      debugPrint('[SupabaseCouponRepository] toggleCouponStatus error: $e');
      await _fallback.toggleCouponStatus(code);
    }
  }
}
