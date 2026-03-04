import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../models/provider_model.dart';

/// Service for Provider CRUD operations with Firestore
class ProviderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _collection = 'providers';

  /// Get current user ID
  String? get _uid => _auth.currentUser?.uid;

  /// Register a new provider
  Future<ProviderModel> registerProvider({
    required String companyName,
    required String ownerName,
    required String phone,
    String whatsappNumber = '',
    String gstin = '',
    required String district,
    String state = '',
    required String address,
    required GeoPoint location,
    String? profileImageUrl,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');

    final provider = ProviderModel(
      id: uid,
      companyName: companyName,
      ownerName: ownerName,
      phone: phone,
      whatsappNumber: whatsappNumber,
      gstin: gstin,
      district: district,
      state: state,
      address: address,
      location: location,
      profileImageUrl: profileImageUrl,
    );

    await _firestore
        .collection(_collection)
        .doc(uid)
        .set(provider.toMap(), SetOptions(merge: true));

    // Also update users collection with provider role
    await _firestore.collection('users').doc(uid).set({
      'role': 'provider',
      'providerId': uid,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return provider;
  }

  /// Get provider by ID
  Future<ProviderModel?> getProvider(String providerId) async {
    final doc = await _firestore.collection(_collection).doc(providerId).get();
    if (!doc.exists) return null;
    return ProviderModel.fromDocument(doc);
  }

  /// Get current user's provider profile
  Future<ProviderModel?> getCurrentProvider() async {
    if (_uid == null) return null;
    return getProvider(_uid!);
  }

  /// Update provider profile
  Future<void> updateProvider(ProviderModel provider) async {
    await _firestore.collection(_collection).doc(provider.id).update({
      ...provider.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream provider data for real-time updates
  Stream<ProviderModel?> streamProvider(String providerId) {
    return _firestore
        .collection(_collection)
        .doc(providerId)
        .snapshots()
        .map((doc) => doc.exists ? ProviderModel.fromDocument(doc) : null);
  }

  /// Get all providers (for admin)
  Future<List<ProviderModel>> getAllProviders() async {
    final snapshot = await _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => ProviderModel.fromDocument(doc)).toList();
  }

  /// Get providers by district
  Future<List<ProviderModel>> getProvidersByDistrict(String district) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('district', isEqualTo: district)
        .where('isVerified', isEqualTo: true)
        .get();
    return snapshot.docs.map((doc) => ProviderModel.fromDocument(doc)).toList();
  }

  /// Verify provider (admin only)
  Future<void> verifyProvider(String providerId) async {
    await _firestore.collection(_collection).doc(providerId).update({
      'isVerified': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Check if current user is a registered provider
  Future<bool> isCurrentUserProvider() async {
    if (_uid == null) return false;
    final doc = await _firestore.collection(_collection).doc(_uid).get();
    return doc.exists;
  }
}

/// ChangeNotifier for Provider state management
class ProviderRegistrationProvider extends ChangeNotifier {
  final ProviderService _service = ProviderService();

  ProviderModel? _provider;
  bool _isLoading = false;
  String? _errorMessage;

  ProviderModel? get provider => _provider;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isRegistered => _provider != null;

  /// Load current provider profile
  Future<void> loadCurrentProvider() async {
    _isLoading = true;
    notifyListeners();

    try {
      _provider = await _service.getCurrentProvider();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load provider: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Register as provider
  Future<bool> register({
    required String companyName,
    required String ownerName,
    required String phone,
    String whatsappNumber = '',
    String gstin = '',
    required String district,
    String state = '',
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _provider = await _service.registerProvider(
        companyName: companyName,
        ownerName: ownerName,
        phone: phone,
        whatsappNumber: whatsappNumber,
        gstin: gstin,
        district: district,
        state: state,
        address: address,
        location: GeoPoint(latitude, longitude),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update provider profile
  Future<bool> updateProfile(ProviderModel updated) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.updateProvider(updated);
      _provider = updated;
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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
