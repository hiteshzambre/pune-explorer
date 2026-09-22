import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pune_explorer/core/supabase/supabase_config.dart';
import 'package:pune_explorer/core/providers/app_providers.dart';
import 'package:pune_explorer/data/repositories/auth_repository.dart';
import 'package:pune_explorer/data/repositories/destination_repository.dart';
import 'package:pune_explorer/data/repositories/booking_repository.dart';
import 'package:pune_explorer/data/repositories/supabase/supabase_auth_repository.dart';
import 'package:pune_explorer/data/repositories/supabase/supabase_destination_repository.dart';
import 'package:pune_explorer/data/repositories/supabase/supabase_booking_repository.dart';
import 'package:pune_explorer/data/repositories/supabase/supabase_payment_repository.dart';
import 'package:pune_explorer/data/repositories/supabase/supabase_cms_repository.dart';
import 'package:pune_explorer/data/repositories/supabase/supabase_coupon_repository.dart';
import 'package:pune_explorer/data/repositories/supabase/supabase_support_repository.dart';
import 'package:pune_explorer/data/repositories/supabase/supabase_refund_repository.dart';
import 'package:pune_explorer/data/repositories/supabase/supabase_media_repository.dart';
import 'package:pune_explorer/data/repositories/supabase/supabase_settings_repository.dart';
import 'package:pune_explorer/data/repositories/supabase/supabase_audit_repository.dart';

void main() {
  group('⚡ SupabaseConfig Unit Tests', () {
    test('Default environment flags fall back cleanly when dart-defines are empty', () {
      expect(SupabaseConfig.isInitialized, isFalse);
      expect(SupabaseConfig.client, isNull);
    });

    test('All database table constants match normalized production schema names', () {
      expect(SupabaseConfig.tableProfiles, 'profiles');
      expect(SupabaseConfig.tableRoles, 'roles');
      expect(SupabaseConfig.tablePermissions, 'permissions');
      expect(SupabaseConfig.tableUserRoles, 'user_roles');
      expect(SupabaseConfig.tableRolePermissions, 'role_permissions');
      expect(SupabaseConfig.tableCategories, 'categories');
      expect(SupabaseConfig.tableTags, 'tags');
      expect(SupabaseConfig.tableDestinations, 'destinations');
      expect(SupabaseConfig.tableDestinationImages, 'destination_images');
      expect(SupabaseConfig.tableDestinationHighlights, 'destination_highlights');
      expect(SupabaseConfig.tableDestinationFoodSpots, 'destination_food_spots');
      expect(SupabaseConfig.tableTours, 'tours');
      expect(SupabaseConfig.tableTourItinerary, 'tour_itinerary_items');
      expect(SupabaseConfig.tableTourBoardingPoints, 'tour_boarding_points');
      expect(SupabaseConfig.tableDarshanCircuits, 'darshan_circuits');
      expect(SupabaseConfig.tableDarshanStops, 'darshan_stops');
      expect(SupabaseConfig.tableHeritageWalks, 'heritage_walks');
      expect(SupabaseConfig.tableHeritageWalkStops, 'heritage_walk_stops');
      expect(SupabaseConfig.tableHeritageWalkGuides, 'heritage_walk_guides');
      expect(SupabaseConfig.tableBookings, 'bookings');
      expect(SupabaseConfig.tableBookingTravelers, 'booking_travelers');
      expect(SupabaseConfig.tableBookingSeats, 'booking_seats');
      expect(SupabaseConfig.tablePayments, 'payments');
      expect(SupabaseConfig.tableRefundRequests, 'refund_requests');
      expect(SupabaseConfig.tableCoupons, 'coupons');
      expect(SupabaseConfig.tableCouponRedemptions, 'coupon_redemptions');
      expect(SupabaseConfig.tableReviews, 'reviews');
      expect(SupabaseConfig.tableFaqs, 'faqs');
      expect(SupabaseConfig.tableNotifications, 'notifications');
      expect(SupabaseConfig.tableSupportTickets, 'support_tickets');
      expect(SupabaseConfig.tableSupportMessages, 'support_messages');
      expect(SupabaseConfig.tableHomepageSlides, 'homepage_slides');
      expect(SupabaseConfig.tableHomepageSections, 'homepage_sections');
      expect(SupabaseConfig.tableMediaAssets, 'media_assets');
      expect(SupabaseConfig.tableAppSettings, 'app_settings');
      expect(SupabaseConfig.tableAuditLogs, 'audit_logs');
    });

    test('All storage bucket constants are non-empty and kebab-case/lowercase', () {
      expect(SupabaseConfig.bucketDestinations, 'destinations');
      expect(SupabaseConfig.bucketTours, 'tours');
      expect(SupabaseConfig.bucketHeritageWalks, 'heritage-walks');
      expect(SupabaseConfig.bucketReceipts, 'receipts');
      expect(SupabaseConfig.bucketAvatars, 'avatars');
      expect(SupabaseConfig.bucketMediaLibrary, 'media-library');
      expect(SupabaseConfig.bucketBranding, 'branding');
    });

    test('mapError accurately parses PostgreSQL and Auth error messages into friendly descriptions', () {
      const authErr = AuthException('Invalid login credentials');
      expect(SupabaseConfig.mapError(authErr), 'Invalid login credentials');

      const uniqueErr = PostgrestException(message: 'duplicate key', code: '23505');
      expect(SupabaseConfig.mapError(uniqueErr), 'A record with this unique identifier already exists.');

      const rlsErr = PostgrestException(message: 'permission denied', code: '42501');
      expect(SupabaseConfig.mapError(rlsErr), 'Access denied. You do not have permission to perform this action.');

      const storageErr = StorageException('Upload failed');
      expect(SupabaseConfig.mapError(storageErr), 'File storage error: Upload failed');

      expect(SupabaseConfig.mapError('Generic error'), 'Generic error');
    });

    test('Riverpod providers resolve to fallback implementations when Supabase is not configured', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final authRepo = container.read(authRepositoryProvider);
      final destRepo = container.read(destinationRepositoryProvider);
      final bookingRepo = container.read(bookingRepositoryProvider);

      expect(authRepo, isA<LocalAuthRepository>());
      expect(destRepo, isA<LocalDestinationRepository>());
      expect(bookingRepo, isA<LocalBookingRepository>());
    });

    test('All 11 Supabase repository classes instantiate cleanly with null default client', () {
      expect(() => SupabaseAuthRepository(), returnsNormally);
      expect(() => SupabaseDestinationRepository(), returnsNormally);
      expect(() => SupabaseBookingRepository(), returnsNormally);
      expect(() => SupabasePaymentRepository(bookingRepository: LocalBookingRepository()), returnsNormally);
      expect(() => SupabaseCmsRepository(), returnsNormally);
      expect(() => SupabaseCouponRepository(), returnsNormally);
      expect(() => SupabaseSupportRepository(), returnsNormally);
      expect(() => SupabaseRefundRepository(), returnsNormally);
      expect(() => SupabaseMediaRepository(), returnsNormally);
      expect(() => SupabaseSettingsRepository(), returnsNormally);
      expect(() => SupabaseAuditRepository(), returnsNormally);
    });
  });
}
