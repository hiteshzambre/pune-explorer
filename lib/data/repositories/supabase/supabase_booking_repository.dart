import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/booking.dart';
import '../../../core/enums/app_enums.dart';
import '../booking_repository.dart';
import '../../../core/supabase/supabase_config.dart';

class SupabaseBookingRepository implements BookingRepository {
  final SupabaseClient? _client;
  final LocalBookingRepository _fallback = LocalBookingRepository();

  SupabaseBookingRepository([SupabaseClient? client])
      : _client = client ?? SupabaseConfig.client;

  SupabaseClient get client {
    final c = _client ?? SupabaseConfig.client;
    if (c == null) throw StateError('Supabase is not initialized.');
    return c;
  }

  @override
  Future<List<Booking>> getBookings() async {
    try {
      final user = client.auth.currentUser;
      var query = client.from(SupabaseConfig.tableBookings).select();

      // If regular user, filter by user_id
      if (user != null) {
        // Check if admin to decide whether to fetch all or only user bookings
        final isAdminRes = await client.rpc('is_admin', params: {'p_user_id': user.id});
        if (isAdminRes != true) {
          query = query.eq('user_id', user.id);
        }
      }

      final res = await query.order('created_at', ascending: false);
      final list = res as List<dynamic>;

      if (list.isEmpty) return await _fallback.getBookings();

      return list.map((item) {
        final statusStr = item['status'] as String? ?? 'pending';
        final status = BookingStatus.values.firstWhere(
          (s) => s.name.toLowerCase() == statusStr.toLowerCase(),
          orElse: () => BookingStatus.pending,
        );

        return Booking(
          id: item['id'] as String,
          tourId: item['tour_id'] as String? ?? 'pune-darshan',
          tourTitle: item['notes'] != null && (item['notes'] as String).isNotEmpty
              ? item['notes'] as String
              : 'PuneExplorer Tour',
          travelDate: item['travel_date']?.toString() ?? 'Upcoming',
          pickupPoint: item['boarding_point'] as String? ?? 'Swargate',
          passengers: const [],
          selectedSeats: const [],
          basePrice: (item['total_amount'] as num?)?.toDouble() ?? 500.0,
          seatExtraPrice: 0.0,
          discountAmount: (item['discount_amount'] as num?)?.toDouble() ?? 0.0,
          appliedCoupon: null,
          gstAmount: 0.0,
          platformFee: 0.0,
          totalAmount: (item['final_amount'] as num?)?.toDouble() ?? 500.0,
          status: status,
          createdAt: item['created_at']?.toString() ?? DateTime.now().toIso8601String(),
          customerName: 'Traveler',
          customerEmail: '',
          customerPhone: '',
          verificationHash: item['booking_code'] as String? ?? 'PE',
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseBookingRepository] getBookings error: $e. Falling back.');
      return await _fallback.getBookings();
    }
  }

  @override
  Future<Booking?> getBookingById(String id) async {
    try {
      final res = await client
          .from(SupabaseConfig.tableBookings)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (res == null) return await _fallback.getBookingById(id);

      final statusStr = res['status'] as String? ?? 'pending';
      final status = BookingStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == statusStr.toLowerCase(),
        orElse: () => BookingStatus.pending,
      );

      return Booking(
        id: res['id'] as String,
        tourId: res['tour_id'] as String? ?? 'pune-darshan',
        tourTitle: res['notes'] != null && (res['notes'] as String).isNotEmpty
            ? res['notes'] as String
            : 'PuneExplorer Tour',
        travelDate: res['travel_date']?.toString() ?? 'Upcoming',
        pickupPoint: res['boarding_point'] as String? ?? 'Swargate',
        passengers: const [],
        selectedSeats: const [],
        basePrice: (res['total_amount'] as num?)?.toDouble() ?? 500.0,
        seatExtraPrice: 0.0,
        discountAmount: (res['discount_amount'] as num?)?.toDouble() ?? 0.0,
        appliedCoupon: null,
        gstAmount: 0.0,
        platformFee: 0.0,
        totalAmount: (res['final_amount'] as num?)?.toDouble() ?? 500.0,
        status: status,
        createdAt: res['created_at']?.toString() ?? DateTime.now().toIso8601String(),
        customerName: 'Traveler',
        customerEmail: '',
        customerPhone: '',
        verificationHash: res['booking_code'] as String? ?? 'PE',
      );
    } catch (e) {
      debugPrint('[SupabaseBookingRepository] getBookingById error: $e');
      return _fallback.getBookingById(id);
    }
  }

  @override
  Future<void> saveBooking(Booking booking) async {
    try {
      final user = client.auth.currentUser;
      final userId = user?.id;

      if (userId == null) {
        // Fallback for unauthenticated/mock testing
        return await _fallback.saveBooking(booking);
      }

      await client.from(SupabaseConfig.tableBookings).upsert({
        'id': booking.id,
        'booking_code': booking.verificationHash.isNotEmpty
            ? booking.verificationHash
            : 'PE-${booking.id.hashCode.abs().toString().padLeft(6, '0')}',
        'user_id': userId,
        'tour_id': booking.tourId,
        'booking_type': 'tour',
        'travel_date': DateTime.tryParse(booking.travelDate)?.toIso8601String() ??
            DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'boarding_point': booking.pickupPoint,
        'total_travelers': booking.passengers.isNotEmpty ? booking.passengers.length : 1,
        'total_amount': booking.basePrice,
        'discount_amount': booking.discountAmount,
        'final_amount': booking.totalAmount,
        'status': booking.status.name,
        'payment_status': booking.status == BookingStatus.confirmed ? 'paid' : 'unpaid',
        'notes': booking.tourTitle,
      });

      // Insert passenger records
      if (booking.passengers.isNotEmpty) {
        final travelerRows = booking.passengers.map((p) => {
          'booking_id': booking.id,
          'full_name': p.fullName,
          'age': p.age,
          'gender': p.gender,
          'is_lead_traveler': p == booking.passengers.first,
        }).toList();

        await client.from(SupabaseConfig.tableBookingTravelers).insert(travelerRows);
      }
    } catch (e) {
      debugPrint('[SupabaseBookingRepository] saveBooking error: $e. Saving to local fallback.');
      await _fallback.saveBooking(booking);
    }
  }

  @override
  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      await client
          .from(SupabaseConfig.tableBookings)
          .update({'status': status.name})
          .eq('id', bookingId);
    } catch (e) {
      debugPrint('[SupabaseBookingRepository] updateBookingStatus error: $e');
      await _fallback.updateBookingStatus(bookingId, status);
    }
  }
}
