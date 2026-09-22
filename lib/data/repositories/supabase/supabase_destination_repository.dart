import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/destination.dart';
import '../../models/tour_package.dart';
import '../../models/route_model.dart';
import '../../models/heritage_walk.dart';
import '../../models/coupon.dart';
import '../../models/review.dart';
import '../destination_repository.dart';
import '../../../core/supabase/supabase_config.dart';

class SupabaseDestinationRepository implements DestinationRepository {
  final SupabaseClient? _client;
  final LocalDestinationRepository _fallback = LocalDestinationRepository();

  SupabaseDestinationRepository([SupabaseClient? client])
      : _client = client ?? SupabaseConfig.client;

  SupabaseClient get client {
    final c = _client ?? SupabaseConfig.client;
    if (c == null) {
      throw StateError('Supabase is not initialized.');
    }
    return c;
  }

  // ── Destinations ─────────────────────────────────────────────────────────────

  @override
  Future<List<Destination>> getDestinations() async {
    try {
      final res = await client
          .from(SupabaseConfig.tableDestinations)
          .select()
          .eq('is_active', true)
          .order('rating', ascending: false);

      final list = res as List<dynamic>;
      if (list.isEmpty) {
        return await _fallback.getDestinations();
      }

      return list.map((item) {
        final hero = item['hero_image'] as String? ?? '';
        return Destination.fromJson({
          'id': item['id'] ?? item['slug'],
          'name': item['name'],
          'city': 'Pune',
          'state': 'Maharashtra',
          'category': item['category_id'] ?? 'historical',
          'description': item['short_description'] ?? '',
          'longDescription': item['full_description'] ?? '',
          'images': hero.isNotEmpty ? [hero] : [],
          'rating': (item['rating'] as num?)?.toDouble() ?? 4.5,
          'reviewCount': (item['review_count'] as num?)?.toInt() ?? 100,
          'latitude': (item['latitude'] as num?)?.toDouble() ?? 18.5204,
          'longitude': (item['longitude'] as num?)?.toDouble() ?? 73.8567,
          'entryFeeIndian': (item['entry_fee'] as num?)?.toDouble() ?? 0.0,
          'bestTime': item['best_time_to_visit'] ?? 'October to March',
          'openingHours': item['timings'] ?? '9:00 AM - 6:00 PM',
          'recommendedDuration': item['ideal_duration'] ?? '2-3 hours',
          'trending': item['is_trending'] ?? false,
          'featured': item['is_featured'] ?? false,
        });
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseDestinationRepository] getDestinations error: $e. Using fallback.');
      return await _fallback.getDestinations();
    }
  }

  @override
  Future<Destination?> getDestinationById(String id) async {
    try {
      final res = await client
          .from(SupabaseConfig.tableDestinations)
          .select()
          .or('id.eq.$id,slug.eq.$id')
          .maybeSingle();

      if (res == null) {
        return await _fallback.getDestinationById(id);
      }

      final hero = res['hero_image'] as String? ?? '';
      return Destination.fromJson({
        'id': res['id'] ?? res['slug'],
        'name': res['name'],
        'city': 'Pune',
        'state': 'Maharashtra',
        'category': res['category_id'] ?? 'historical',
        'description': res['short_description'] ?? '',
        'longDescription': res['full_description'] ?? '',
        'images': hero.isNotEmpty ? [hero] : [],
        'rating': (res['rating'] as num?)?.toDouble() ?? 4.5,
        'reviewCount': (res['review_count'] as num?)?.toInt() ?? 100,
        'latitude': (res['latitude'] as num?)?.toDouble() ?? 18.5204,
        'longitude': (res['longitude'] as num?)?.toDouble() ?? 73.8567,
        'entryFeeIndian': (res['entry_fee'] as num?)?.toDouble() ?? 0.0,
        'bestTime': res['best_time_to_visit'] ?? 'October to March',
        'openingHours': res['timings'] ?? '9:00 AM - 6:00 PM',
        'recommendedDuration': res['ideal_duration'] ?? '2-3 hours',
        'trending': res['is_trending'] ?? false,
        'featured': res['is_featured'] ?? false,
      });
    } catch (e) {
      debugPrint('[SupabaseDestinationRepository] getDestinationById error: $e');
      return _fallback.getDestinationById(id);
    }
  }

  @override
  Future<void> addDestination(Destination destination) async {
    try {
      await client.from(SupabaseConfig.tableDestinations).insert({
        'id': destination.id,
        'slug': destination.id,
        'name': destination.name,
        'category_id': destination.category.name,
        'short_description': destination.description,
        'full_description': destination.longDescription,
        'hero_image': destination.images.isNotEmpty ? destination.images.first : '',
        'rating': destination.rating,
        'review_count': destination.reviewCount,
        'entry_fee': destination.entryFeeIndian,
        'best_time_to_visit': destination.bestTime,
        'timings': destination.openingHours,
        'ideal_duration': destination.recommendedDuration,
        'latitude': destination.latitude,
        'longitude': destination.longitude,
        'is_featured': destination.isFeatured,
        'is_trending': destination.isTrending,
        'is_active': true,
      });
    } catch (e) {
      throw Exception(SupabaseConfig.mapError(e));
    }
  }

  @override
  Future<void> updateDestination(Destination destination) async {
    try {
      await client.from(SupabaseConfig.tableDestinations).update({
        'name': destination.name,
        'category_id': destination.category.name,
        'short_description': destination.description,
        'full_description': destination.longDescription,
        'hero_image': destination.images.isNotEmpty ? destination.images.first : '',
        'rating': destination.rating,
        'review_count': destination.reviewCount,
        'entry_fee': destination.entryFeeIndian,
        'best_time_to_visit': destination.bestTime,
        'timings': destination.openingHours,
        'ideal_duration': destination.recommendedDuration,
        'latitude': destination.latitude,
        'longitude': destination.longitude,
        'is_featured': destination.isFeatured,
        'is_trending': destination.isTrending,
      }).eq('id', destination.id);
    } catch (e) {
      throw Exception(SupabaseConfig.mapError(e));
    }
  }

  @override
  Future<void> deleteDestination(String id) async {
    try {
      await client.from(SupabaseConfig.tableDestinations).delete().eq('id', id);
    } catch (e) {
      throw Exception(SupabaseConfig.mapError(e));
    }
  }

  // ── Tour Packages ────────────────────────────────────────────────────────────

  @override
  Future<List<TourPackage>> getTourPackages() async => _fallback.getTourPackages();

  @override
  Future<TourPackage?> getTourPackageById(String id) async => _fallback.getTourPackageById(id);

  @override
  Future<void> addTourPackage(TourPackage package) async => _fallback.addTourPackage(package);

  @override
  Future<void> updateTourPackage(TourPackage package) async => _fallback.updateTourPackage(package);

  @override
  Future<void> deleteTourPackage(String id) async => _fallback.deleteTourPackage(id);

  // ── Routes & Circuits ────────────────────────────────────────────────────────

  @override
  Future<List<RouteCircuit>> getRoutes() async => _fallback.getRoutes();

  @override
  Future<RouteCircuit?> getRouteById(String id) async => _fallback.getRouteById(id);

  @override
  Future<void> addRoute(RouteCircuit route) async => _fallback.addRoute(route);

  @override
  Future<void> updateRoute(RouteCircuit route) async => _fallback.updateRoute(route);

  @override
  Future<void> reorderRouteStops(String routeId, List<RouteWaypoint> waypoints) async =>
      _fallback.reorderRouteStops(routeId, waypoints);

  @override
  Future<void> deleteRoute(String id) async => _fallback.deleteRoute(id);

  // ── Heritage Walks ───────────────────────────────────────────────────────────

  @override
  Future<List<HeritageWalk>> getHeritageWalks() async => _fallback.getHeritageWalks();

  @override
  Future<HeritageWalk?> getHeritageWalkById(String id) async => _fallback.getHeritageWalkById(id);

  @override
  Future<void> addHeritageWalk(HeritageWalk walk) async => _fallback.addHeritageWalk(walk);

  @override
  Future<void> updateHeritageWalk(HeritageWalk walk) async => _fallback.updateHeritageWalk(walk);

  @override
  Future<void> deleteHeritageWalk(String id) async => _fallback.deleteHeritageWalk(id);

  // ── Coupons ──────────────────────────────────────────────────────────────────

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
        return Coupon(
          code: item['code'] as String,
          title: item['title'] as String? ?? '',
          description: item['description'] as String? ?? '',
          discountValue: (item['discount_value'] as num?)?.toDouble() ?? 10.0,
          minBookingAmount: (item['min_booking_amount'] as num?)?.toDouble() ?? 0.0,
          validUntil: DateTime.tryParse(item['valid_until']?.toString() ?? '') ??
              DateTime.now().add(const Duration(days: 90)),
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseDestinationRepository] getCoupons error: $e');
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
        'is_active': true,
      });
    } catch (e) {
      throw Exception(SupabaseConfig.mapError(e));
    }
  }

  @override
  Future<void> deleteCoupon(String code) async {
    try {
      await client.from(SupabaseConfig.tableCoupons).delete().eq('code', code.toUpperCase());
    } catch (e) {
      throw Exception(SupabaseConfig.mapError(e));
    }
  }

  // ── Reviews ──────────────────────────────────────────────────────────────────

  @override
  Future<List<Review>> getReviews(String destinationId) async {
    try {
      final res = await client
          .from(SupabaseConfig.tableReviews)
          .select()
          .eq('destination_id', destinationId)
          .eq('status', 'approved')
          .order('created_at', ascending: false);

      final list = res as List<dynamic>;
      if (list.isEmpty) return await _fallback.getReviews(destinationId);

      return list.map((item) {
        return Review(
          id: item['id'] as String,
          destinationId: item['destination_id'] as String? ?? destinationId,
          authorName: item['author_name'] as String? ?? 'Explorer',
          authorAvatar: '',
          rating: (item['rating'] as num?)?.toDouble() ?? 5.0,
          date: item['created_at']?.toString() ?? 'Today',
          comment: item['comment'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseDestinationRepository] getReviews error: $e');
      return await _fallback.getReviews(destinationId);
    }
  }

  @override
  Future<List<Review>> getAllReviews() async {
    try {
      final res = await client
          .from(SupabaseConfig.tableReviews)
          .select()
          .order('created_at', ascending: false);

      final list = res as List<dynamic>;
      if (list.isEmpty) return await _fallback.getAllReviews();

      return list.map((item) {
        return Review(
          id: item['id'] as String,
          destinationId: item['destination_id'] as String? ?? '',
          authorName: item['author_name'] as String? ?? 'Explorer',
          authorAvatar: '',
          rating: (item['rating'] as num?)?.toDouble() ?? 5.0,
          date: item['created_at']?.toString() ?? 'Today',
          comment: item['comment'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseDestinationRepository] getAllReviews error: $e');
      return await _fallback.getAllReviews();
    }
  }

  @override
  Future<void> addReview(Review review) async {
    try {
      await client.from(SupabaseConfig.tableReviews).insert({
        'id': review.id,
        'destination_id': review.destinationId,
        'user_id': client.auth.currentUser?.id,
        'author_name': review.authorName,
        'rating': review.rating,
        'comment': review.comment,
        'status': 'approved',
      });
    } catch (e) {
      throw Exception(SupabaseConfig.mapError(e));
    }
  }

  @override
  Future<void> updateReview(Review review) async {
    try {
      await client.from(SupabaseConfig.tableReviews).update({
        'rating': review.rating,
        'comment': review.comment,
      }).eq('id', review.id);
    } catch (e) {
      throw Exception(SupabaseConfig.mapError(e));
    }
  }

  @override
  Future<void> deleteReview(String id) async {
    try {
      await client.from(SupabaseConfig.tableReviews).delete().eq('id', id);
    } catch (e) {
      throw Exception(SupabaseConfig.mapError(e));
    }
  }

  @override
  void resetToSeed() {
    _fallback.resetToSeed();
  }
}
