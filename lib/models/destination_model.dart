class DestinationCategory {
  final int id;
  final String name;
  final String slug;
  final String icon;

  DestinationCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
  });

  factory DestinationCategory.fromJson(Map<String, dynamic> json) {
    return DestinationCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      icon: json['icon'] ?? '',
    );
  }
}

class FacilityModel {
  final int id;
  final String name;
  final String icon;
  final int destinationsCount;

  const FacilityModel({
    required this.id,
    required this.name,
    required this.icon,
    this.destinationsCount = 0,
  });

  factory FacilityModel.fromJson(Map<String, dynamic> json) {
    return FacilityModel(
      id: json['id'] is num
          ? (json['id'] as num).toInt()
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: (json['name'] ?? '').toString(),
      icon: (json['icon'] ?? '').toString(),
      destinationsCount: json['destinations_count'] is num
          ? (json['destinations_count'] as num).toInt()
          : 0,
    );
  }
}

class DestinationImage {
  final int id;
  final String imagePath;
  final String? imageUrl;

  DestinationImage({
    required this.id,
    required this.imagePath,
    this.imageUrl,
  });

  factory DestinationImage.fromJson(Map<String, dynamic> json) {
    return DestinationImage(
      id: json['id'] ?? 0,
      imagePath: json['image_path'] ?? '',
      imageUrl: json['image_url'],
    );
  }
}

class DestinationModel {
  final int id;
  final int categoryId;
  final String name;
  final String slug;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final int price;
  final String openingHours;
  final String? phone;
  final String? thumbnail;
  final String? thumbnailUrl;
  final double ratingAvg;
  final int ratingCount;
  final bool isPopular;
  final int reviewsCount;
  final DestinationCategory? category;
  final List<DestinationImage> images;
  final List<FacilityModel> facilities;

  DestinationModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.price,
    required this.openingHours,
    this.phone,
    this.thumbnail,
    this.thumbnailUrl,
    required this.ratingAvg,
    required this.ratingCount,
    required this.isPopular,
    required this.reviewsCount,
    this.category,
    required this.images,
    this.facilities = const [],
  });

  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    double parsedRating = 0.0;
    if (json['rating_avg'] != null) {
      if (json['rating_avg'] is num) {
        parsedRating = (json['rating_avg'] as num).toDouble();
      } else {
        parsedRating = double.tryParse(json['rating_avg'].toString()) ?? 0.0;
      }
    }

    int parsedPrice = 0;
    if (json['price'] != null) {
      if (json['price'] is num) {
        parsedPrice = (json['price'] as num).toInt();
      } else {
        parsedPrice = int.tryParse(json['price'].toString()) ?? 0;
      }
    }

    double parsedLat = 0.0;
    double parsedLng = 0.0;
    if (json['latitude'] != null) {
      parsedLat = (json['latitude'] is num)
          ? (json['latitude'] as num).toDouble()
          : double.tryParse(json['latitude'].toString()) ?? 0.0;
    }
    if (json['longitude'] != null) {
      parsedLng = (json['longitude'] is num)
          ? (json['longitude'] as num).toDouble()
          : double.tryParse(json['longitude'].toString()) ?? 0.0;
    }

    List<DestinationImage> imageList = [];
    if (json['images'] is List) {
      imageList = (json['images'] as List)
          .whereType<Map<String, dynamic>>()
          .map(DestinationImage.fromJson)
          .toList();
    }

    List<FacilityModel> facilityList = [];
    if (json['facilities'] is List) {
      facilityList = (json['facilities'] as List)
          .whereType<Map<String, dynamic>>()
          .map(FacilityModel.fromJson)
          .toList();
    }

    DestinationCategory? cat;
    if (json['category'] is Map<String, dynamic>) {
      cat = DestinationCategory.fromJson(json['category']);
    }

    return DestinationModel(
      id: json['id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      latitude: parsedLat,
      longitude: parsedLng,
      price: parsedPrice,
      openingHours: json['opening_hours'] ?? '08:00 - 17:00',
      phone: json['phone'],
      thumbnail: json['thumbnail'],
      thumbnailUrl: json['thumbnail_url'],
      ratingAvg: parsedRating,
      ratingCount: json['rating_count'] ?? 0,
      isPopular: json['is_popular'] == true || json['is_popular'] == 1,
      reviewsCount: json['reviews_count'] ?? 0,
      category: cat,
      images: imageList,
      facilities: facilityList,
    );
  }

  String get formattedPrice {
    if (price <= 0) {
      return 'Gratis';
    }
    final formatted = price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted / tiket';
  }
}

class PaginatedDestinationsResponse {
  final List<DestinationModel> destinations;
  final int currentPage;
  final int lastPage;
  final int total;

  const PaginatedDestinationsResponse({
    required this.destinations,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}
