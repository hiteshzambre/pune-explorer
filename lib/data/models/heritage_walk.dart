import 'package:flutter/material.dart';

enum HeritageWalkCategory {
  royalWadas,
  craftsCulture,
  freedomTrail,
  reformers,
  sacred,
  culinary,
  colonial;

  String get label {
    switch (this) {
      case HeritageWalkCategory.royalWadas:
        return 'Royal Wadas';
      case HeritageWalkCategory.craftsCulture:
        return 'Crafts & Peths';
      case HeritageWalkCategory.freedomTrail:
        return 'Freedom Trail';
      case HeritageWalkCategory.reformers:
        return 'Social Reformers';
      case HeritageWalkCategory.sacred:
        return 'Sacred Trails';
      case HeritageWalkCategory.culinary:
        return 'Food & Culture';
      case HeritageWalkCategory.colonial:
        return 'Colonial Camp';
    }
  }

  String get marathiLabel {
    switch (this) {
      case HeritageWalkCategory.royalWadas:
        return 'ऐतिहासिक वाडे';
      case HeritageWalkCategory.craftsCulture:
        return 'हस्तकला व पेठा';
      case HeritageWalkCategory.freedomTrail:
        return 'स्वातंत्र्य लढा';
      case HeritageWalkCategory.reformers:
        return 'समाजसुधारक वारसा';
      case HeritageWalkCategory.sacred:
        return 'पवित्र मंदिरे';
      case HeritageWalkCategory.culinary:
        return 'पुणेरी खाद्यसंस्कृती';
      case HeritageWalkCategory.colonial:
        return 'ब्रिटिशकालीन पुणे';
    }
  }

  String get icon {
    switch (this) {
      case HeritageWalkCategory.royalWadas:
        return '🏰';
      case HeritageWalkCategory.craftsCulture:
        return '🔨';
      case HeritageWalkCategory.freedomTrail:
        return '🔥';
      case HeritageWalkCategory.reformers:
        return '💡';
      case HeritageWalkCategory.sacred:
        return '🪔';
      case HeritageWalkCategory.culinary:
        return '🍲';
      case HeritageWalkCategory.colonial:
        return '🏛️';
    }
  }

  Color get accentColor {
    switch (this) {
      case HeritageWalkCategory.royalWadas:
        return const Color(0xFFD97706); // Amber Gold
      case HeritageWalkCategory.craftsCulture:
        return const Color(0xFFB45309); // Copper Bronze
      case HeritageWalkCategory.freedomTrail:
        return const Color(0xFFDC2626); // Maratha Crimson
      case HeritageWalkCategory.reformers:
        return const Color(0xFF4F46E5); // Indigo
      case HeritageWalkCategory.sacred:
        return const Color(0xFFEA580C); // Saffron Orange
      case HeritageWalkCategory.culinary:
        return const Color(0xFF059669); // Emerald Green
      case HeritageWalkCategory.colonial:
        return const Color(0xFF0284C7); // Heritage Teal Blue
    }
  }
}

enum WalkDifficulty {
  easy,
  moderate,
  extended;

  String get label {
    switch (this) {
      case WalkDifficulty.easy:
        return 'Easy Stroll';
      case WalkDifficulty.moderate:
        return 'Moderate Walk';
      case WalkDifficulty.extended:
        return 'Extended Trail';
    }
  }

  String get paceDescription {
    switch (this) {
      case WalkDifficulty.easy:
        return 'Gentle flat walking with frequent shaded benches and easy terrain.';
      case WalkDifficulty.moderate:
        return 'Active walking through historic peth alleys and wada staircases.';
      case WalkDifficulty.extended:
        return 'Thorough multi-neighborhood exploration with moderate stamina required.';
    }
  }

  Color get color {
    switch (this) {
      case WalkDifficulty.easy:
        return const Color(0xFF10B981);
      case WalkDifficulty.moderate:
        return const Color(0xFFF59E0B);
      case WalkDifficulty.extended:
        return const Color(0xFFEF4444);
    }
  }
}

enum WalkTimeOfDay {
  morning,
  evening,
  anytime;

  String get label {
    switch (this) {
      case WalkTimeOfDay.morning:
        return 'Early Morning (6:30 – 9:30 AM)';
      case WalkTimeOfDay.evening:
        return 'Evening (4:30 – 7:30 PM)';
      case WalkTimeOfDay.anytime:
        return 'Flexible / Anytime';
    }
  }

  String get shortLabel {
    switch (this) {
      case WalkTimeOfDay.morning:
        return 'Morning 6:30-9:30 AM';
      case WalkTimeOfDay.evening:
        return 'Evening 4:30-7:30 PM';
      case WalkTimeOfDay.anytime:
        return 'Flexible Timing';
    }
  }
}

class HeritageWalkStop {
  final String id;
  final int stopNumber;
  final String name;
  final String marathiName;
  final double latitude;
  final double longitude;
  final String era;
  final int walkingDurationFromPreviousMinutes;
  final int recommendedTimeSpentMinutes;
  final String historicalStory;
  final List<String> keyFacts;
  final String photoUrl;
  final String audioNoteSummary;
  final String architecturalStyle;
  final String insiderTip;

  const HeritageWalkStop({
    required this.id,
    required this.stopNumber,
    required this.name,
    required this.marathiName,
    required this.latitude,
    required this.longitude,
    required this.era,
    this.walkingDurationFromPreviousMinutes = 5,
    this.recommendedTimeSpentMinutes = 15,
    required this.historicalStory,
    this.keyFacts = const [],
    required this.photoUrl,
    this.audioNoteSummary = '',
    this.architecturalStyle = '',
    this.insiderTip = '',
  });

  factory HeritageWalkStop.fromJson(Map<String, dynamic> json) {
    return HeritageWalkStop(
      id: json['id'] as String,
      stopNumber: json['stopNumber'] as int? ?? 1,
      name: json['name'] as String,
      marathiName: json['marathiName'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 18.5204,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 73.8567,
      era: json['era'] as String? ?? '',
      walkingDurationFromPreviousMinutes: json['walkingDurationFromPreviousMinutes'] as int? ?? 5,
      recommendedTimeSpentMinutes: json['recommendedTimeSpentMinutes'] as int? ?? 15,
      historicalStory: json['historicalStory'] as String? ?? '',
      keyFacts: (json['keyFacts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      photoUrl: json['photoUrl'] as String? ?? '',
      audioNoteSummary: json['audioNoteSummary'] as String? ?? '',
      architecturalStyle: json['architecturalStyle'] as String? ?? '',
      insiderTip: json['insiderTip'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'stopNumber': stopNumber,
        'name': name,
        'marathiName': marathiName,
        'latitude': latitude,
        'longitude': longitude,
        'era': era,
        'walkingDurationFromPreviousMinutes': walkingDurationFromPreviousMinutes,
        'recommendedTimeSpentMinutes': recommendedTimeSpentMinutes,
        'historicalStory': historicalStory,
        'keyFacts': keyFacts,
        'photoUrl': photoUrl,
        'audioNoteSummary': audioNoteSummary,
        'architecturalStyle': architecturalStyle,
        'insiderTip': insiderTip,
      };
}

class HeritageWalk {
  final String id;
  final String title;
  final String marathiTitle;
  final String subtitle;
  final HeritageWalkCategory category;
  final String coverImage;
  final List<String> galleryImages;
  final int durationMinutes;
  final double distanceKm;
  final WalkDifficulty difficulty;
  final String startLocationName;
  final String endLocationName;
  final double startLatitude;
  final double startLongitude;
  final double rating;
  final int reviewCount;
  final double price; // 0.0 for free self-guided, >0 for historian tour pass
  final bool isSelfGuided;
  final bool hasAudioGuide;
  final WalkTimeOfDay bestTimeOfDay;
  final String bestDays;
  final List<String> highlights;
  final List<String> included;
  final List<String> whatToBring;
  final List<String> culturalEtiquette;
  final List<String> localFoodPitstops;
  final String description;
  final String historicalContext;
  final List<HeritageWalkStop> stops;
  final String guideName;
  final String guideRole;
  final String guideAvatar;
  final bool isFeatured;

  const HeritageWalk({
    required this.id,
    required this.title,
    required this.marathiTitle,
    required this.subtitle,
    required this.category,
    required this.coverImage,
    this.galleryImages = const [],
    required this.durationMinutes,
    required this.distanceKm,
    this.difficulty = WalkDifficulty.moderate,
    required this.startLocationName,
    required this.endLocationName,
    required this.startLatitude,
    required this.startLongitude,
    this.rating = 4.9,
    this.reviewCount = 120,
    this.price = 0.0,
    this.isSelfGuided = true,
    this.hasAudioGuide = false,
    this.bestTimeOfDay = WalkTimeOfDay.morning,
    this.bestDays = 'Tuesday to Sunday (Avoid Monday wada closures)',
    this.highlights = const [],
    this.included = const [],
    this.whatToBring = const [],
    this.culturalEtiquette = const [],
    this.localFoodPitstops = const [],
    required this.description,
    required this.historicalContext,
    required this.stops,
    this.guideName = 'Dr. Mandar Lavate',
    this.guideRole = 'Senior Pune Heritage Historian & Author',
    this.guideAvatar = 'assets/images/guides/guide_mandar.jpg',
    this.isFeatured = false,
  });

  String get durationFormatted {
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    if (hours > 0 && mins > 0) return '$hours hr $mins min';
    if (hours > 0) return '$hours hr';
    return '$mins min';
  }

  int get stopsCount => stops.length;

  bool get isFree => price <= 0.0;

  factory HeritageWalk.fromJson(Map<String, dynamic> json) {
    return HeritageWalk(
      id: json['id'] as String,
      title: json['title'] as String,
      marathiTitle: json['marathiTitle'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      category: HeritageWalkCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => HeritageWalkCategory.royalWadas,
      ),
      coverImage: json['coverImage'] as String? ?? '',
      galleryImages: (json['galleryImages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      durationMinutes: json['durationMinutes'] as int? ?? 90,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 2.0,
      difficulty: WalkDifficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => WalkDifficulty.moderate,
      ),
      startLocationName: json['startLocationName'] as String? ?? '',
      endLocationName: json['endLocationName'] as String? ?? '',
      startLatitude: (json['startLatitude'] as num?)?.toDouble() ?? 18.5204,
      startLongitude: (json['startLongitude'] as num?)?.toDouble() ?? 73.8567,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      reviewCount: json['reviewCount'] as int? ?? 100,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      isSelfGuided: json['isSelfGuided'] as bool? ?? true,
      hasAudioGuide: json['hasAudioGuide'] as bool? ?? false,
      bestTimeOfDay: WalkTimeOfDay.values.firstWhere(
        (t) => t.name == json['bestTimeOfDay'],
        orElse: () => WalkTimeOfDay.morning,
      ),
      bestDays: json['bestDays'] as String? ?? 'Tuesday to Sunday',
      highlights: (json['highlights'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      included: (json['included'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      whatToBring: (json['whatToBring'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      culturalEtiquette: (json['culturalEtiquette'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      localFoodPitstops: (json['localFoodPitstops'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      description: json['description'] as String? ?? '',
      historicalContext: json['historicalContext'] as String? ?? '',
      stops: (json['stops'] as List<dynamic>?)
              ?.map((e) => HeritageWalkStop.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      guideName: json['guideName'] as String? ?? 'Dr. Mandar Lavate',
      guideRole: json['guideRole'] as String? ?? 'Pune Heritage Historian',
      guideAvatar: json['guideAvatar'] as String? ?? '',
      isFeatured: json['isFeatured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'marathiTitle': marathiTitle,
        'subtitle': subtitle,
        'category': category.name,
        'coverImage': coverImage,
        'galleryImages': galleryImages,
        'durationMinutes': durationMinutes,
        'distanceKm': distanceKm,
        'difficulty': difficulty.name,
        'startLocationName': startLocationName,
        'endLocationName': endLocationName,
        'startLatitude': startLatitude,
        'startLongitude': startLongitude,
        'rating': rating,
        'reviewCount': reviewCount,
        'price': price,
        'isSelfGuided': isSelfGuided,
        'hasAudioGuide': hasAudioGuide,
        'bestTimeOfDay': bestTimeOfDay.name,
        'bestDays': bestDays,
        'highlights': highlights,
        'included': included,
        'whatToBring': whatToBring,
        'culturalEtiquette': culturalEtiquette,
        'localFoodPitstops': localFoodPitstops,
        'description': description,
        'historicalContext': historicalContext,
        'stops': stops.map((s) => s.toJson()).toList(),
        'guideName': guideName,
        'guideRole': guideRole,
        'guideAvatar': guideAvatar,
        'isFeatured': isFeatured,
      };
}
