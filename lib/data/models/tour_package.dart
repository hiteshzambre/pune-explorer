class TourItineraryItem {
  final String time;
  final String title;
  final String desc;

  const TourItineraryItem({
    required this.time,
    required this.title,
    required this.desc,
  });

  factory TourItineraryItem.fromJson(Map<String, dynamic> json) => TourItineraryItem(
        time: json['time'] as String? ?? '',
        title: json['title'] as String? ?? '',
        desc: json['desc'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'time': time, 'title': title, 'desc': desc};
}

class TourPackage {
  final String id;
  final String title;
  final String subtitle;
  final String destinationId;
  final String destinationName;
  final String duration;
  final double price;
  final double originalPrice;
  final double rating;
  final int reviewCount;
  final String badge;
  final String category;
  final List<String> images;
  final List<String> inclusions;
  final List<String> exclusions;
  final List<String> highlights;
  final List<TourItineraryItem> itinerary;
  final List<String> pickupPoints;
  final bool hasAccommodation;
  final double accommodationDiscount;

  const TourPackage({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.destinationId,
    required this.destinationName,
    required this.duration,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.badge,
    required this.category,
    required this.images,
    required this.inclusions,
    required this.exclusions,
    required this.highlights,
    required this.itinerary,
    required this.pickupPoints,
    this.hasAccommodation = false,
    this.accommodationDiscount = 0.0,
  });

  String get primaryImage =>
      images.isNotEmpty ? images.first : 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?q=80&w=600';

  factory TourPackage.fromJson(Map<String, dynamic> json) {
    return TourPackage(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      destinationId: json['destinationId'] as String? ?? '',
      destinationName: json['destinationName'] as String? ?? '',
      duration: json['duration'] as String? ?? '1 Day',
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? (json['price'] as num).toDouble() * 1.3,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 100,
      badge: json['badge'] as String? ?? 'Curated Tour',
      category: json['category'] as String? ?? 'Adventure',
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      inclusions: (json['inclusions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      exclusions: (json['exclusions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      highlights: (json['highlights'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      itinerary: (json['itinerary'] as List<dynamic>?)
              ?.map((e) => TourItineraryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pickupPoints: (json['pickupPoints'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          ['Swargate Bus Stand', 'Deccan Gymkhana', 'Pune Station'],
      hasAccommodation: json['hasAccommodation'] as bool? ?? false,
      accommodationDiscount: (json['accommodationDiscount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'destinationId': destinationId,
        'destinationName': destinationName,
        'duration': duration,
        'price': price,
        'originalPrice': originalPrice,
        'rating': rating,
        'reviewCount': reviewCount,
        'badge': badge,
        'category': category,
        'images': images,
        'inclusions': inclusions,
        'exclusions': exclusions,
        'highlights': highlights,
        'itinerary': itinerary.map((e) => e.toJson()).toList(),
        'pickupPoints': pickupPoints,
        'hasAccommodation': hasAccommodation,
        'accommodationDiscount': accommodationDiscount,
      };
}
