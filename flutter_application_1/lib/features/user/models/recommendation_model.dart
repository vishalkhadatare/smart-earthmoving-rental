import '../../../features/home/models/equipment_model.dart';

/// Enum for project types
enum ProjectType {
  residential,
  commercial,
  industrial,
  infrastructure,
  mining,
  other;

  String get displayName {
    switch (this) {
      case ProjectType.residential:
        return 'Residential';
      case ProjectType.commercial:
        return 'Commercial';
      case ProjectType.industrial:
        return 'Industrial';
      case ProjectType.infrastructure:
        return 'Infrastructure';
      case ProjectType.mining:
        return 'Mining';
      case ProjectType.other:
        return 'Other';
    }
  }

  static ProjectType? fromString(String? value) {
    if (value == null) return null;
    return ProjectType.values.firstWhere(
      (e) => e.displayName.toLowerCase() == value.toLowerCase(),
      orElse: () => ProjectType.other,
    );
  }
}

/// Enum for soil types
enum SoilType {
  clayey,
  sandy,
  loamy,
  rocky,
  mixed,
  other;

  String get displayName {
    switch (this) {
      case SoilType.clayey:
        return 'Clayey';
      case SoilType.sandy:
        return 'Sandy';
      case SoilType.loamy:
        return 'Loamy';
      case SoilType.rocky:
        return 'Rocky';
      case SoilType.mixed:
        return 'Mixed';
      case SoilType.other:
        return 'Other';
    }
  }

  static SoilType? fromString(String? value) {
    if (value == null) return null;
    return SoilType.values.firstWhere(
      (e) => e.displayName.toLowerCase() == value.toLowerCase(),
      orElse: () => SoilType.other,
    );
  }
}

/// Model for recommendation filters
class RecommendationFilter {
  final ProjectType? projectType;
  final SoilType? soilType;
  final double diggingDepth; // in meters
  final double duration; // in days (user input)

  RecommendationFilter({
    this.projectType,
    this.soilType,
    this.diggingDepth = 3.0,
    this.duration = 1.0,
  });

  RecommendationFilter copyWith({
    ProjectType? projectType,
    SoilType? soilType,
    double? diggingDepth,
    double? duration,
  }) {
    return RecommendationFilter(
      projectType: projectType ?? this.projectType,
      soilType: soilType ?? this.soilType,
      diggingDepth: diggingDepth ?? this.diggingDepth,
      duration: duration ?? this.duration,
    );
  }
}

/// Model for a ranked recommendation result
class RecommendationResult {
  final EquipmentModel equipment;
  final double score; // Match score 0-100
  final String reason; // Why this equipment is recommended
  final bool isBestMatch;

  const RecommendationResult({
    required this.equipment,
    required this.score,
    this.reason = '',
    this.isBestMatch = false,
  });
}

/// Sorting options for recommendation results
enum RecommendationSort {
  bestMatch,
  price,
  rating,
  availability;

  String get displayName {
    switch (this) {
      case RecommendationSort.bestMatch:
        return 'Best Match';
      case RecommendationSort.price:
        return 'Price: Low to High';
      case RecommendationSort.rating:
        return 'Highest Rated';
      case RecommendationSort.availability:
        return 'Available First';
    }
  }
}

/// Filtering options for recommendation results
enum RecommendationFilter2 {
  available,
  highRating,
  affordable;

  String get displayName {
    switch (this) {
      case RecommendationFilter2.available:
        return 'Available';
      case RecommendationFilter2.highRating:
        return 'High Rating';
      case RecommendationFilter2.affordable:
        return 'Affordable';
    }
  }
}
