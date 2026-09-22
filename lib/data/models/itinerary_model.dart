class ItineraryStop {
  final String id;
  final String destinationId;
  final String name;
  final String timeSlot;
  final String categoryIcon;
  final String notes;
  final bool isCompleted;

  const ItineraryStop({
    required this.id,
    required this.destinationId,
    required this.name,
    this.timeSlot = 'Morning (09:00 AM)',
    this.categoryIcon = '📍',
    this.notes = '',
    this.isCompleted = false,
  });

  ItineraryStop copyWith({
    String? id,
    String? destinationId,
    String? name,
    String? timeSlot,
    String? categoryIcon,
    String? notes,
    bool? isCompleted,
  }) {
    return ItineraryStop(
      id: id ?? this.id,
      destinationId: destinationId ?? this.destinationId,
      name: name ?? this.name,
      timeSlot: timeSlot ?? this.timeSlot,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'destinationId': destinationId,
        'name': name,
        'timeSlot': timeSlot,
        'categoryIcon': categoryIcon,
        'notes': notes,
        'isCompleted': isCompleted,
      };

  factory ItineraryStop.fromJson(Map<String, dynamic> json) => ItineraryStop(
        id: json['id'] as String,
        destinationId: json['destinationId'] as String,
        name: json['name'] as String,
        timeSlot: json['timeSlot'] as String? ?? 'Morning (09:00 AM)',
        categoryIcon: json['categoryIcon'] as String? ?? '📍',
        notes: json['notes'] as String? ?? '',
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}

class ItineraryDay {
  final int dayNumber;
  final String title;
  final List<ItineraryStop> stops;

  const ItineraryDay({
    required this.dayNumber,
    required this.title,
    this.stops = const [],
  });

  ItineraryDay copyWith({
    int? dayNumber,
    String? title,
    List<ItineraryStop>? stops,
  }) {
    return ItineraryDay(
      dayNumber: dayNumber ?? this.dayNumber,
      title: title ?? this.title,
      stops: stops ?? this.stops,
    );
  }

  Map<String, dynamic> toJson() => {
        'dayNumber': dayNumber,
        'title': title,
        'stops': stops.map((s) => s.toJson()).toList(),
      };

  factory ItineraryDay.fromJson(Map<String, dynamic> json) => ItineraryDay(
        dayNumber: (json['dayNumber'] as num).toInt(),
        title: json['title'] as String,
        stops: (json['stops'] as List<dynamic>?)
                ?.map((s) => ItineraryStop.fromJson(s as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

class ItineraryPlan {
  final String id;
  final String title;
  final String description;
  final String startDate;
  final int totalDays;
  final List<ItineraryDay> days;
  final List<String> checklist;
  final String createdAt;

  const ItineraryPlan({
    required this.id,
    required this.title,
    this.description = '',
    required this.startDate,
    this.totalDays = 2,
    this.days = const [],
    this.checklist = const [
      'Carry valid Gov ID proof',
      'Refillable water bottle & energy bars',
      'Comfortable trekking shoes & rain cover',
      'Camera / Smartphone power bank',
    ],
    required this.createdAt,
  });

  ItineraryPlan copyWith({
    String? id,
    String? title,
    String? description,
    String? startDate,
    int? totalDays,
    List<ItineraryDay>? days,
    List<String>? checklist,
    String? createdAt,
  }) {
    return ItineraryPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      totalDays: totalDays ?? this.totalDays,
      days: days ?? this.days,
      checklist: checklist ?? this.checklist,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'startDate': startDate,
        'totalDays': totalDays,
        'days': days.map((d) => d.toJson()).toList(),
        'checklist': checklist,
        'createdAt': createdAt,
      };

  factory ItineraryPlan.fromJson(Map<String, dynamic> json) => ItineraryPlan(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        startDate: json['startDate'] as String,
        totalDays: (json['totalDays'] as num?)?.toInt() ?? 2,
        days: (json['days'] as List<dynamic>?)
                ?.map((d) => ItineraryDay.fromJson(d as Map<String, dynamic>))
                .toList() ??
            const [],
        checklist: (json['checklist'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        createdAt: json['createdAt'] as String,
      );
}
