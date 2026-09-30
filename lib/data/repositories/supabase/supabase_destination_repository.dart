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
import '../../../core/enums/app_enums.dart';

class SupabaseDestinationRepository implements DestinationRepository {
  final SupabaseClient? _client;
  final LocalDestinationRepository _fallback;

  SupabaseDestinationRepository([SupabaseClient? client, LocalDestinationRepository? fallback])
      : _client = client ?? SupabaseConfig.client,
        _fallback = fallback ?? LocalDestinationRepository();

  SupabaseClient get client {
    final c = _client ?? SupabaseConfig.client;
    if (c == null) {
      throw StateError('Supabase is not initialized.');
    }
    return c;
  }

  static String _mapCategoryToDb(DestinationCategory cat) {
    switch (cat) {
      case DestinationCategory.forts:
        return 'historical';
      case DestinationCategory.spiritual:
        return 'religious';
      case DestinationCategory.lakesNature:
      case DestinationCategory.hillStation:
      case DestinationCategory.adventure:
      case DestinationCategory.weekendGetaway:
        return 'nature';
      case DestinationCategory.city:
        return 'historical';
      default:
        return 'historical';
    }
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
      // When database has 0 records, return empty list. Never resurrect hardcoded seed items!
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
          'reviewCount': (item['review_count'] as num?)?.toInt() ?? 0,
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
      debugPrint('[SupabaseDestinationRepository] getDestinations error: $e. Returning local cache.');
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
        // Destination does not exist or was deleted from Supabase. Never resurrect!
        return null;
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
        'reviewCount': (res['review_count'] as num?)?.toInt() ?? 0,
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
      return null;
    }
  }

  @override
  Future<void> addDestination(Destination destination) async {
    // 1. Sync to local fallback storage first so it is immediately available
    await _fallback.addDestination(destination);

    // 2. Persist to Supabase
    try {
      final dbCategory = _mapCategoryToDb(destination.category);
      await client.from(SupabaseConfig.tableDestinations).upsert({
        'id': destination.id,
        'slug': destination.id,
        'name': destination.name,
        'category_id': dbCategory,
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
      debugPrint('[SupabaseDestinationRepository] addDestination Supabase error: $e');
      throw Exception(SupabaseConfig.mapError(e));
    }
  }

  @override
  Future<void> updateDestination(Destination destination) async {
    // 1. Sync to local fallback storage
    await _fallback.updateDestination(destination);

    // 2. Persist to Supabase
    try {
      final dbCategory = _mapCategoryToDb(destination.category);
      await client.from(SupabaseConfig.tableDestinations).upsert({
        'id': destination.id,
        'slug': destination.id,
        'name': destination.name,
        'category_id': dbCategory,
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
      debugPrint('[SupabaseDestinationRepository] updateDestination Supabase error: $e');
      throw Exception(SupabaseConfig.mapError(e));
    }
  }

  @override
  Future<void> deleteDestination(String id) async {
    // 1. Delete from Supabase first
    try {
      await client.from(SupabaseConfig.tableDestinations).delete().eq('id', id);
    } catch (e) {
      debugPrint('[SupabaseDestinationRepository] deleteDestination Supabase error: $e');
      throw Exception(SupabaseConfig.mapError(e));
    }

    // 2. Also purge from local cache
    await _fallback.deleteDestination(id);
  }

  // ── Tour Packages ────────────────────────────────────────────────────────────

  @override
  Future<List<TourPackage>> getTourPackages() async {
    try {
      final res = await client
          .from(SupabaseConfig.tableTours)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);
      final list = res as List<dynamic>;
      if (list.isEmpty) return await _fallback.getTourPackages();

      return list.map((item) {
        final hero = item['hero_image'] as String? ?? '';
        final inclusionsRaw = item['inclusions'];
        final exclusionsRaw = item['exclusions'];
        return TourPackage(
          id: item['id'] as String,
          title: item['title'] as String? ?? '',
          subtitle: item['subtitle'] as String? ?? '',
          destinationId: 'dest_pune_all',
          destinationName: 'Pune City',
          duration: item['duration_hours'] != null ? '${item['duration_hours']} Hours' : 'Full Day',
          price: (item['discounted_price'] as num?)?.toDouble() ?? (item['price_per_person'] as num?)?.toDouble() ?? 499.0,
          originalPrice: (item['price_per_person'] as num?)?.toDouble() ?? 799.0,
          rating: (item['rating'] as num?)?.toDouble() ?? 4.9,
          reviewCount: (item['review_count'] as num?)?.toInt() ?? 100,
          badge: item['difficulty'] as String? ?? 'POPULAR',
          category: item['tour_type'] as String? ?? 'Sightseeing',
          images: hero.isNotEmpty ? [hero] : const ['https://images.unsplash.com/photo-1544735716-392fe2489ffa?q=80&w=1200'],
          inclusions: (inclusionsRaw is List) ? inclusionsRaw.map((e) => e.toString()).toList() : const ['AC Coach', 'Certified Guide'],
          exclusions: (exclusionsRaw is List) ? exclusionsRaw.map((e) => e.toString()).toList() : const ['Personal Expenses'],
          highlights: const ['Iconic Landmarks', 'Comfortable AC Travel'],
          itinerary: const [],
          pickupPoints: const ['Swargate', 'Pune Station', 'Shivajinagar'],
          hasAccommodation: false,
          accommodationDiscount: 0,
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseDestinationRepository] getTourPackages error: $e');
      return await _fallback.getTourPackages();
    }
  }

  @override
  Future<TourPackage?> getTourPackageById(String id) async {
    final list = await getTourPackages();
    return list.where((p) => p.id == id).firstOrNull ?? await _fallback.getTourPackageById(id);
  }

  @override
  Future<void> addTourPackage(TourPackage package) async {
    await _fallback.addTourPackage(package);
    try {
      await client.from(SupabaseConfig.tableTours).upsert({
        'id': package.id,
        'title': package.title,
        'subtitle': package.subtitle,
        'tour_type': package.category,
        'duration_days': 1,
        'duration_hours': 8,
        'price_per_person': package.originalPrice,
        'discounted_price': package.price,
        'hero_image': package.images.isNotEmpty ? package.images.first : '',
        'overview': package.subtitle,
        'difficulty': package.badge,
        'rating': package.rating,
        'review_count': package.reviewCount,
        'inclusions': package.inclusions,
        'exclusions': package.exclusions,
        'is_active': true,
        'is_featured': true,
      });
    } catch (e) {
      debugPrint('[SupabaseDestinationRepository] addTourPackage error: $e');
    }
  }

  @override
  Future<void> updateTourPackage(TourPackage package) async {
    await _fallback.updateTourPackage(package);
    try {
      await client.from(SupabaseConfig.tableTours).upsert({
        'id': package.id,
        'title': package.title,
        'subtitle': package.subtitle,
        'tour_type': package.category,
        'price_per_person': package.originalPrice,
        'discounted_price': package.price,
        'hero_image': package.images.isNotEmpty ? package.images.first : '',
        'difficulty': package.badge,
        'inclusions': package.inclusions,
        'exclusions': package.exclusions,
        'is_active': true,
      });
    } catch (e) {
      debugPrint('[SupabaseDestinationRepository] updateTourPackage error: $e');
    }
  }

  @override
  Future<void> deleteTourPackage(String id) async {
    await _fallback.deleteTourPackage(id);
    try {
      await client.from(SupabaseConfig.tableTours).delete().eq('id', id);
    } catch (e) {
      debugPrint('[SupabaseDestinationRepository] deleteTourPackage error: $e');
    }
  }

  // ── Routes & Circuits ────────────────────────────────────────────────────────

  @override
  Future<List<RouteCircuit>> getRoutes() async {
    try {
      final res = await client
          .from(SupabaseConfig.tableDarshanCircuits)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: true);
      final list = res as List<dynamic>;
      if (list.isEmpty) return await _fallback.getRoutes();

      final fallbackRoutes = await _fallback.getRoutes();
      final defaultWaypoints = fallbackRoutes.isNotEmpty ? fallbackRoutes.first.waypoints : <RouteWaypoint>[];

      return list.map((item) {
        return RouteCircuit(
          id: item['id'] as String,
          title: item['title'] as String? ?? 'Pune Darshan Circuit',
          subtitle: item['description'] as String? ?? 'Pune Darshan City Tour',
          badge: 'Scenic Trail',
          icon: '🚌',
          from: const RouteWaypoint(name: 'Swargate Bus Station', lat: 18.5018, lng: 73.8586),
          to: const RouteWaypoint(name: 'Pune Railway Station', lat: 18.5284, lng: 73.8744),
          waypoints: defaultWaypoints,
          distanceKm: 45.0,
          durationFormatted: '${item['departure_time'] ?? '08:00 AM'} - ${item['return_time'] ?? '06:00 PM'}',
          difficulty: 'Easy',
          bestTime: 'Year-round',
          highlights: const ['Historic Landmarks', 'City Highlights'],
          pitstops: const ['Swargate', 'Pune Station'],
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseDestinationRepository] getRoutes error: $e');
      return await _fallback.getRoutes();
    }
  }

  @override
  Future<RouteCircuit?> getRouteById(String id) async {
    final list = await getRoutes();
    return list.where((r) => r.id == id).firstOrNull ?? await _fallback.getRouteById(id);
  }

  @override
  Future<void> addRoute(RouteCircuit route) async {
    await _fallback.addRoute(route);
    try {
      await client.from(SupabaseConfig.tableDarshanCircuits).upsert({
        'id': route.id,
        'circuit_code': route.id.toUpperCase(),
        'title': route.title,
        'description': route.subtitle,
        'departure_time': '08:00 AM',
        'return_time': '06:00 PM',
        'bus_type': 'AC Electric Coach',
        'fare_per_seat': 500,
        'is_active': true,
      });
    } catch (e) {
      debugPrint('[SupabaseDestinationRepository] addRoute error: $e');
    }
  }

  @override
  Future<void> updateRoute(RouteCircuit route) async {
    await _fallback.updateRoute(route);
    try {
      await client.from(SupabaseConfig.tableDarshanCircuits).upsert({
        'id': route.id,
        'circuit_code': route.id.toUpperCase(),
        'title': route.title,
        'description': route.subtitle,
        'is_active': true,
      });
    } catch (e) {
      debugPrint('[SupabaseDestinationRepository] updateRoute error: $e');
    }
  }

  @override
  Future<void> reorderRouteStops(String routeId, List<RouteWaypoint> waypoints) async {
    await _fallback.reorderRouteStops(routeId, waypoints);
  }

  @override
  Future<void> deleteRoute(String id) async {
    await _fallback.deleteRoute(id);
    try {
      await client.from(SupabaseConfig.tableDarshanCircuits).delete().eq('id', id);
    } catch (e) {
      debugPrint('[SupabaseDestinationRepository] deleteRoute error: $e');
    }
  }

  // ── Heritage Walks ───────────────────────────────────────────────────────────

  @override
  Future<List<HeritageWalk>> getHeritageWalks() async {
    try {
      final res = await client
          .from(SupabaseConfig.tableHeritageWalks)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: true);
      final list = res as List<dynamic>;
      if (list.isEmpty) return await _fallback.getHeritageWalks();

      return list.map((item) {
        final hero = item['hero_image'] as String? ?? '';
        return HeritageWalk(
          id: item['id'] as String,
          title: item['title'] as String? ?? '',
          marathiTitle: '',
          subtitle: item['tagline'] as String? ?? '',
          category: HeritageWalkCategory.royalWadas,
          coverImage: hero.isNotEmpty ? hero : 'https://images.unsplash.com/photo-1590050752117-238cb0fb12b1?w=1200',
          galleryImages: const [],
          durationMinutes: (item['duration_minutes'] as num?)?.toInt() ?? 120,
          distanceKm: (item['distance_km'] as num?)?.toDouble() ?? 2.5,
          difficulty: WalkDifficulty.easy,
          startLocationName: item['start_point'] as String? ?? 'Shaniwar Wada',
          endLocationName: item['end_point'] as String? ?? 'Vishrambaug Wada',
          startLatitude: 18.5196,
          startLongitude: 73.8553,
          price: (item['ticket_price'] as num?)?.toDouble() ?? 299.0,
          whatToBring: const ['Comfortable walking shoes', 'Water bottle', 'Camera'],
          culturalEtiquette: const ['Dress modestly when entering temple areas'],
          localFoodPitstops: const ['Puneri Chai & Misal at Kasba Peth'],
          description: item['description'] as String? ?? '',
          historicalContext: item['tagline'] as String? ?? '',
          stops: const [],
          guideName: 'Heritage Walk Lead',
          guideRole: 'Cultural Historian',
          guideAvatar: '',
          isFeatured: true,
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseDestinationRepository] getHeritageWalks error: $e');
      return await _fallback.getHeritageWalks();
    }
  }

  @override
  Future<HeritageWalk?> getHeritageWalkById(String id) async {
    final list = await getHeritageWalks();
    return list.where((w) => w.id == id).firstOrNull ?? await _fallback.getHeritageWalkById(id);
  }

  @override
  Future<void> addHeritageWalk(HeritageWalk walk) async {
    await _fallback.addHeritageWalk(walk);
    try {
      await client.from(SupabaseConfig.tableHeritageWalks).upsert({
        'id': walk.id,
        'title': walk.title,
        'tagline': walk.subtitle,
        'description': walk.description,
        'hero_image': walk.coverImage,
        'duration_minutes': walk.durationMinutes,
        'distance_km': walk.distanceKm,
        'difficulty': walk.difficulty.name,
        'start_point': walk.startLocationName,
        'end_point': walk.endLocationName,
        'ticket_price': walk.price,
        'is_active': true,
      });
    } catch (e) {
      debugPrint('[SupabaseDestinationRepository] addHeritageWalk error: $e');
    }
  }

  @override
  Future<void> updateHeritageWalk(HeritageWalk walk) async {
    await _fallback.updateHeritageWalk(walk);
    try {
      await client.from(SupabaseConfig.tableHeritageWalks).upsert({
        'id': walk.id,
        'title': walk.title,
        'tagline': walk.subtitle,
        'description': walk.description,
        'hero_image': walk.coverImage,
        'duration_minutes': walk.durationMinutes,
        'distance_km': walk.distanceKm,
        'ticket_price': walk.price,
        'is_active': true,
      });
    } catch (e) {
      debugPrint('[SupabaseDestinationRepository] updateHeritageWalk error: $e');
    }
  }

  @override
  Future<void> deleteHeritageWalk(String id) async {
    await _fallback.deleteHeritageWalk(id);
    try {
      await client.from(SupabaseConfig.tableHeritageWalks).delete().eq('id', id);
    } catch (e) {
      debugPrint('[SupabaseDestinationRepository] deleteHeritageWalk error: $e');
    }
  }

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
