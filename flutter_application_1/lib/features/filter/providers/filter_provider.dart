import 'package:flutter/material.dart';
import '../../../data/models/equipment_model.dart';
import '../../../data/dummy_data.dart';

/// Provider for managing filter state
class FilterProvider extends ChangeNotifier {
  EquipmentFilter _filter = EquipmentFilter();
  List<Equipment> _filteredResults = DummyData.equipmentList;

  // Getters
  EquipmentFilter get filter => _filter;
  List<Equipment> get filteredResults => _filteredResults;
  int get resultCount => _filteredResults.length;

  /// Update equipment type filter
  void updateEquipmentType(String? type) {
    _filter = _filter.copyWith(equipmentType: type);
    _applyFilters();
  }

  /// Update company filter
  void updateCompany(String? company) {
    _filter = _filter.copyWith(company: company);
    _applyFilters();
  }

  /// Update soil type filter
  void updateSoilType(String? soilType) {
    _filter = _filter.copyWith(soilType: soilType);
    _applyFilters();
  }

  /// Update location filter
  void updateLocation(String? location) {
    _filter = _filter.copyWith(location: location);
    _applyFilters();
  }

  /// Update price range
  void updatePriceRange(double? minPrice, double? maxPrice) {
    _filter = _filter.copyWith(minPrice: minPrice, maxPrice: maxPrice);
    _applyFilters();
  }

  /// Apply all filters
  void _applyFilters() {
    _filteredResults = DummyData.equipmentList.where((equipment) {
      if (_filter.equipmentType != null &&
          equipment.category != _filter.equipmentType) {
        return false;
      }

      if (_filter.company != null && equipment.company != _filter.company) {
        return false;
      }

      if (_filter.soilType != null &&
          !equipment.soilTypes.contains(_filter.soilType)) {
        return false;
      }

      if (_filter.location != null && equipment.location != _filter.location) {
        return false;
      }

      if (_filter.minPrice != null && equipment.priceHour < _filter.minPrice!) {
        return false;
      }

      if (_filter.maxPrice != null && equipment.priceHour > _filter.maxPrice!) {
        return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _filter = EquipmentFilter();
    _filteredResults = DummyData.equipmentList;
    notifyListeners();
  }
}
