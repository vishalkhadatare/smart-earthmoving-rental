import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/home/models/equipment_model.dart';
import '../../../models/firestore_equipment_model.dart';
import '../models/recommendation_model.dart';

/// Service to calculate and rank equipment recommendations.
///
/// Fetches equipment from Firestore and uses the values entered by the user
/// (project type, soil type, digging depth, duration) to compute scores and
/// rank the equipment.
class RecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Convert FirestoreEquipmentModel to EquipmentModel for consistency
  EquipmentModel _convertToEquipmentModel(FirestoreEquipmentModel fsModel) {
    final provider = EquipmentProviderInfo(
      id: fsModel.providerId,
      name: fsModel.providerName,
      phone: fsModel.ownerPhone,
      rating: 4.5, // Default rating if not available
      location: fsModel.district,
    );

    return EquipmentModel(
      id: fsModel.id,
      name: '${fsModel.brand} ${fsModel.model}',
      model: fsModel.model,
      imageAsset: fsModel.machineImages.isNotEmpty
          ? fsModel.machineImages.first
          : 'assets/images/equipment_placeholder.png',
      pricePerHour: fsModel.hourlyRate,
      category: fsModel.machineType.value,
      provider: provider,
      isAvailable: fsModel.availabilityStatus,
    );
  }

  /// Fetch all available equipment from Firestore
  Future<List<EquipmentModel>> _fetchEquipmentFromFirestore() async {
    try {
      debugPrint('[Recommendation] Fetching equipment from Firestore...');
      final snapshot = await _firestore
          .collection('equipment')
          .where('availabilityStatus', isEqualTo: true)
          .get();

      debugPrint(
        '[Recommendation] Found ${snapshot.docs.length} available items',
      );
      final equipment = snapshot.docs
          .map((doc) => FirestoreEquipmentModel.fromDocument(doc))
          .map(_convertToEquipmentModel)
          .toList();
      return equipment;
    } catch (e) {
      debugPrint('[Recommendation] Error fetching equipment: $e');
      return [];
    }
  }

  /// Get top N recommendations based on user filter values and Firestore equipment
  Future<List<RecommendationResult>> getRecommendations(
    RecommendationFilter filter, {
    int topN = 5,
  }) async {
    debugPrint('[Recommendation] getRecommendations()');
    debugPrint(
      '   Filter: projectType=${filter.projectType}, depth=${filter.diggingDepth}m, duration=${filter.duration}d',
    );

    final equipment = await _fetchEquipmentFromFirestore();
    debugPrint('   Equipment catalogue size: ${equipment.length}');

    if (equipment.isEmpty) {
      debugPrint('[Recommendation] No equipment available');
      return [];
    }

    final scored = equipment.map((equipmentItem) {
      final score = _calculateScore(equipmentItem, filter);
      return RecommendationResult(
        equipment: equipmentItem,
        score: score,
        reason: _getRecommendationReason(equipmentItem, filter),
        isBestMatch: false,
      );
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));
    if (scored.isNotEmpty) {
      scored[0] = RecommendationResult(
        equipment: scored[0].equipment,
        score: scored[0].score,
        reason: scored[0].reason,
        isBestMatch: true,
      );
    }

    final results = scored.take(topN).toList();
    debugPrint('[Recommendation] Returning ${results.length} recommendations');
    return results;
  }

  /// Calculate recommendation score for an equipment (0-100) using user inputs
  double _calculateScore(
    EquipmentModel equipment,
    RecommendationFilter filter,
  ) {
    double score = 50.0; // base

    // type/project match contributes up to 40 points
    score += _getTypeMatchScore(equipment, filter) * 40;

    // digging depth preference
    if (filter.diggingDepth <= 2) {
      if (equipment.name.toLowerCase().contains('mini') ||
          equipment.category.toLowerCase().contains('loader')) {
        score += 20;
      }
    } else if (filter.diggingDepth <= 5) {
      if (equipment.category.toLowerCase().contains('excavator')) {
        score += 20;
      }
    } else {
      if (equipment.category.toLowerCase().contains('bulldozer') ||
          equipment.category.toLowerCase().contains('loader')) {
        score += 20;
      }
    }

    // soil type bonus
    if (filter.soilType != null) {
      score += _getSoilTypeBonus(equipment, filter.soilType!) * 10;
    }

    // duration: longer projects favour economical machines
    if (filter.duration >= 7) {
      if (equipment.pricePerHour <= 1800) {
        score += 20;
      }
    } else {
      score += 10;
    }

    return score.clamp(0, 100);
  }

  /// Get equipment type match score (0-1)
  double _getTypeMatchScore(
    EquipmentModel equipment,
    RecommendationFilter filter,
  ) {
    if (filter.projectType == null) return 0.5;
    final category = equipment.category.toLowerCase();
    final project = filter.projectType!;
    double matchScore = 0.5;

    switch (project) {
      case ProjectType.residential:
        if (category.contains('mini')) {
          matchScore = 0.9;
        } else if (category.contains('excavator')) {
          matchScore = 0.7;
        }
        break;
      case ProjectType.commercial:
        if (category.contains('excavator')) {
          matchScore = 0.9;
        } else if (category.contains('loader')) {
          matchScore = 0.8;
        }
        break;
      case ProjectType.industrial:
        if (category.contains('bulldozer') || category.contains('loader')) {
          matchScore = 0.9;
        }
        break;
      case ProjectType.infrastructure:
        if (category.contains('excavator') || category.contains('roller')) {
          matchScore = 0.9;
        }
        break;
      case ProjectType.mining:
        if (category.contains('bulldozer') || category.contains('loader')) {
          matchScore = 0.95;
        }
        break;
      case ProjectType.other:
        matchScore = 0.6;
        break;
    }
    return matchScore;
  }

  /// Get soil type compatibility bonus
  double _getSoilTypeBonus(EquipmentModel equipment, SoilType soilType) {
    final category = equipment.category.toLowerCase();

    switch (soilType) {
      case SoilType.clayey:
        if (category.contains('excavator') || category.contains('compactor')) {
          return 0.8;
        }
        return 0.3;

      case SoilType.sandy:
        if (category.contains('excavator') || category.contains('loader')) {
          return 0.8;
        } else if (category.contains('roller')) {
          return 0.9;
        }
        return 0.4;

      case SoilType.loamy:
        return 0.7;

      case SoilType.rocky:
        if (category.contains('excavator') || category.contains('loader')) {
          return 0.9;
        } else if (category.contains('crane')) {
          return 0.85;
        }
        return 0.3;

      case SoilType.mixed:
        if (category.contains('excavator')) {
          return 0.8;
        }
        return 0.6;

      case SoilType.other:
        return 0.5;
    }
  }

  /// Get personalized recommendation reason
  String _getRecommendationReason(
    EquipmentModel equipment,
    RecommendationFilter filter,
  ) {
    final reasons = <String>[];

    if (filter.projectType != null) {
      reasons.add('${filter.projectType!.displayName} project');
    }
    reasons.add('${filter.diggingDepth.toStringAsFixed(1)}m depth');
    reasons.add('Duration ${filter.duration.toStringAsFixed(0)}d');

    return reasons.take(2).join(' · ');
  }

  /// Sort recommendations
  List<RecommendationResult> sortRecommendations(
    List<RecommendationResult> results,
    RecommendationSort sortBy,
  ) {
    final sorted = List<RecommendationResult>.from(results);

    switch (sortBy) {
      case RecommendationSort.bestMatch:
        sorted.sort((a, b) => b.score.compareTo(a.score));
        break;
      case RecommendationSort.price:
        sorted.sort(
          (a, b) =>
              a.equipment.pricePerHour.compareTo(b.equipment.pricePerHour),
        );
        break;
      case RecommendationSort.rating:
        sorted.sort((a, b) => b.equipment.rating.compareTo(a.equipment.rating));
        break;
      case RecommendationSort.availability:
        sorted.sort((a, b) {
          if (a.equipment.isAvailable == b.equipment.isAvailable) {
            return b.score.compareTo(a.score);
          }
          return a.equipment.isAvailable ? -1 : 1;
        });
        break;
    }

    return sorted;
  }

  /// Filter recommendations
  List<RecommendationResult> filterRecommendations(
    List<RecommendationResult> results,
    Set<RecommendationFilter2> activeFilters,
  ) {
    return results.where((result) {
      for (final filter in activeFilters) {
        switch (filter) {
          case RecommendationFilter2.available:
            if (!result.equipment.isAvailable) return false;
            break;
          case RecommendationFilter2.highRating:
            if (result.equipment.rating < 4.0) return false;
            break;
          case RecommendationFilter2.affordable:
            if (result.equipment.pricePerHour > 2000) return false;
            break;
        }
      }
      return true;
    }).toList();
  }
}

/// Provider for recommendation service
final recommendationServiceProvider = Provider((ref) {
  return RecommendationService();
});

/// Provider for storing current recommendation filters
final recommendationFilterProvider = StateProvider((ref) {
  return RecommendationFilter();
});

/// Provider for storing current recommendations
final recommendationsProvider = StateProvider<List<RecommendationResult>>((
  ref,
) {
  return [];
});

/// Provider for storing current sort option
final recommendationSortProvider = StateProvider((ref) {
  return RecommendationSort.bestMatch;
});

/// Provider for storing active filter options
final recommendationActiveFiltersProvider =
    StateProvider<Set<RecommendationFilter2>>((ref) {
      return {};
    });
