import 'package:flutter/material.dart';

/// Provider for managing bottom navigation state
class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  /// Update current navigation index
  void updateIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
