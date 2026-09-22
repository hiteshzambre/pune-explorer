import '../../core/enums/app_enums.dart';

class AttractionItem {
  final String name;
  final String description;
  final String distance;
  final String travelTime;
  final double rating;
  final String image;

  const AttractionItem({
    required this.name,
    required this.description,
    required this.distance,
    required this.travelTime,
    required this.rating,
    required this.image,
  });

  factory AttractionItem.fromJson(Map<String, dynamic> json) => AttractionItem(
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        distance: json['distance'] as String? ?? '',
        travelTime: json['travelTime'] as String? ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
        image: json['image'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'distance': distance,
        'travelTime': travelTime,
        'rating': rating,
        'image': image,
      };
}

class FoodSpot {
  final String name;
  final String description;
  final String price;
  final String category;
  final bool isVeg;
  final String image;

  const FoodSpot({
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.isVeg,
    required this.image,
  });

  factory FoodSpot.fromJson(Map<String, dynamic> json) => FoodSpot(
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        price: json['price'] as String? ?? '',
        category: json['category'] as String? ?? 'Snack',
        isVeg: json['isVeg'] as bool? ?? true,
        image: json['image'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'isVeg': isVeg,
        'image': image,
      };
}

class HotelItem {
  final String name;
  final String description;
  final double pricePerNight;
  final double rating;
  final List<String> amenities;
  final String distance;
  final String contact;
  final String image;

  const HotelItem({
    required this.name,
    required this.description,
    required this.pricePerNight,
    required this.rating,
    required this.amenities,
    required this.distance,
    required this.contact,
    required this.image,
  });

  factory HotelItem.fromJson(Map<String, dynamic> json) => HotelItem(
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        pricePerNight: (json['pricePerNight'] as num?)?.toDouble() ?? 2000,
        rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
        amenities: (json['amenities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        distance: json['distance'] as String? ?? '',
        contact: json['contact'] as String? ?? '',
        image: json['image'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'pricePerNight': pricePerNight,
        'rating': rating,
        'amenities': amenities,
        'distance': distance,
        'contact': contact,
        'image': image,
      };
}

class Destination {
  final String id;
  final String name;
  final String city;
  final String state; // Pune Region
  final DestinationCategory category;
  final String description;
  final String longDescription;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final double latitude;
  final double longitude;
  final double entryFeeIndian;
  final double entryFeeForeign;
  final String bestTime;
  final String openingHours;
  final String recommendedDuration;
  final String famousFor;
  final DifficultyLevel difficulty;
  final double distanceFromPuneKm;
  final bool isTrending;
  final bool isFeatured;
  final List<AttractionItem> attractions;
  final List<FoodSpot> foods;
  final List<HotelItem> hotels;
  final List<String> travelTips;

  const Destination({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.category,
    required this.description,
    required this.longDescription,
    required this.images,
    required this.rating,
    required this.reviewCount,
    required this.latitude,
    required this.longitude,
    required this.entryFeeIndian,
    required this.entryFeeForeign,
    required this.bestTime,
    required this.openingHours,
    required this.recommendedDuration,
    required this.famousFor,
    this.difficulty = DifficultyLevel.moderate,
    this.distanceFromPuneKm = 0.0,
    this.isTrending = false,
    this.isFeatured = false,
    this.attractions = const [],
    this.foods = const [],
    this.hotels = const [],
    this.travelTips = const [],
  });

  String get primaryImage =>
      images.isNotEmpty ? images.first : 'https://images.unsplash.com/photo-1599661046289-e31897846e41?q=80&w=600';

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String? ?? 'Pune',
      state: json['state'] as String? ?? 'Pune District',
      category: DestinationCategory.fromString(json['category'] as String?),
      description: json['description'] as String? ?? '',
      longDescription: json['longDescription'] as String? ?? json['description'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 100,
      latitude: ((json['coords'] as Map<String, dynamic>?)?['lat'] as num?)?.toDouble() ??
          (json['latitude'] as num?)?.toDouble() ??
          18.5204,
      longitude: ((json['coords'] as Map<String, dynamic>?)?['lng'] as num?)?.toDouble() ??
          (json['longitude'] as num?)?.toDouble() ??
          73.8567,
      entryFeeIndian: ((json['entryFee'] as Map<String, dynamic>?)?['indian'] as num?)?.toDouble() ??
          (json['entryFeeIndian'] as num?)?.toDouble() ??
          0.0,
      entryFeeForeign: ((json['entryFee'] as Map<String, dynamic>?)?['foreign'] as num?)?.toDouble() ??
          (json['entryFeeForeign'] as num?)?.toDouble() ??
          0.0,
      bestTime: json['bestTime'] as String? ?? 'All year round',
      openingHours: json['openingHours'] as String? ?? 'Open 24 hours',
      recommendedDuration: json['recommendedDuration'] as String? ?? '2-3 hours',
      famousFor: json['famousFor'] as String? ?? '',
      difficulty: json['difficulty'] != null
          ? DifficultyLevel.values.firstWhere(
              (d) => d.name == json['difficulty'],
              orElse: () => DifficultyLevel.moderate,
            )
          : DifficultyLevel.moderate,
      distanceFromPuneKm: (json['distanceFromPuneKm'] as num?)?.toDouble() ?? 15.0,
      isTrending: json['trending'] as bool? ?? json['isTrending'] as bool? ?? false,
      isFeatured: json['featured'] as bool? ?? json['isFeatured'] as bool? ?? false,
      attractions: (json['attractions'] as List<dynamic>?)
              ?.map((e) => AttractionItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      foods: (json['foods'] as List<dynamic>?)
              ?.map((e) => FoodSpot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hotels: (json['hotels'] as List<dynamic>?)
              ?.map((e) => HotelItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      travelTips: (json['travelTips'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'city': city,
        'state': state,
        'category': category.name,
        'description': description,
        'longDescription': longDescription,
        'images': images,
        'rating': rating,
        'reviewCount': reviewCount,
        'latitude': latitude,
        'longitude': longitude,
        'entryFeeIndian': entryFeeIndian,
        'entryFeeForeign': entryFeeForeign,
        'bestTime': bestTime,
        'openingHours': openingHours,
        'recommendedDuration': recommendedDuration,
        'famousFor': famousFor,
        'difficulty': difficulty.name,
        'distanceFromPuneKm': distanceFromPuneKm,
        'isTrending': isTrending,
        'isFeatured': isFeatured,
        'attractions': attractions.map((e) => e.toJson()).toList(),
        'foods': foods.map((e) => e.toJson()).toList(),
        'hotels': hotels.map((e) => e.toJson()).toList(),
        'travelTips': travelTips,
      };
}
