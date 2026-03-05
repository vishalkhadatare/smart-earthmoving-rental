import 'package:flutter/foundation.dart';
import '../models/user_profile_model.dart';
import '../services/user_service.dart';

class UserProfileProvider extends ChangeNotifier {
  final UserService _service = UserService();

  UserProfileModel? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await _service.getCurrentProfile();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load profile: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile(UserProfileModel updated) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.updateProfile(updated);
      _profile = updated;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Update failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
