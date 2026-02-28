/// Equipment status enum
enum EquipmentStatus {
  available,
  rented,
  maintenance;

  String get displayName {
    switch (this) {
      case EquipmentStatus.available:
        return 'Available';
      case EquipmentStatus.rented:
        return 'Rented';
      case EquipmentStatus.maintenance:
        return 'Under Maintenance';
    }
  }
}

/// Equipment model containing all product details
class Equipment {
  final String id;
  final String name;
  final String company;
  final String imageUrl;
  final String? secondaryImageUrl;
  final String location;
  final double rating;
  final int reviewCount;
  final double priceHour;
  final double priceDay;
  final double priceMonth;
  final EquipmentStatus status;
  final String category;
  final String description;
  final Map<String, String> specifications;
  final List<String> soilTypes;
  final bool isSaved;

  Equipment({
    required this.id,
    required this.name,
    required this.company,
    required this.imageUrl,
    this.secondaryImageUrl,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.priceHour,
    required this.priceDay,
    required this.priceMonth,
    required this.status,
    required this.category,
    required this.description,
    required this.specifications,
    required this.soilTypes,
    this.isSaved = false,
  });

  /// Create a copy of this equipment with modified fields
  Equipment copyWith({
    String? id,
    String? name,
    String? company,
    String? imageUrl,
    String? secondaryImageUrl,
    String? location,
    double? rating,
    int? reviewCount,
    double? priceHour,
    double? priceDay,
    double? priceMonth,
    EquipmentStatus? status,
    String? category,
    String? description,
    Map<String, String>? specifications,
    List<String>? soilTypes,
    bool? isSaved,
  }) {
    return Equipment(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      imageUrl: imageUrl ?? this.imageUrl,
      secondaryImageUrl: secondaryImageUrl ?? this.secondaryImageUrl,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      priceHour: priceHour ?? this.priceHour,
      priceDay: priceDay ?? this.priceDay,
      priceMonth: priceMonth ?? this.priceMonth,
      status: status ?? this.status,
      category: category ?? this.category,
      description: description ?? this.description,
      specifications: specifications ?? this.specifications,
      soilTypes: soilTypes ?? this.soilTypes,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

/// Filter model for equipment filtering
class EquipmentFilter {
  final String? equipmentType;
  final String? company;
  final String? soilType;
  final String? location;
  final double? minPrice;
  final double? maxPrice;
  final String? status;

  EquipmentFilter({
    this.equipmentType,
    this.company,
    this.soilType,
    this.location,
    this.minPrice,
    this.maxPrice,
    this.status,
  });

  /// Check if any filter is applied
  bool get isApplied =>
      equipmentType != null ||
      company != null ||
      soilType != null ||
      location != null ||
      minPrice != null ||
      maxPrice != null ||
      status != null;

  EquipmentFilter copyWith({
    String? equipmentType,
    String? company,
    String? soilType,
    String? location,
    double? minPrice,
    double? maxPrice,
    String? status,
  }) {
    return EquipmentFilter(
      equipmentType: equipmentType ?? this.equipmentType,
      company: company ?? this.company,
      soilType: soilType ?? this.soilType,
      location: location ?? this.location,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      status: status ?? this.status,
    );
  }
}
