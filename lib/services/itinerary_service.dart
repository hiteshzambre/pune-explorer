import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../data/models/itinerary_model.dart';
import '../data/models/destination.dart';

class ItineraryService {
  static const _keyItineraries = 'pune_user_itineraries';
  static const _uuid = Uuid();

  static final List<ItineraryPlan> _defaultPlans = [
    const ItineraryPlan(
      id: 'plan_monsoon_weekend',
      title: 'Monsoon Forts & Waterfalls Trail',
      description: '2-Day weekend circuit covering Sinhagad Fort, Katraj Ghat, and Tamhini waterfalls.',
      startDate: '2026-09-05',
      totalDays: 2,
      days: [
        ItineraryDay(
          dayNumber: 1,
          title: 'Day 1: Historic Forts & Puneri Flavors',
          stops: [
            ItineraryStop(
              id: 'stop_1',
              destinationId: 'dest_sinhagad',
              name: 'Sinhagad Fort Trek & Kanda Bhaji',
              timeSlot: 'Morning (06:30 AM - 10:30 AM)',
              categoryIcon: '🏛️',
              notes: 'Start early for sunrise above the clouds. Enjoy authentic Matka Dahi.',
            ),
            ItineraryStop(
              id: 'stop_2',
              destinationId: 'dest_dagdusheth',
              name: 'Dagdusheth Ganpati Temple Darshan',
              timeSlot: 'Afternoon (01:00 PM - 02:30 PM)',
              categoryIcon: '🛕',
              notes: 'VIP Pass through Pune Darshan counter.',
            ),
            ItineraryStop(
              id: 'stop_3',
              destinationId: 'dest_shaniwar_wada',
              name: 'Shaniwar Wada Palace & Sound-Light Show',
              timeSlot: 'Evening (05:00 PM - 07:00 PM)',
              categoryIcon: '🏛️',
              notes: 'Explore Dilli Darwaza and court fountain grounds.',
            ),
          ],
        ),
        ItineraryDay(
          dayNumber: 2,
          title: 'Day 2: Scenic Waterfalls & Lake Sunset',
          stops: [
            ItineraryStop(
              id: 'stop_4',
              destinationId: 'dest_tamhini',
              name: 'Tamhini Ghat Valley & Waterfalls',
              timeSlot: 'Morning (08:00 AM - 12:00 PM)',
              categoryIcon: '🌊',
              notes: 'Drive through misty mountain passes with roadside waterfall stops.',
            ),
            ItineraryStop(
              id: 'stop_5',
              destinationId: 'dest_pawna',
              name: 'Pawna Lake Waterfront & Campfire',
              timeSlot: 'Evening (04:00 PM - 08:00 PM)',
              categoryIcon: '🏕️',
              notes: 'Sunset boating and lakeview tea.',
            ),
          ],
        ),
      ],
      createdAt: '2026-08-28T10:00:00Z',
    ),
  ];

  static Future<List<ItineraryPlan>> getItineraries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyItineraries);
      if (raw != null) {
        final List<dynamic> list = jsonDecode(raw);
        return list.map((e) => ItineraryPlan.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return List.from(_defaultPlans);
  }

  static Future<void> saveItinerary(ItineraryPlan plan) async {
    try {
      final plans = await getItineraries();
      final index = plans.indexWhere((p) => p.id == plan.id);
      if (index >= 0) {
        plans[index] = plan;
      } else {
        plans.insert(0, plan);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyItineraries, jsonEncode(plans.map((p) => p.toJson()).toList()));
    } catch (_) {}
  }

  static Future<void> deleteItinerary(String id) async {
    try {
      final plans = await getItineraries();
      plans.removeWhere((p) => p.id == id);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyItineraries, jsonEncode(plans.map((p) => p.toJson()).toList()));
    } catch (_) {}
  }

  static ItineraryPlan createNewPlan({
    required String title,
    required String description,
    required String startDate,
    int totalDays = 2,
    List<Destination>? initialDestinations,
  }) {
    final planId = 'plan_${_uuid.v4().substring(0, 8)}';
    final List<ItineraryDay> days = [];

    for (int i = 1; i <= totalDays; i++) {
      days.add(ItineraryDay(
        dayNumber: i,
        title: 'Day $i: Explore & Discover',
        stops: [],
      ));
    }

    if (initialDestinations != null && initialDestinations.isNotEmpty && days.isNotEmpty) {
      for (int i = 0; i < initialDestinations.length; i++) {
        final dayIndex = i % totalDays;
        final dest = initialDestinations[i];
        final stop = ItineraryStop(
          id: 'stop_${_uuid.v4().substring(0, 6)}',
          destinationId: dest.id,
          name: dest.name,
          categoryIcon: dest.category.icon,
          timeSlot: i % 2 == 0 ? 'Morning (09:00 AM)' : 'Afternoon (02:00 PM)',
          notes: 'Recommended duration: ${dest.recommendedDuration}',
        );
        final currentStops = List<ItineraryStop>.from(days[dayIndex].stops)..add(stop);
        days[dayIndex] = days[dayIndex].copyWith(stops: currentStops);
      }
    }

    return ItineraryPlan(
      id: planId,
      title: title,
      description: description,
      startDate: startDate,
      totalDays: totalDays,
      days: days,
      createdAt: DateTime.now().toIso8601String(),
    );
  }
}
