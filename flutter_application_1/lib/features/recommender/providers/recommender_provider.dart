import 'package:flutter/material.dart';
import '../../../data/models/equipment_model.dart';
import '../../../data/dummy_data.dart';

/// Provider for managing recommender screen state
class RecommenderProvider extends ChangeNotifier {
  String? _selectedProject;
  String? _selectedSoilType;
  double _diggingDepth = 5.0;
  double _maxBudget = 2500.0;
  List<Equipment> _recommendations = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  // Getters
  String? get selectedProject => _selectedProject;
  String? get selectedSoilType => _selectedSoilType;
  double get diggingDepth => _diggingDepth;
  double get maxBudget => _maxBudget;
  List<Equipment> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  bool get hasSearched => _hasSearched;

  /// Update selected project type
  void updateProjectType(String? projectType) {
    _selectedProject = projectType;
    notifyListeners();
  }

  /// Update selected soil type
  void updateSoilType(String? soilType) {
    _selectedSoilType = soilType;
    notifyListeners();
  }

  /// Update digging depth
  void updateDiggingDepth(double depth) {
    _diggingDepth = depth;
    notifyListeners();
  }

  /// Update max budget
  void updateMaxBudget(double budget) {
    _maxBudget = budget;
    notifyListeners();
  }

  /// Get recommendations based on current filters
  Future<void> getRecommendations() async {
    _isLoading = true;
    notifyListeners();

    /// Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    _recommendations = DummyData.getRecommendations(
      soilType: _selectedSoilType,
      maxBudget: _maxBudget,
    );

    _isLoading = false;
    _hasSearched = true;
    notifyListeners();
  }

  /// Reset recommendations
  void resetRecommendations() {
    _selectedProject = null;
    _selectedSoilType = null;
    _diggingDepth = 5.0;
    _maxBudget = 2500.0;
    _recommendations = [];
    _hasSearched = false;
    notifyListeners();
  }
}
