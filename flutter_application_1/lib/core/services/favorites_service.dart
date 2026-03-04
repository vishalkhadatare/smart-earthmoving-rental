import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service to manage user favorites in Firestore
class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _favoritesRef {
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(uid).collection('favorites');
  }

  /// Add equipment to favorites
  Future<void> addFavorite(String equipmentId) async {
    await _favoritesRef.doc(equipmentId).set({
      'equipmentId': equipmentId,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove equipment from favorites
  Future<void> removeFavorite(String equipmentId) async {
    await _favoritesRef.doc(equipmentId).delete();
  }

  /// Check if equipment is favorited
  Future<bool> isFavorite(String equipmentId) async {
    final doc = await _favoritesRef.doc(equipmentId).get();
    return doc.exists;
  }

  /// Get all favorite equipment IDs
  Future<Set<String>> getFavoriteIds() async {
    final snapshot = await _favoritesRef.get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  /// Stream favorite IDs for real-time updates
  Stream<Set<String>> streamFavoriteIds() {
    if (_uid == null) return Stream.value({});
    return _favoritesRef.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.id).toSet(),
    );
  }
}

/// ChangeNotifier for favorites state management
class FavoritesProvider extends ChangeNotifier {
  final FavoritesService _service = FavoritesService();
  Set<String> _favoriteIds = {};
  bool _isLoading = false;

  Set<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;

  bool isFavorite(String equipmentId) => _favoriteIds.contains(equipmentId);

  /// Load all favorites
  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      _favoriteIds = await _service.getFavoriteIds();
    } catch (e) {
      debugPrint('Failed to load favorites: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String equipmentId) async {
    try {
      if (_favoriteIds.contains(equipmentId)) {
        await _service.removeFavorite(equipmentId);
        _favoriteIds.remove(equipmentId);
      } else {
        await _service.addFavorite(equipmentId);
        _favoriteIds.add(equipmentId);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to toggle favorite: $e');
    }
  }
}
