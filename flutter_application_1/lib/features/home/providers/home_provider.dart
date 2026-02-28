import 'package:flutter/material.dart';
import '../../../data/models/equipment_model.dart';
import '../../../data/dummy_data.dart';

/// Provider for managing home screen state
class HomeProvider extends ChangeNotifier {
  List<Equipment> _allEquipment = DummyData.equipmentList;
  List<Equipment> _filteredEquipment = DummyData.equipmentList;
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  String _searchQuery = '';
  bool _isLoading = false;

  // Getters
  List<Equipment> get allEquipment => _allEquipment;
  List<Equipment> get filteredEquipment => _filteredEquipment;
  String get selectedCategory => _selectedCategory;
  String get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  /// Initialize with dummy data
  HomeProvider() {
    _loadEquipment();
  }

  /// Load equipment from dummy data
  void _loadEquipment() {
    _isLoading = true;
    notifyListeners();

    /// Simulate network delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _allEquipment = DummyData.equipmentList;
      _filteredEquipment = _allEquipment;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Update search query and filter
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Update selected category
  void updateCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  /// Update selected status
  void updateStatus(String status) {
    _selectedStatus = status;
    _applyFilters();
  }

  /// Apply all filters
  void _applyFilters() {
    _filteredEquipment = _allEquipment.where((equipment) {
      // Category filter
      if (_selectedCategory != 'All' &&
          equipment.category != _selectedCategory) {
        return false;
      }

      // Status filter
      if (_selectedStatus != 'All' &&
          equipment.status.displayName != _selectedStatus) {
        return false;
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        return equipment.name.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            equipment.company.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
      }

      return true;
    }).toList();

    notifyListeners();
  }

  /// Reset all filters
  void resetFilters() {
    _selectedCategory = 'All';
    _selectedStatus = 'All';
    _searchQuery = '';
    _filteredEquipment = _allEquipment;
    notifyListeners();
  }
}
