import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/destination.dart';
import '../models/tour_package.dart';
import '../models/route_model.dart';
import '../models/heritage_walk.dart';
import '../models/coupon.dart';
import '../models/review.dart';
import '../seed/pune_seed_data.dart';

abstract class DestinationRepository {
  Future<List<Destination>> getDestinations();
  Future<Destination?> getDestinationById(String id);
  Future<void> addDestination(Destination destination);
  Future<void> updateDestination(Destination destination);
  Future<void> deleteDestination(String id);

  Future<List<TourPackage>> getTourPackages();
  Future<TourPackage?> getTourPackageById(String id);
  Future<void> addTourPackage(TourPackage package);
  Future<void> updateTourPackage(TourPackage package);
  Future<void> deleteTourPackage(String id);

  Future<List<RouteCircuit>> getRoutes();
  Future<RouteCircuit?> getRouteById(String id);
  Future<void> addRoute(RouteCircuit route);
  Future<void> updateRoute(RouteCircuit route);
  Future<void> reorderRouteStops(String routeId, List<RouteWaypoint> waypoints);
  Future<void> deleteRoute(String id);

  Future<List<HeritageWalk>> getHeritageWalks();
  Future<HeritageWalk?> getHeritageWalkById(String id);
  Future<void> addHeritageWalk(HeritageWalk walk);
  Future<void> updateHeritageWalk(HeritageWalk walk);
  Future<void> deleteHeritageWalk(String id);

  Future<List<Coupon>> getCoupons();
  Future<void> addCoupon(Coupon coupon);
  Future<void> deleteCoupon(String code);

  Future<List<Review>> getReviews(String destinationId);
  Future<List<Review>> getAllReviews();
  Future<void> addReview(Review review);
  Future<void> updateReview(Review review);
  Future<void> deleteReview(String id);

  void resetToSeed();
}

class LocalDestinationRepository implements DestinationRepository {
  static const String keyDestinations = 'pune_cms_destinations';
  static const String keyTourPackages = 'pune_cms_tour_packages';
  static const String keyRoutes = 'pune_cms_routes';
  static const String keyHeritageWalks = 'pune_cms_heritage_walks';
  static const String keyCoupons = 'pune_cms_coupons';
  static const String keyReviews = 'pune_cms_reviews';

  List<Destination> _destinations = List.from(PuneSeedData.destinations);
  List<TourPackage> _tourPackages = List.from(PuneSeedData.tourPackages);
  List<RouteCircuit> _routes = List.from(PuneSeedData.routes);
  List<HeritageWalk> _heritageWalks = List.from(PuneSeedData.heritageWalks);
  List<Coupon> _coupons = List.from(PuneSeedData.coupons);
  List<Review> _reviews = List.from(PuneSeedData.reviews);
  bool _isLoaded = false;

  Future<void> _loadFromStorage() async {
    if (_isLoaded) return;
    _isLoaded = true;
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(milliseconds: 60),
      );

      // Destinations
      final rawDest = prefs.getString(keyDestinations);
      if (rawDest != null) {
        final List<dynamic> list = jsonDecode(rawDest);
        _destinations = list.map((e) => Destination.fromJson(e as Map<String, dynamic>)).toList();
      }

      // Tour Packages
      final rawTours = prefs.getString(keyTourPackages);
      if (rawTours != null) {
        final List<dynamic> list = jsonDecode(rawTours);
        _tourPackages = list.map((e) => TourPackage.fromJson(e as Map<String, dynamic>)).toList();
      }

      // Routes (Pune Darshan circuits)
      final rawRoutes = prefs.getString(keyRoutes);
      if (rawRoutes != null) {
        final List<dynamic> list = jsonDecode(rawRoutes);
        _routes = list.map((e) => RouteCircuit.fromJson(e as Map<String, dynamic>)).toList();
      }

      // Heritage Walks
      final rawWalks = prefs.getString(keyHeritageWalks);
      if (rawWalks != null) {
        final List<dynamic> list = jsonDecode(rawWalks);
        _heritageWalks = list.map((e) => HeritageWalk.fromJson(e as Map<String, dynamic>)).toList();
      }

      // Coupons
      final rawCoupons = prefs.getString(keyCoupons);
      if (rawCoupons != null) {
        final List<dynamic> list = jsonDecode(rawCoupons);
        _coupons = list.map((e) => Coupon.fromJson(e as Map<String, dynamic>)).toList();
      }

      // Reviews
      final rawReviews = prefs.getString(keyReviews);
      if (rawReviews != null) {
        final List<dynamic> list = jsonDecode(rawReviews);
        _reviews = list.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Fallback kept to initial seed data
    }
  }

  Future<void> _persist(String key, List<dynamic> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(items));
    } catch (_) {}
  }

  // ── Destinations ────────────────────────────────────────────────────────────

  @override
  Future<List<Destination>> getDestinations() async {
    await _loadFromStorage();
    return List.unmodifiable(_destinations);
  }

  @override
  Future<Destination?> getDestinationById(String id) async {
    await _loadFromStorage();
    try {
      return _destinations.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addDestination(Destination destination) async {
    await _loadFromStorage();
    _destinations.insert(0, destination);
    await _persist(keyDestinations, _destinations.map((d) => d.toJson()).toList());
  }

  @override
  Future<void> updateDestination(Destination destination) async {
    await _loadFromStorage();
    final index = _destinations.indexWhere((d) => d.id == destination.id);
    if (index != -1) {
      _destinations[index] = destination;
      await _persist(keyDestinations, _destinations.map((d) => d.toJson()).toList());
    }
  }

  @override
  Future<void> deleteDestination(String id) async {
    await _loadFromStorage();
    _destinations.removeWhere((d) => d.id == id);
    await _persist(keyDestinations, _destinations.map((d) => d.toJson()).toList());
  }

  // ── Tour Packages ───────────────────────────────────────────────────────────

  @override
  Future<List<TourPackage>> getTourPackages() async {
    await _loadFromStorage();
    return List.unmodifiable(_tourPackages);
  }

  @override
  Future<TourPackage?> getTourPackageById(String id) async {
    await _loadFromStorage();
    try {
      return _tourPackages.firstWhere((p) => p.id == id);
    } catch (_) {
      // Graceful fallback for legacy IDs to maintain backward compatibility
      if ((id == 'pkg_darshan_royal' || id == 'pkg_darshan' || id == 'pkg_1') && _tourPackages.isNotEmpty) {
        return _tourPackages.firstWhere(
          (p) => p.id == 'PNE-DAR-01',
          orElse: () => _tourPackages.first,
        );
      }
      return null;
    }
  }

  @override
  Future<void> addTourPackage(TourPackage package) async {
    await _loadFromStorage();
    _tourPackages.insert(0, package);
    await _persist(keyTourPackages, _tourPackages.map((p) => p.toJson()).toList());
  }

  @override
  Future<void> updateTourPackage(TourPackage package) async {
    await _loadFromStorage();
    final index = _tourPackages.indexWhere((p) => p.id == package.id);
    if (index != -1) {
      _tourPackages[index] = package;
      await _persist(keyTourPackages, _tourPackages.map((p) => p.toJson()).toList());
    }
  }

  @override
  Future<void> deleteTourPackage(String id) async {
    await _loadFromStorage();
    _tourPackages.removeWhere((p) => p.id == id);
    await _persist(keyTourPackages, _tourPackages.map((p) => p.toJson()).toList());
  }

  // ── Route Circuits & Pune Darshan ──────────────────────────────────────────

  @override
  Future<List<RouteCircuit>> getRoutes() async {
    await _loadFromStorage();
    return List.unmodifiable(_routes);
  }

  @override
  Future<RouteCircuit?> getRouteById(String id) async {
    await _loadFromStorage();
    try {
      return _routes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addRoute(RouteCircuit route) async {
    await _loadFromStorage();
    _routes.insert(0, route);
    await _persist(keyRoutes, _routes.map((r) => r.toJson()).toList());
  }

  @override
  Future<void> updateRoute(RouteCircuit route) async {
    await _loadFromStorage();
    final index = _routes.indexWhere((r) => r.id == route.id);
    if (index != -1) {
      _routes[index] = route;
      await _persist(keyRoutes, _routes.map((r) => r.toJson()).toList());
    }
  }

  @override
  Future<void> reorderRouteStops(String routeId, List<RouteWaypoint> waypoints) async {
    await _loadFromStorage();
    final index = _routes.indexWhere((r) => r.id == routeId);
    if (index != -1) {
      final current = _routes[index];
      _routes[index] = RouteCircuit(
        id: current.id,
        title: current.title,
        subtitle: current.subtitle,
        badge: current.badge,
        icon: current.icon,
        from: current.from,
        to: current.to,
        waypoints: waypoints,
        distanceKm: current.distanceKm,
        durationFormatted: current.durationFormatted,
        difficulty: current.difficulty,
        bestTime: current.bestTime,
        highlights: current.highlights,
        pitstops: current.pitstops,
      );
      await _persist(keyRoutes, _routes.map((r) => r.toJson()).toList());
    }
  }

  @override
  Future<void> deleteRoute(String id) async {
    await _loadFromStorage();
    _routes.removeWhere((r) => r.id == id);
    await _persist(keyRoutes, _routes.map((r) => r.toJson()).toList());
  }

  // ── Heritage Walks ──────────────────────────────────────────────────────────

  @override
  Future<List<HeritageWalk>> getHeritageWalks() async {
    await _loadFromStorage();
    return List.unmodifiable(_heritageWalks);
  }

  @override
  Future<HeritageWalk?> getHeritageWalkById(String id) async {
    await _loadFromStorage();
    try {
      return _heritageWalks.firstWhere((w) => w.id == id);
    } catch (_) {
      if ((id == 'walk_old_pune' || id == 'walk_1') && _heritageWalks.isNotEmpty) {
        return _heritageWalks.firstWhere(
          (w) => w.id == 'PNE-WAL-01',
          orElse: () => _heritageWalks.first,
        );
      }
      return null;
    }
  }

  @override
  Future<void> addHeritageWalk(HeritageWalk walk) async {
    await _loadFromStorage();
    _heritageWalks.insert(0, walk);
    await _persist(keyHeritageWalks, _heritageWalks.map((w) => w.toJson()).toList());
  }

  @override
  Future<void> updateHeritageWalk(HeritageWalk walk) async {
    await _loadFromStorage();
    final index = _heritageWalks.indexWhere((w) => w.id == walk.id);
    if (index != -1) {
      _heritageWalks[index] = walk;
      await _persist(keyHeritageWalks, _heritageWalks.map((w) => w.toJson()).toList());
    }
  }

  @override
  Future<void> deleteHeritageWalk(String id) async {
    await _loadFromStorage();
    _heritageWalks.removeWhere((w) => w.id == id);
    await _persist(keyHeritageWalks, _heritageWalks.map((w) => w.toJson()).toList());
  }

  // ── Coupons ─────────────────────────────────────────────────────────────────

  @override
  Future<List<Coupon>> getCoupons() async {
    await _loadFromStorage();
    return List.unmodifiable(_coupons);
  }

  @override
  Future<void> addCoupon(Coupon coupon) async {
    await _loadFromStorage();
    _coupons.insert(0, coupon);
    await _persist(keyCoupons, _coupons.map((c) => c.toJson()).toList());
  }

  @override
  Future<void> deleteCoupon(String code) async {
    await _loadFromStorage();
    _coupons.removeWhere((c) => c.code.toUpperCase() == code.toUpperCase());
    await _persist(keyCoupons, _coupons.map((c) => c.toJson()).toList());
  }

  // ── Reviews ─────────────────────────────────────────────────────────────────

  @override
  Future<List<Review>> getReviews(String destinationId) async {
    await _loadFromStorage();
    return _reviews.where((r) => r.destinationId == destinationId).toList();
  }

  @override
  Future<List<Review>> getAllReviews() async {
    await _loadFromStorage();
    return List.unmodifiable(_reviews);
  }

  @override
  Future<void> addReview(Review review) async {
    await _loadFromStorage();
    _reviews.insert(0, review);
    await _persist(keyReviews, _reviews.map((r) => r.toJson()).toList());
  }

  @override
  Future<void> updateReview(Review review) async {
    await _loadFromStorage();
    final index = _reviews.indexWhere((r) => r.id == review.id);
    if (index != -1) {
      _reviews[index] = review;
      await _persist(keyReviews, _reviews.map((r) => r.toJson()).toList());
    }
  }

  @override
  Future<void> deleteReview(String id) async {
    await _loadFromStorage();
    _reviews.removeWhere((r) => r.id == id);
    await _persist(keyReviews, _reviews.map((r) => r.toJson()).toList());
  }

  /// Reset all data back to original seed data
  @override
  void resetToSeed() {
    _destinations = List.from(PuneSeedData.destinations);
    _tourPackages = List.from(PuneSeedData.tourPackages);
    _routes = List.from(PuneSeedData.routes);
    _heritageWalks = List.from(PuneSeedData.heritageWalks);
    _coupons = List.from(PuneSeedData.coupons);
    _reviews = List.from(PuneSeedData.reviews);
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(keyDestinations);
      prefs.remove(keyTourPackages);
      prefs.remove(keyRoutes);
      prefs.remove(keyHeritageWalks);
      prefs.remove(keyCoupons);
      prefs.remove(keyReviews);
    });
  }
}
