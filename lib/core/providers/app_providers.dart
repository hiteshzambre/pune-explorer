import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/destination.dart';
import '../../data/models/tour_package.dart';
import '../../data/models/route_model.dart';
import '../../data/models/heritage_walk.dart';
import '../../data/models/coupon.dart';
import '../../data/models/booking.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/review.dart';
import '../../data/models/weather_model.dart';
import '../../data/models/itinerary_model.dart';
import '../../data/models/branding_model.dart';
import '../../data/models/payment_order.dart';
import '../../data/repositories/destination_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/cms_repository.dart';
import '../../data/repositories/media_library_repository.dart';
import '../../data/repositories/audit_log_repository.dart';
import '../../data/repositories/coupon_repository.dart';
import '../../data/repositories/admin_support_repository.dart';
import '../../data/repositories/admin_refund_repository.dart';
import '../../data/repositories/admin_settings_repository.dart';
import '../supabase/supabase_config.dart';
import '../../data/repositories/supabase/supabase_auth_repository.dart';
import '../../data/repositories/supabase/supabase_destination_repository.dart';
import '../../data/repositories/supabase/supabase_booking_repository.dart';
import '../../data/repositories/supabase/supabase_payment_repository.dart';
import '../../data/repositories/supabase/supabase_cms_repository.dart';
import '../../data/repositories/supabase/supabase_coupon_repository.dart';
import '../../data/repositories/supabase/supabase_support_repository.dart';
import '../../data/repositories/supabase/supabase_refund_repository.dart';
import '../../data/repositories/supabase/supabase_media_repository.dart';
import '../../data/repositories/supabase/supabase_settings_repository.dart';
import '../../data/repositories/supabase/supabase_audit_repository.dart';
import '../../data/models/admin_support_ticket.dart';
import '../../data/models/admin_refund_request.dart';
import '../../data/models/admin_personalization.dart';
import '../../data/models/admin_global_settings.dart';
import '../../data/models/cms_models.dart';
import '../../core/constants/admin_permissions.dart';
import '../../services/weather_service.dart';
import '../../services/ai_service.dart';
import '../../services/payment_service.dart';
import '../../services/offline_service.dart';
import '../../services/itinerary_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/admin_constants.dart';
import '../../core/enums/app_enums.dart';

class PreferencesCache {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }
}

// ── Repositories & Services Providers ───────────────────────────────────────
final destinationRepositoryProvider = Provider<DestinationRepository>((ref) {
  if (SupabaseConfig.isConfigured && SupabaseConfig.isInitialized) {
    return SupabaseDestinationRepository();
  }
  return LocalDestinationRepository();
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  if (SupabaseConfig.isConfigured && SupabaseConfig.isInitialized) {
    return SupabaseBookingRepository();
  }
  return LocalBookingRepository();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (SupabaseConfig.isConfigured && SupabaseConfig.isInitialized) {
    return SupabaseAuthRepository();
  }
  return LocalAuthRepository();
});

final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return MockPaymentService();
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final bookingRepo = ref.watch(bookingRepositoryProvider);
  if (SupabaseConfig.isConfigured && SupabaseConfig.isInitialized) {
    return SupabasePaymentRepository(bookingRepository: bookingRepo);
  }
  return LocalPaymentRepository(bookingRepository: bookingRepo);
});

class PaymentOrdersNotifier extends StateNotifier<AsyncValue<List<PaymentOrder>>> {
  final PaymentRepository _repo;

  PaymentOrdersNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      final orders = await _repo.getAllOrders();
      if (mounted) state = AsyncValue.data(orders);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  Future<PaymentOrder> createOrder({
    required String bookingId,
    required String userId,
    required String packageId,
    required String packageName,
    required double amount,
    String? merchantUpiId,
    String? merchantName,
  }) async {
    final order = await _repo.createOrder(
      bookingId: bookingId,
      userId: userId,
      packageId: packageId,
      packageName: packageName,
      amount: amount,
      merchantUpiId: merchantUpiId,
      merchantName: merchantName,
    );
    await loadOrders();
    return order;
  }

  Future<PaymentOrder> submitTransactionId({
    required String orderId,
    required String transactionId,
  }) async {
    final updated = await _repo.submitTransactionId(
      orderId: orderId,
      transactionId: transactionId,
    );
    await loadOrders();
    return updated;
  }

  Future<PaymentOrder> verifyPayment({
    required String orderId,
    required String verifiedBy,
    String? notes,
  }) async {
    final updated = await _repo.verifyPayment(
      orderId: orderId,
      verifiedBy: verifiedBy,
      notes: notes,
    );
    await loadOrders();
    return updated;
  }

  Future<PaymentOrder> rejectPayment({
    required String orderId,
    required String reason,
    required String rejectedBy,
  }) async {
    final updated = await _repo.rejectPayment(
      orderId: orderId,
      reason: reason,
      rejectedBy: rejectedBy,
    );
    await loadOrders();
    return updated;
  }

  Future<PaymentOrder> regenerateOrder(String orderId) async {
    final refreshed = await _repo.regenerateExpiredOrder(orderId);
    await loadOrders();
    return refreshed;
  }
}

final paymentOrdersProvider = StateNotifierProvider<PaymentOrdersNotifier, AsyncValue<List<PaymentOrder>>>((ref) {
  final repo = ref.watch(paymentRepositoryProvider);
  return PaymentOrdersNotifier(repo);
});

final paymentOrderByIdProvider = Provider.family<PaymentOrder?, String>((ref, orderId) {
  final ordersAsync = ref.watch(paymentOrdersProvider);
  return ordersAsync.maybeWhen(
    data: (orders) => orders.where((o) => o.orderId == orderId || o.id == orderId).firstOrNull,
    orElse: () => null,
  );
});

final pendingPaymentVerificationsProvider = Provider<List<PaymentOrder>>((ref) {
  final ordersAsync = ref.watch(paymentOrdersProvider);
  return ordersAsync.maybeWhen(
    data: (orders) => orders
        .where((o) =>
            o.status == PaymentStatus.underVerification ||
            o.status == PaymentStatus.paymentSubmitted)
        .toList(),
    orElse: () => const [],
  );
});


// ── Destination Catalog & Async State ──────────────────────────────────────
final destinationsAsyncProvider = FutureProvider<List<Destination>>((ref) async {
  final repo = ref.watch(destinationRepositoryProvider);
  return repo.getDestinations();
});

final trendingDestinationsProvider = Provider<List<Destination>>((ref) {
  final asyncDest = ref.watch(destinationsAsyncProvider);
  return asyncDest.maybeWhen(
    data: (list) {
      final trending = list.where((d) => d.isTrending).toList();
      return trending.isNotEmpty ? trending : list;
    },
    orElse: () => const [],
  );
});

final featuredDestinationsProvider = Provider<List<Destination>>((ref) {
  final asyncDest = ref.watch(destinationsAsyncProvider);
  return asyncDest.maybeWhen(
    data: (list) {
      final featured = list.where((d) => d.isFeatured).take(5).toList();
      return featured.isNotEmpty ? featured : list.take(4).toList();
    },
    orElse: () => const [],
  );
});

final destinationWeatherProvider = FutureProvider.family<WeatherData, ({double lat, double lng})>((ref, coords) async {
  final service = ref.watch(weatherServiceProvider);
  return service.fetchDestinationWeather(coords.lat, coords.lng);
});

final destinationReviewsProvider = FutureProvider.family<List<Review>, String>((ref, destId) async {
  final repo = ref.watch(destinationRepositoryProvider);
  return repo.getReviews(destId);
});

final tourPackagesAsyncProvider = FutureProvider<List<TourPackage>>((ref) async {
  final repo = ref.watch(destinationRepositoryProvider);
  return repo.getTourPackages();
});

final routesAsyncProvider = FutureProvider<List<RouteCircuit>>((ref) async {
  final repo = ref.watch(destinationRepositoryProvider);
  return repo.getRoutes();
});

final heritageWalksAsyncProvider = FutureProvider<List<HeritageWalk>>((ref) async {
  final repo = ref.watch(destinationRepositoryProvider);
  return repo.getHeritageWalks();
});

// ── Heritage Walk Filter State & Providers ──────────────────────────────────
class HeritageWalkFilterState {
  final String searchQuery;
  final HeritageWalkCategory? category;
  final WalkDifficulty? difficulty;
  final int? maxDurationMinutes;
  final WalkTimeOfDay? timeOfDay;
  final bool? isFreeOnly;
  final String sortBy; // 'popular', 'shortest', 'longest', 'rating'

  const HeritageWalkFilterState({
    this.searchQuery = '',
    this.category,
    this.difficulty,
    this.maxDurationMinutes,
    this.timeOfDay,
    this.isFreeOnly,
    this.sortBy = 'popular',
  });

  bool get hasActiveFilters =>
      category != null ||
      difficulty != null ||
      maxDurationMinutes != null ||
      timeOfDay != null ||
      isFreeOnly == true ||
      searchQuery.isNotEmpty;

  HeritageWalkFilterState copyWith({
    String? searchQuery,
    HeritageWalkCategory? category,
    bool clearCategory = false,
    WalkDifficulty? difficulty,
    bool clearDifficulty = false,
    int? maxDurationMinutes,
    bool clearDuration = false,
    WalkTimeOfDay? timeOfDay,
    bool clearTimeOfDay = false,
    bool? isFreeOnly,
    bool clearFreeOnly = false,
    String? sortBy,
  }) {
    return HeritageWalkFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      category: clearCategory ? null : (category ?? this.category),
      difficulty: clearDifficulty ? null : (difficulty ?? this.difficulty),
      maxDurationMinutes: clearDuration ? null : (maxDurationMinutes ?? this.maxDurationMinutes),
      timeOfDay: clearTimeOfDay ? null : (timeOfDay ?? this.timeOfDay),
      isFreeOnly: clearFreeOnly ? null : (isFreeOnly ?? this.isFreeOnly),
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class HeritageWalkFilterNotifier extends StateNotifier<HeritageWalkFilterState> {
  HeritageWalkFilterNotifier() : super(const HeritageWalkFilterState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategory(HeritageWalkCategory? category) {
    if (category == null || state.category == category) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(category: category);
    }
  }

  void setDifficulty(WalkDifficulty? difficulty) {
    if (difficulty == null || state.difficulty == difficulty) {
      state = state.copyWith(clearDifficulty: true);
    } else {
      state = state.copyWith(difficulty: difficulty);
    }
  }

  void setMaxDuration(int? maxDurationMinutes) {
    if (maxDurationMinutes == null || state.maxDurationMinutes == maxDurationMinutes) {
      state = state.copyWith(clearDuration: true);
    } else {
      state = state.copyWith(maxDurationMinutes: maxDurationMinutes);
    }
  }

  void setTimeOfDay(WalkTimeOfDay? timeOfDay) {
    if (timeOfDay == null || state.timeOfDay == timeOfDay) {
      state = state.copyWith(clearTimeOfDay: true);
    } else {
      state = state.copyWith(timeOfDay: timeOfDay);
    }
  }

  void toggleFreeOnly() {
    final nextVal = state.isFreeOnly == true ? null : true;
    if (nextVal == null) {
      state = state.copyWith(clearFreeOnly: true);
    } else {
      state = state.copyWith(isFreeOnly: true);
    }
  }

  void setSortBy(String sort) {
    state = state.copyWith(sortBy: sort);
  }

  void resetFilters() {
    state = const HeritageWalkFilterState();
  }
}

final heritageWalkFilterProvider =
    StateNotifierProvider<HeritageWalkFilterNotifier, HeritageWalkFilterState>((ref) {
  return HeritageWalkFilterNotifier();
});

final filteredHeritageWalksProvider = Provider<AsyncValue<List<HeritageWalk>>>((ref) {
  final walksAsync = ref.watch(heritageWalksAsyncProvider);
  final filter = ref.watch(heritageWalkFilterProvider);

  return walksAsync.whenData((walks) {
    var result = List<HeritageWalk>.from(walks);

    // 1. Search Query Filter
    if (filter.searchQuery.trim().isNotEmpty) {
      final q = filter.searchQuery.toLowerCase().trim();
      result = result.where((w) {
        final titleMatch = w.title.toLowerCase().contains(q);
        final marathiMatch = w.marathiTitle.toLowerCase().contains(q);
        final subtitleMatch = w.subtitle.toLowerCase().contains(q);
        final descriptionMatch = w.description.toLowerCase().contains(q);
        final startMatch = w.startLocationName.toLowerCase().contains(q);
        final endMatch = w.endLocationName.toLowerCase().contains(q);
        final highlightsMatch = w.highlights.any((h) => h.toLowerCase().contains(q));
        final stopsMatch = w.stops.any((s) =>
            s.name.toLowerCase().contains(q) ||
            s.marathiName.toLowerCase().contains(q) ||
            s.historicalStory.toLowerCase().contains(q));
        return titleMatch ||
            marathiMatch ||
            subtitleMatch ||
            descriptionMatch ||
            startMatch ||
            endMatch ||
            highlightsMatch ||
            stopsMatch;
      }).toList();
    }

    // 2. Category Filter
    if (filter.category != null) {
      result = result.where((w) => w.category == filter.category).toList();
    }

    // 3. Difficulty Filter
    if (filter.difficulty != null) {
      result = result.where((w) => w.difficulty == filter.difficulty).toList();
    }

    // 4. Max Duration Filter
    if (filter.maxDurationMinutes != null) {
      result = result.where((w) => w.durationMinutes <= filter.maxDurationMinutes!).toList();
    }

    // 5. Time of Day Filter
    if (filter.timeOfDay != null) {
      result = result.where((w) => w.bestTimeOfDay == filter.timeOfDay || w.bestTimeOfDay == WalkTimeOfDay.anytime).toList();
    }

    // 6. Free Only
    if (filter.isFreeOnly == true) {
      result = result.where((w) => w.isFree).toList();
    }

    // 7. Sort
    switch (filter.sortBy) {
      case 'shortest':
        result.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
      case 'longest':
        result.sort((a, b) => b.distanceKm.compareTo(a.distanceKm));
        break;
      case 'rating':
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'popular':
      default:
        result.sort((a, b) {
          if (a.isFeatured && !b.isFeatured) return -1;
          if (!a.isFeatured && b.isFeatured) return 1;
          return (b.reviewCount * b.rating).compareTo(a.reviewCount * a.rating);
        });
        break;
    }

    return result;
  });
});

final couponsAsyncProvider = FutureProvider<List<Coupon>>((ref) async {
  final repo = ref.watch(destinationRepositoryProvider);
  return repo.getCoupons();
});

// ── Explore Filter & Search States ──────────────────────────────────────────
class ExploreFilterState {
  final String searchQuery;
  final DestinationCategory category;
  final PuneRegion region;
  final String sortBy; // 'recommended', 'rating', 'price_asc', 'distance'
  final bool isGridView;

  const ExploreFilterState({
    this.searchQuery = '',
    this.category = DestinationCategory.all,
    this.region = PuneRegion.all,
    this.sortBy = 'recommended',
    this.isGridView = true,
  });

  ExploreFilterState copyWith({
    String? searchQuery,
    DestinationCategory? category,
    PuneRegion? region,
    String? sortBy,
    bool? isGridView,
  }) {
    return ExploreFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
      region: region ?? this.region,
      sortBy: sortBy ?? this.sortBy,
      isGridView: isGridView ?? this.isGridView,
    );
  }
}

class ExploreFilterNotifier extends StateNotifier<ExploreFilterState> {
  ExploreFilterNotifier() : super(const ExploreFilterState());

  void setSearchQuery(String query) => state = state.copyWith(searchQuery: query);
  void setCategory(DestinationCategory cat) => state = state.copyWith(category: cat);
  void setRegion(PuneRegion reg) => state = state.copyWith(region: reg);
  void setSortBy(String sort) => state = state.copyWith(sortBy: sort);
  void toggleViewMode() => state = state.copyWith(isGridView: !state.isGridView);
  void resetFilters() => state = const ExploreFilterState();
}

final exploreFilterProvider = StateNotifierProvider<ExploreFilterNotifier, ExploreFilterState>((ref) {
  return ExploreFilterNotifier();
});

// Filtered Destinations Provider
final filteredDestinationsProvider = Provider<List<Destination>>((ref) {
  final destinationsAsync = ref.watch(destinationsAsyncProvider);
  final filter = ref.watch(exploreFilterProvider);

  return destinationsAsync.when(
    data: (list) {
      return list.where((d) {
        // Search text matching
        if (filter.searchQuery.isNotEmpty) {
          final q = filter.searchQuery.toLowerCase();
          final matchName = d.name.toLowerCase().contains(q);
          final matchDesc = d.description.toLowerCase().contains(q);
          final matchFamous = d.famousFor.toLowerCase().contains(q);
          final matchCity = d.city.toLowerCase().contains(q);
          final matchState = d.state.toLowerCase().contains(q);
          final matchCategory = d.category.label.toLowerCase().contains(q);
          if (!matchName && !matchDesc && !matchFamous && !matchCity && !matchState && !matchCategory) return false;
        }

        // Category filter
        if (filter.category != DestinationCategory.all) {
          if (d.category != filter.category) return false;
        }

        // Region filter
        if (filter.region != PuneRegion.all) {
          if (!d.state.toLowerCase().contains(filter.region.label.toLowerCase())) return false;
        }

        return true;
      }).toList()
        ..sort((a, b) {
          if (filter.sortBy == 'rating') {
            return b.rating.compareTo(a.rating);
          } else if (filter.sortBy == 'price_asc') {
            return a.entryFeeIndian.compareTo(b.entryFeeIndian);
          } else if (filter.sortBy == 'distance') {
            return a.distanceFromPuneKm.compareTo(b.distanceFromPuneKm);
          }
          // Default: recommended / featured first
          if (a.isFeatured && !b.isFeatured) return -1;
          if (!a.isFeatured && b.isFeatured) return 1;
          return b.rating.compareTo(a.rating);
        });
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// ── Favorites State Notifier ────────────────────────────────────────────────
class FavoritesNotifier extends StateNotifier<Set<String>> {
  bool _isLoaded = false;

  FavoritesNotifier() : super(<String>{}) {
    _load();
  }

  Future<void> _load() async {
    final set = await OfflineService.getFavoriteIds();
    if (mounted && !_isLoaded) {
      state = set;
      _isLoaded = true;
    }
  }

  Future<void> toggle(String id) async {
    _isLoaded = true;
    await OfflineService.toggleFavorite(id);
    if (!mounted) return;
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  Future<void> clear() async {
    state = {};
  }

  bool isFavorite(String id) => state.contains(id);
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier();
});

// ── Recent Searches State ───────────────────────────────────────────────────
class RecentSearchesNotifier extends StateNotifier<List<String>> {
  bool _isLoaded = false;

  RecentSearchesNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final searches = await OfflineService.getRecentSearches();
    if (mounted && !_isLoaded) {
      state = searches;
      _isLoaded = true;
    }
  }

  Future<void> add(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;
    _isLoaded = true;
    final current = List<String>.from(state);
    current.remove(clean);
    current.insert(0, clean);
    if (current.length > 8) current.removeLast();
    state = current;
    await OfflineService.addRecentSearch(clean);
  }

  Future<void> clear() async {
    _isLoaded = true;
    state = [];
    await OfflineService.clearRecentSearches();
  }
}

final recentSearchesProvider = StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
  return RecentSearchesNotifier();
});

// ── User Authentication State ───────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    final user = await _repo.getCurrentUser();
    if (mounted) {
      state = AsyncValue.data(user ?? UserProfile.guest());
    }
  }

  Future<UserProfile> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.signInWithEmail(email, password);
      if (mounted) state = AsyncValue.data(user);
      return user;
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signInAsAdmin(String email, String password, String pin) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.signInAsAdmin(email, password, pin);
      if (mounted) state = AsyncValue.data(user);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<UserProfile> register(String name, String email, String password, String phone) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.registerWithEmail(name, email, password, phone);
      if (mounted) state = AsyncValue.data(user);
      return user;
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> continueAsGuest() async {
    final user = await _repo.signInAsGuest();
    if (mounted) state = AsyncValue.data(user);
  }

  Future<void> signOut() async {
    await _repo.signOut();
    if (mounted) state = AsyncValue.data(UserProfile.guest());
  }

  void updateProfile({String? name, String? phone, String? avatarUrl}) {
    final current = state.value;
    if (current != null) {
      final updated = UserProfile(
        id: current.id,
        email: current.email,
        name: name ?? current.name,
        phone: phone ?? current.phone,
        avatarUrl: avatarUrl ?? current.avatarUrl,
        isGuest: current.isGuest,
        isAdmin: current.isAdmin,
      );
      state = AsyncValue.data(updated);
    }
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserProfile>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

// ── User Bookings State ─────────────────────────────────────────────────────
class BookingsNotifier extends StateNotifier<AsyncValue<List<Booking>>> {
  final BookingRepository _repo;

  BookingsNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadBookings();
  }

  Future<void> loadBookings() async {
    state = const AsyncValue.loading();
    try {
      final bookings = await _repo.getBookings();
      if (mounted) state = AsyncValue.data(bookings);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  Future<void> addBooking(Booking booking) async {
    final current = state.value ?? [];
    state = AsyncValue.data([booking, ...current.where((b) => b.id != booking.id)]);
    try {
      await _repo.saveBooking(booking);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  Future<void> cancelBooking(String id) async {
    final current = state.value ?? [];
    state = AsyncValue.data(
      current.map((b) => b.id == id ? b.copyWith(status: BookingStatus.cancelled) : b).toList(),
    );
    try {
      await _repo.updateBookingStatus(id, BookingStatus.cancelled);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }
}

final userBookingsProvider = StateNotifierProvider<BookingsNotifier, AsyncValue<List<Booking>>>((ref) {
  final repo = ref.watch(bookingRepositoryProvider);
  return BookingsNotifier(repo);
});

// ── Theme Mode Notifier ─────────────────────────────────────────────────────
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await PreferencesCache.instance;
      final modeStr = prefs.getString(AppConstants.keyThemeMode);
      if (mounted) {
        if (modeStr == 'light') {
          state = ThemeMode.light;
        } else if (modeStr == 'dark') {
          state = ThemeMode.dark;
        } else if (modeStr == 'system') {
          state = ThemeMode.system;
        } else {
          state = ThemeMode.light;
        }
      }
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await PreferencesCache.instance;
      if (mode == ThemeMode.light) await prefs.setString(AppConstants.keyThemeMode, 'light');
      if (mode == ThemeMode.dark) await prefs.setString(AppConstants.keyThemeMode, 'dark');
      if (mode == ThemeMode.system) await prefs.setString(AppConstants.keyThemeMode, 'system');
    } catch (_) {}
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

// ── App Locale Notifier ─────────────────────────────────────────────────────
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await PreferencesCache.instance;
      final code = prefs.getString(AppConstants.keyLanguage);
      if (code != null) state = Locale(code);
    } catch (_) {}
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    try {
      final prefs = await PreferencesCache.instance;
      await prefs.setString(AppConstants.keyLanguage, languageCode);
    } catch (_) {}
  }
}

final appLocaleProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

// ── Itineraries Notifier ───────────────────────────────────────────────────
class ItinerariesNotifier extends StateNotifier<AsyncValue<List<ItineraryPlan>>> {
  ItinerariesNotifier() : super(const AsyncValue.loading()) {
    loadItineraries();
  }

  Future<void> loadItineraries() async {
    try {
      final list = await ItineraryService.getItineraries();
      if (mounted) state = AsyncValue.data(list);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  Future<void> savePlan(ItineraryPlan plan) async {
    final current = state.value ?? [];
    final idx = current.indexWhere((p) => p.id == plan.id);
    if (idx >= 0) {
      final updated = List<ItineraryPlan>.from(current);
      updated[idx] = plan;
      state = AsyncValue.data(updated);
    } else {
      state = AsyncValue.data([plan, ...current]);
    }
    await ItineraryService.saveItinerary(plan);
  }

  Future<void> deletePlan(String id) async {
    final current = state.value ?? [];
    state = AsyncValue.data(current.where((p) => p.id != id).toList());
    await ItineraryService.deleteItinerary(id);
  }
}

final userItinerariesProvider = StateNotifierProvider<ItinerariesNotifier, AsyncValue<List<ItineraryPlan>>>((ref) {
  return ItinerariesNotifier();
});

// ── Branding & CMS Settings Notifier ───────────────────────────────────────
class BrandingNotifier extends StateNotifier<BrandingConfig> {
  BrandingNotifier() : super(const BrandingConfig()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await PreferencesCache.instance;
      final raw = prefs.getString('pune_branding_config');
      if (raw != null && mounted) {
        state = BrandingConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {}
  }

  Future<void> updateConfig(BrandingConfig config) async {
    state = config;
    try {
      final prefs = await PreferencesCache.instance;
      await prefs.setString('pune_branding_config', jsonEncode(config.toJson()));
    } catch (_) {}
  }
}

final brandingConfigProvider = StateNotifierProvider<BrandingNotifier, BrandingConfig>((ref) {
  return BrandingNotifier();
});

// ── CMS, Media, and Audit Repositories ───────────────────────────────────────
final cmsRepositoryProvider = Provider<CmsRepository>((ref) {
  if (SupabaseConfig.isConfigured && SupabaseConfig.isInitialized) {
    return SupabaseCmsRepository();
  }
  return LocalCmsRepository();
});

final mediaLibraryRepositoryProvider = Provider<MediaLibraryRepository>((ref) {
  if (SupabaseConfig.isConfigured && SupabaseConfig.isInitialized) {
    return SupabaseMediaRepository();
  }
  return LocalMediaLibraryRepository();
});

final auditLogRepositoryProvider = Provider<AuditLogRepository>((ref) {
  if (SupabaseConfig.isConfigured && SupabaseConfig.isInitialized) {
    return SupabaseAuditRepository();
  }
  return LocalAuditLogRepository();
});

// ── Homepage CMS State Notifier ──────────────────────────────────────────────
class HomepageCmsNotifier extends StateNotifier<AsyncValue<HomepageCmsConfig>> {
  final CmsRepository _repo;
  final Ref _ref;

  HomepageCmsNotifier(this._repo, this._ref) : super(const AsyncValue.loading()) {
    loadConfig();
  }

  Future<void> loadConfig() async {
    try {
      final config = await _repo.getHomepageConfig();
      if (mounted) state = AsyncValue.data(config);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateConfig(HomepageCmsConfig config) async {
    await _repo.saveHomepageConfig(config);
    await loadConfig();
    _ref.invalidate(brandingConfigProvider);
  }

  Future<void> addSlide(HeroSlideItem slide) async {
    final current = state.value ?? HomepageCmsConfig.defaultSeed();
    final updated = current.copyWith(slides: [...current.slides, slide]);
    await updateConfig(updated);
  }

  Future<void> updateSlide(HeroSlideItem slide) async {
    final current = state.value ?? HomepageCmsConfig.defaultSeed();
    final index = current.slides.indexWhere((s) => s.id == slide.id);
    if (index >= 0) {
      final newSlides = List<HeroSlideItem>.from(current.slides);
      newSlides[index] = slide;
      await updateConfig(current.copyWith(slides: newSlides));
    }
  }

  Future<void> deleteSlide(String id) async {
    final current = state.value ?? HomepageCmsConfig.defaultSeed();
    final newSlides = current.slides.where((s) => s.id != id).toList();
    await updateConfig(current.copyWith(slides: newSlides));
  }
}

final homepageCmsProvider = StateNotifierProvider<HomepageCmsNotifier, AsyncValue<HomepageCmsConfig>>((ref) {
  final repo = ref.watch(cmsRepositoryProvider);
  return HomepageCmsNotifier(repo, ref);
});

// ── Media Library Assets Notifier ────────────────────────────────────────────
class MediaAssetsNotifier extends StateNotifier<AsyncValue<List<MediaAsset>>> {
  final MediaLibraryRepository _repo;

  MediaAssetsNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadAssets();
  }

  Future<void> loadAssets() async {
    try {
      final assets = await _repo.getAssets();
      if (mounted) state = AsyncValue.data(assets);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  Future<MediaAsset> addAsset(MediaAsset asset) async {
    final created = await _repo.addAsset(asset);
    await loadAssets();
    return created;
  }

  Future<List<MediaAsset>> addAssets(List<MediaAsset> assets) async {
    final created = await _repo.addAssets(assets);
    await loadAssets();
    return created;
  }

  Future<MediaAsset> updateAsset(MediaAsset asset) async {
    final updated = await _repo.updateAsset(asset);
    await loadAssets();
    return updated;
  }

  Future<bool> deleteAsset(String id) async {
    final res = await _repo.deleteAsset(id);
    await loadAssets();
    return res;
  }

  Future<int> replaceAssetUrl({required String oldUrl, required String newUrl}) async {
    final count = await _repo.replaceAssetUrl(oldUrl: oldUrl, newUrl: newUrl);
    await loadAssets();
    return count;
  }
}

final mediaAssetsProvider = StateNotifierProvider<MediaAssetsNotifier, AsyncValue<List<MediaAsset>>>((ref) {
  final repo = ref.watch(mediaLibraryRepositoryProvider);
  return MediaAssetsNotifier(repo);
});

// ── Audit Logs State Notifier ────────────────────────────────────────────────
class AuditLogsNotifier extends StateNotifier<AsyncValue<List<AuditLogEntry>>> {
  final AuditLogRepository _repo;

  AuditLogsNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadLogs();
  }

  Future<void> loadLogs() async {
    try {
      final logs = await _repo.getLogs();
      if (mounted) state = AsyncValue.data(logs);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  Future<AuditLogEntry> log({
    required String actorEmail,
    required String actorRole,
    required String action,
    required String resourceType,
    required String resourceId,
    Map<String, dynamic> metadata = const {},
  }) async {
    final entry = await _repo.log(
      actorEmail: actorEmail,
      actorRole: actorRole,
      action: action,
      resourceType: resourceType,
      resourceId: resourceId,
      metadata: metadata,
    );
    await loadLogs();
    return entry;
  }
}

final auditLogsProvider = StateNotifierProvider<AuditLogsNotifier, AsyncValue<List<AuditLogEntry>>>((ref) {
  final repo = ref.watch(auditLogRepositoryProvider);
  return AuditLogsNotifier(repo);
});

final allUsersProvider = FutureProvider<List<UserProfile>>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.getAllUsers();
});

final adminAccountsProvider = FutureProvider<List<AdminAccount>>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.getAdminAccounts();
});

// ── Admin Session State & Notifier with RBAC ─────────────────────────────────
class AdminSessionState {
  final bool isAuthenticated;
  final String email;
  final String role;
  final String? sessionToken;
  final String? lastLogin;

  const AdminSessionState({
    this.isAuthenticated = false,
    this.email = '',
    this.role = '',
    this.sessionToken,
    this.lastLogin,
  });

  AdminRole get adminRole => AdminRole.fromString(role);

  bool hasPermission(String permission) =>
      AdminPermissions.hasPermission(adminRole, permission);

  AdminSessionState copyWith({
    bool? isAuthenticated,
    String? email,
    String? role,
    String? sessionToken,
    String? lastLogin,
  }) {
    return AdminSessionState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      email: email ?? this.email,
      role: role ?? this.role,
      sessionToken: sessionToken ?? this.sessionToken,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

class AdminSessionNotifier extends StateNotifier<AdminSessionState> {
  final Ref _ref;

  AdminSessionNotifier(this._ref) : super(const AdminSessionState()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await PreferencesCache.instance;
      final token = prefs.getString(AdminConstants.keyAdminToken);
      final email = prefs.getString(AdminConstants.keyAdminEmail) ?? AdminConstants.defaultAdminEmail;
      final role = prefs.getString(AdminConstants.keyAdminRole) ?? AdminConstants.roleSuperAdmin;
      final lastLogin = prefs.getString(AdminConstants.keyAdminLastLogin);

      if (token != null && token.isNotEmpty && mounted) {
        state = AdminSessionState(
          isAuthenticated: true,
          email: email,
          role: role,
          sessionToken: token,
          lastLogin: lastLogin,
        );
      }
    } catch (_) {}
  }

  void switchRole(AdminRole newRole) {
    state = state.copyWith(role: newRole.label);
    PreferencesCache.instance.then((prefs) {
      prefs.setString(AdminConstants.keyAdminRole, newRole.label);
    });
  }

  Future<void> reloadSession() async {
    await _load();
  }

  Future<bool> login(String email, String password, [String pin = '1234']) async {
    try {
      await _ref.read(authStateProvider.notifier).signInAsAdmin(email, password, pin);
      final prefs = await PreferencesCache.instance;
      final token = prefs.getString(AdminConstants.keyAdminToken) ?? 'admin_token_${DateTime.now().millisecondsSinceEpoch}';
      final role = prefs.getString(AdminConstants.keyAdminRole) ?? AdminConstants.roleSuperAdmin;

      await prefs.setString(AdminConstants.keyAdminToken, token);
      await prefs.setString(AdminConstants.keyAdminEmail, email.trim());
      await prefs.setString(AdminConstants.keyAdminRole, role);
      await prefs.setString(AdminConstants.keyAdminLastLogin, DateTime.now().toIso8601String());

      state = AdminSessionState(
        isAuthenticated: true,
        email: email.trim(),
        role: role,
        sessionToken: token,
        lastLogin: DateTime.now().toIso8601String(),
      );

      // Record sign-in in audit log
      try {
        await _ref.read(auditLogsProvider.notifier).log(
          actorEmail: email.trim(),
          actorRole: role,
          action: 'ADMIN_SIGN_IN',
          resourceType: 'SESSION',
          resourceId: token,
          metadata: {'loginAt': DateTime.now().toIso8601String()},
        );
      } catch (_) {}

      return true;
    } catch (e) {
      debugPrint('[AdminSessionNotifier] login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final currentEmail = state.email;
    final currentRole = state.role;
    state = const AdminSessionState();
    try {
      final prefs = await PreferencesCache.instance;
      await prefs.remove(AdminConstants.keyAdminToken);
      await prefs.remove(AdminConstants.keyAdminEmail);
      await prefs.remove(AdminConstants.keyAdminRole);
      await _ref.read(authStateProvider.notifier).signOut();

      // Record logout in audit log
      try {
        await _ref.read(auditLogsProvider.notifier).log(
          actorEmail: currentEmail.isNotEmpty ? currentEmail : 'admin@puneexplorer.in',
          actorRole: currentRole.isNotEmpty ? currentRole : 'Super Admin',
          action: 'ADMIN_SIGN_OUT',
          resourceType: 'SESSION',
          resourceId: '-',
          metadata: {'logoutAt': DateTime.now().toIso8601String()},
        );
      } catch (_) {}
    } catch (_) {}
  }
}

final adminSessionProvider = StateNotifierProvider<AdminSessionNotifier, AdminSessionState>((ref) {
  return AdminSessionNotifier(ref);
});

// ── Coupon Management Providers ─────────────────────────────────────────────
final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  if (SupabaseConfig.isConfigured && SupabaseConfig.isInitialized) {
    return SupabaseCouponRepository();
  }
  return LocalCouponRepository();
});

class CouponsNotifier extends StateNotifier<AsyncValue<List<Coupon>>> {
  final CouponRepository _repo;

  CouponsNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadCoupons();
  }

  Future<void> loadCoupons() async {
    try {
      final list = await _repo.getCoupons();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCoupon(Coupon coupon) async {
    await _repo.addCoupon(coupon);
    await loadCoupons();
  }

  Future<void> updateCoupon(Coupon coupon) async {
    await _repo.updateCoupon(coupon);
    await loadCoupons();
  }

  Future<void> deleteCoupon(String code) async {
    await _repo.deleteCoupon(code);
    await loadCoupons();
  }

  Future<void> toggleStatus(String code) async {
    await _repo.toggleCouponStatus(code);
    await loadCoupons();
  }

  Future<void> toggleCouponStatus(String code, bool isActive) async {
    await _repo.toggleCouponStatus(code);
    await loadCoupons();
  }

  Future<void> saveCoupon(Coupon coupon) async {
    final list = state.value ?? [];
    if (list.any((c) => c.code == coupon.code)) {
      await updateCoupon(coupon);
    } else {
      await addCoupon(coupon);
    }
  }
}

final couponsProvider = StateNotifierProvider<CouponsNotifier, AsyncValue<List<Coupon>>>((ref) {
  final repo = ref.watch(couponRepositoryProvider);
  return CouponsNotifier(repo);
});

// ── Customer Support Providers ──────────────────────────────────────────────
final adminSupportRepositoryProvider = Provider<AdminSupportRepository>((ref) {
  if (SupabaseConfig.isConfigured && SupabaseConfig.isInitialized) {
    return SupabaseSupportRepository();
  }
  return LocalAdminSupportRepository();
});

class AdminSupportTicketsNotifier extends StateNotifier<AsyncValue<List<AdminSupportTicket>>> {
  final AdminSupportRepository _repo;

  AdminSupportTicketsNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadTickets();
  }

  Future<void> loadTickets() async {
    try {
      final list = await _repo.getTickets();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateStatus(String id, String status) async {
    await _repo.updateTicketStatus(id, status);
    await loadTickets();
  }

  Future<void> assignAdmin(String id, String adminEmail) async {
    await _repo.assignAdmin(id, adminEmail);
    await loadTickets();
  }

  Future<void> addMessage(String ticketId, SupportMessage message) async {
    await _repo.addMessage(ticketId, message);
    await loadTickets();
  }

  Future<void> addInternalNote(String ticketId, String note) async {
    await _repo.addInternalNote(ticketId, note);
    await loadTickets();
  }

  Future<void> saveTicket(AdminSupportTicket ticket) async {
    await _repo.saveTicket(ticket);
    await loadTickets();
  }
}

final adminSupportTicketsProvider =
    StateNotifierProvider<AdminSupportTicketsNotifier, AsyncValue<List<AdminSupportTicket>>>((ref) {
  final repo = ref.watch(adminSupportRepositoryProvider);
  return AdminSupportTicketsNotifier(repo);
});

// ── Refunds & Cancellations Providers ───────────────────────────────────────
final adminRefundRepositoryProvider = Provider<AdminRefundRepository>((ref) {
  if (SupabaseConfig.isConfigured && SupabaseConfig.isInitialized) {
    return SupabaseRefundRepository();
  }
  return LocalAdminRefundRepository();
});

class AdminRefundsNotifier extends StateNotifier<AsyncValue<List<AdminRefundRequest>>> {
  final AdminRefundRepository _repo;

  AdminRefundsNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadRefunds();
  }

  Future<void> loadRefunds() async {
    try {
      final list = await _repo.getRefundRequests();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateStatus(
    String id,
    String status, {
    String? notes,
    String? processedBy,
    double? cancellationFee,
  }) async {
    await _repo.updateRefundStatus(
      id,
      status,
      notes: notes,
      processedBy: processedBy,
      cancellationFee: cancellationFee,
    );
    await loadRefunds();
  }

  Future<void> approveRefund({
    required String refundId,
    required double cancellationFee,
    required String processedBy,
  }) async {
    await updateStatus(
      refundId,
      'approved',
      cancellationFee: cancellationFee,
      processedBy: processedBy,
    );
  }

  Future<void> rejectRefund({
    required String refundId,
    required String reason,
    required String processedBy,
  }) async {
    await updateStatus(
      refundId,
      'rejected',
      notes: reason,
      processedBy: processedBy,
    );
  }
}

final adminRefundsProvider =
    StateNotifierProvider<AdminRefundsNotifier, AsyncValue<List<AdminRefundRequest>>>((ref) {
  final repo = ref.watch(adminRefundRepositoryProvider);
  return AdminRefundsNotifier(repo);
});

// ── Admin Settings & Personalization Providers ──────────────────────────────
final adminSettingsRepositoryProvider = Provider<AdminSettingsRepository>((ref) {
  if (SupabaseConfig.isConfigured && SupabaseConfig.isInitialized) {
    return SupabaseSettingsRepository();
  }
  return LocalAdminSettingsRepository();
});

class AdminGlobalSettingsNotifier extends StateNotifier<AdminGlobalSettings> {
  final AdminSettingsRepository _repo;

  AdminGlobalSettingsNotifier(this._repo) : super(const AdminGlobalSettings()) {
    _load();
  }

  Future<void> _load() async {
    final settings = await _repo.getGlobalSettings();
    state = settings;
  }

  Future<void> update(AdminGlobalSettings settings) async {
    state = settings;
    await _repo.updateGlobalSettings(settings);
  }

  Future<void> updateSettings(AdminGlobalSettings settings) => update(settings);
}

final adminGlobalSettingsProvider =
    StateNotifierProvider<AdminGlobalSettingsNotifier, AdminGlobalSettings>((ref) {
  final repo = ref.watch(adminSettingsRepositoryProvider);
  return AdminGlobalSettingsNotifier(repo);
});

class AdminPersonalizationNotifier extends StateNotifier<AdminPersonalization> {
  final AdminSettingsRepository _repo;

  AdminPersonalizationNotifier(this._repo) : super(const AdminPersonalization()) {
    _load();
  }

  Future<void> _load() async {
    final pers = await _repo.getPersonalization();
    state = pers;
  }

  Future<void> update(AdminPersonalization pers) async {
    state = pers;
    await _repo.updatePersonalization(pers);
  }

  Future<void> updateSettings(AdminPersonalization pers) => update(pers);
}

final adminPersonalizationProvider =
    StateNotifierProvider<AdminPersonalizationNotifier, AdminPersonalization>((ref) {
  final repo = ref.watch(adminSettingsRepositoryProvider);
  return AdminPersonalizationNotifier(repo);
});


