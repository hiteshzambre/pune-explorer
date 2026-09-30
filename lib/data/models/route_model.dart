class RouteWaypoint {
  final String name;
  final double lat;
  final double lng;
  final String description;

  const RouteWaypoint({
    required this.name,
    required this.lat,
    required this.lng,
    this.description = '',
  });

  factory RouteWaypoint.fromJson(Map<String, dynamic> json) => RouteWaypoint(
        name: json['name'] as String? ?? '',
        lat: (json['lat'] as num?)?.toDouble() ?? 18.5204,
        lng: (json['lng'] as num?)?.toDouble() ?? 73.8567,
        description: json['description'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'lat': lat,
        'lng': lng,
        'description': description,
      };
}

class RouteCircuit {
  final String id;
  final String title;
  final String subtitle;
  final String badge;
  final String icon;
  final RouteWaypoint from;
  final RouteWaypoint to;
  final List<RouteWaypoint> waypoints;
  final double distanceKm;
  final String durationFormatted;
  final String difficulty;
  final String bestTime;
  final List<String> highlights;
  final List<String> pitstops;

  const RouteCircuit({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.from,
    required this.to,
    this.waypoints = const [],
    required this.distanceKm,
    required this.durationFormatted,
    required this.difficulty,
    required this.bestTime,
    required this.highlights,
    required this.pitstops,
  });

  factory RouteCircuit.fromJson(Map<String, dynamic> json) {
    return RouteCircuit(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      badge: json['badge'] as String? ?? 'Scenic Trail',
      icon: json['icon'] as String? ?? '🚗',
      from: RouteWaypoint.fromJson(json['from'] as Map<String, dynamic>),
      to: RouteWaypoint.fromJson(json['to'] as Map<String, dynamic>),
      waypoints: (json['waypoints'] as List<dynamic>?)
              ?.map((e) => RouteWaypoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 45.0,
      durationFormatted: json['durationFormatted'] as String? ?? '2 hrs',
      difficulty: json['difficulty'] as String? ?? 'Moderate',
      bestTime: json['bestTime'] as String? ?? 'Monsoon & Winter',
      highlights: (json['highlights'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      pitstops: (json['pitstops'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'badge': badge,
        'icon': icon,
        'from': from.toJson(),
        'to': to.toJson(),
        'waypoints': waypoints.map((w) => w.toJson()).toList(),
        'distanceKm': distanceKm,
        'durationFormatted': durationFormatted,
        'difficulty': difficulty,
        'bestTime': bestTime,
        'highlights': highlights,
        'pitstops': pitstops,
      };

  RouteCircuit copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? badge,
    String? icon,
    RouteWaypoint? from,
    RouteWaypoint? to,
    List<RouteWaypoint>? waypoints,
    double? distanceKm,
    String? durationFormatted,
    String? difficulty,
    String? bestTime,
    List<String>? highlights,
    List<String>? pitstops,
  }) {
    return RouteCircuit(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      badge: badge ?? this.badge,
      icon: icon ?? this.icon,
      from: from ?? this.from,
      to: to ?? this.to,
      waypoints: waypoints ?? this.waypoints,
      distanceKm: distanceKm ?? this.distanceKm,
      durationFormatted: durationFormatted ?? this.durationFormatted,
      difficulty: difficulty ?? this.difficulty,
      bestTime: bestTime ?? this.bestTime,
      highlights: highlights ?? this.highlights,
      pitstops: pitstops ?? this.pitstops,
    );
  }
}


