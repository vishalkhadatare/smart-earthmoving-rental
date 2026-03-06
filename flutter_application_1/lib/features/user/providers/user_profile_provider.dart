import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile_model.dart';

class UserProfileProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  UserProfileModel? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['uid'] = uid;
        _profile = UserProfileModel.fromMap(data);
      } else {
        // Create a minimal profile from Firebase Auth
        final user = FirebaseAuth.instance.currentUser!;
        _profile = UserProfileModel(
          uid: uid,
          fullName: user.displayName ?? '',
          email: user.email ?? '',
          mobileNumber: user.phoneNumber ?? '',
          photoUrl: user.photoURL,
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to load profile: $e';
      debugPrint(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile(UserProfileModel profile) async {
    _errorMessage = null;
    try {
      await _firestore
          .collection('users')
          .doc(profile.uid)
          .set(profile.toMap(), SetOptions(merge: true));
      _profile = profile;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Update failed: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }
  }
}
