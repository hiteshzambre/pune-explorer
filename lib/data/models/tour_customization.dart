class TourCustomization {
  final String transportMode;
  final double transportCostPerPerson;
  final String mealOption;
  final double mealCostPerPerson;
  final String accommodationTier;
  final double accommodationCostPerPerson;
  final int travelersCount;

  const TourCustomization({
    this.transportMode = 'AC Coach (Included)',
    this.transportCostPerPerson = 0.0,
    this.mealOption = 'Standard Maharashtrian Lunch (Included)',
    this.mealCostPerPerson = 0.0,
    this.accommodationTier = 'Day Trip (No Stay)',
    this.accommodationCostPerPerson = 0.0,
    this.travelersCount = 1,
  });

  double get totalAddOnPerPerson =>
      transportCostPerPerson + mealCostPerPerson + accommodationCostPerPerson;

  double get totalCustomizationCost => totalAddOnPerPerson * travelersCount;

  TourCustomization copyWith({
    String? transportMode,
    double? transportCostPerPerson,
    String? mealOption,
    double? mealCostPerPerson,
    String? accommodationTier,
    double? accommodationCostPerPerson,
    int? travelersCount,
  }) {
    return TourCustomization(
      transportMode: transportMode ?? this.transportMode,
      transportCostPerPerson: transportCostPerPerson ?? this.transportCostPerPerson,
      mealOption: mealOption ?? this.mealOption,
      mealCostPerPerson: mealCostPerPerson ?? this.mealCostPerPerson,
      accommodationTier: accommodationTier ?? this.accommodationTier,
      accommodationCostPerPerson: accommodationCostPerPerson ?? this.accommodationCostPerPerson,
      travelersCount: travelersCount ?? this.travelersCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'transportMode': transportMode,
        'transportCostPerPerson': transportCostPerPerson,
        'mealOption': mealOption,
        'mealCostPerPerson': mealCostPerPerson,
        'accommodationTier': accommodationTier,
        'accommodationCostPerPerson': accommodationCostPerPerson,
        'travelersCount': travelersCount,
      };

  factory TourCustomization.fromJson(Map<String, dynamic> json) => TourCustomization(
        transportMode: json['transportMode'] as String? ?? 'AC Coach (Included)',
        transportCostPerPerson: (json['transportCostPerPerson'] as num?)?.toDouble() ?? 0.0,
        mealOption: json['mealOption'] as String? ?? 'Standard Maharashtrian Lunch (Included)',
        mealCostPerPerson: (json['mealCostPerPerson'] as num?)?.toDouble() ?? 0.0,
        accommodationTier: json['accommodationTier'] as String? ?? 'Day Trip (No Stay)',
        accommodationCostPerPerson: (json['accommodationCostPerPerson'] as num?)?.toDouble() ?? 0.0,
        travelersCount: (json['travelersCount'] as num?)?.toInt() ?? 1,
      );
}
