import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Central configuration for Supabase integration in PuneExplorer.
///
/// Values are supplied via compile-time environment variables:
/// `--dart-define=SUPABASE_URL=https://wvrndoguztgqmbqlkztr.supabase.co`
/// `--dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind2cm5kb2d1enRncW1icWxrenRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk1MjIyOTgsImV4cCI6MjEwNTA5ODI5OH0.ry_xePrPZKGek0x9DD-iZnTWyaB6Lf3n3gPNjbCaXGc`
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://wvrndoguztgqmbqlkztr.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind2cm5kb2d1enRncW1icWxrenRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk1MjIyOTgsImV4cCI6MjEwNTA5ODI5OH0.ry_xePrPZKGek0x9DD-iZnTWyaB6Lf3n3gPNjbCaXGc',
  );

  /// Returns true if valid Supabase credentials are provided.
  static bool get isConfigured {
    return url.trim().isNotEmpty &&
        anonKey.trim().isNotEmpty &&
        url.startsWith('http');
  }

  /// Returns true if Supabase has been initialized with an active client.
  static bool get isInitialized => client != null;

  /// Safe accessor for the initialized [SupabaseClient].
  /// Returns null if Supabase has not been initialized.
  static SupabaseClient? get client {
    if (!isConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Initialize Supabase if configuration is available.
  static Future<bool> initialize() async {
    if (!isConfigured) {
      debugPrint('[SupabaseConfig] Supabase credentials not found. Falling back to local/in-memory mode.');
      return false;
    }

    try {
      await Supabase.initialize(
        url: url,
        publishableKey: anonKey,
        debug: kDebugMode,
      );
      debugPrint('[SupabaseConfig] Supabase successfully initialized at $url');
      return true;
    } catch (e, st) {
      debugPrint('[SupabaseConfig] Initialization error: $e\n$st');
      return false;
    }
  }

  /// Standard storage bucket identifiers.
  static const String bucketDestinations = 'destinations';
  static const String bucketTours = 'tours';
  static const String bucketHeritageWalks = 'heritage-walks';
  static const String bucketReceipts = 'receipts';
  static const String bucketAvatars = 'avatars';
  static const String bucketMediaLibrary = 'media-library';
  static const String bucketBranding = 'branding';

  /// Standard database table identifiers.
  static const String tableProfiles = 'profiles';
  static const String tableRoles = 'roles';
  static const String tablePermissions = 'permissions';
  static const String tableUserRoles = 'user_roles';
  static const String tableRolePermissions = 'role_permissions';
  static const String tableCategories = 'categories';
  static const String tableTags = 'tags';
  static const String tableDestinations = 'destinations';
  static const String tableDestinationImages = 'destination_images';
  static const String tableDestinationHighlights = 'destination_highlights';
  static const String tableDestinationFoodSpots = 'destination_food_spots';
  static const String tableTours = 'tours';
  static const String tableTourItinerary = 'tour_itinerary_items';
  static const String tableTourBoardingPoints = 'tour_boarding_points';
  static const String tableDarshanCircuits = 'darshan_circuits';
  static const String tableDarshanStops = 'darshan_stops';
  static const String tableHeritageWalks = 'heritage_walks';
  static const String tableHeritageWalkStops = 'heritage_walk_stops';
  static const String tableHeritageWalkGuides = 'heritage_walk_guides';
  static const String tableBookings = 'bookings';
  static const String tableBookingTravelers = 'booking_travelers';
  static const String tableBookingSeats = 'booking_seats';
  static const String tablePayments = 'payments';
  static const String tableRefundRequests = 'refund_requests';
  static const String tableCoupons = 'coupons';
  static const String tableCouponRedemptions = 'coupon_redemptions';
  static const String tableReviews = 'reviews';
  static const String tableFaqs = 'faqs';
  static const String tableNotifications = 'notifications';
  static const String tableSupportTickets = 'support_tickets';
  static const String tableSupportMessages = 'support_messages';
  static const String tableHomepageSlides = 'homepage_slides';
  static const String tableHomepageSections = 'homepage_sections';
  static const String tableMediaAssets = 'media_assets';
  static const String tableAppSettings = 'app_settings';
  static const String tableAuditLogs = 'audit_logs';

  /// Maps Supabase/PostgREST/Auth exceptions to clear, user-friendly messages.
  static String mapError(dynamic error) {
    if (error is AuthException) {
      return error.message;
    }
    if (error is PostgrestException) {
      final code = error.code;
      final message = error.message;
      if (code == '23505') {
        return 'A record with this unique identifier already exists.';
      }
      if (code == '42501') {
        return 'Access denied. You do not have permission to perform this action.';
      }
      return message.isNotEmpty ? message : 'Database operation failed.';
    }
    if (error is StorageException) {
      return 'File storage error: ${error.message}';
    }
    return error?.toString() ?? 'An unexpected error occurred.';
  }
}
