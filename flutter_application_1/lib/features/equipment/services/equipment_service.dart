import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../models/firestore_equipment_model.dart';

/// Service for Equipment CRUD operations with Firestore
class EquipmentService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _uid => _auth.currentUser?.uid;

  /// Reference to the equipment collection
  CollectionReference<Map<String, dynamic>> get _equipmentRef =>
      _firestore.collection('equipment');

  Future<List<FirestoreEquipmentModel>> _fetchAllEquipment() async {
    final snapshot = await _equipmentRef
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => FirestoreEquipmentModel.fromDocument(doc))
        .toList();
  }

  /// Add new equipment (provider only) – writes to Firestore
  Future<FirestoreEquipmentModel> addEquipment({
    required MachineType machineType,
    required String brand,
    required String model,
    String capacity = '',
    required double hourlyRate,
    double dailyRate = 0,
    required String district,
    String state = '',
    required GeoPoint location,
    List<String> machineImages = const [],
    String description = '',
    List<String> specs = const [],
    String providerName = '',
    String ownerPhone = '',
    String company = '',
    String soilType = '',
    String depth = '',
    String enginePower = '',
    String bucketCapacity = '',
    String area = '',
    String operatingWeight = '',
  }) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      throw Exception('User not authenticated. Please log in again.');
    }

    debugPrint('┌─── ADD EQUIPMENT ───');
    debugPrint('│ uid: $uid');
    debugPrint('│ providerName: $providerName');
    debugPrint('│ brand: $brand, model: $model');
    debugPrint('│ district: $district');
    debugPrint('│ machineImages count: ${machineImages.length}');
    if (machineImages.isNotEmpty) {
      for (int i = 0; i < machineImages.length; i++) {
        debugPrint('│ image[$i]: ${machineImages[i]}');
      }
    }
    debugPrint('│ ownerPhone: $ownerPhone');

    final now = DateTime.now();
    final docRef = _equipmentRef.doc(); // auto-ID
    debugPrint('│ docId: ${docRef.id}');

    final equipment = FirestoreEquipmentModel(
      id: docRef.id,
      providerId: uid,
      providerName: providerName,
      machineType: machineType,
      brand: brand,
      model: model,
      capacity: capacity,
      hourlyRate: hourlyRate,
      dailyRate: dailyRate,
      availabilityStatus: true,
      district: district,
      state: state,
      location: location,
      machineImages: machineImages,
      description: description,
      specs: specs,
      ownerPhone: ownerPhone,
      company: company,
      soilType: soilType,
      depth: depth,
      enginePower: enginePower,
      bucketCapacity: bucketCapacity,
      area: area,
      operatingWeight: operatingWeight,
      createdAt: now,
      updatedAt: now,
    );

    final dataMap = equipment.toMap();
    debugPrint('│ Writing to Firestore...');

    await docRef.set(dataMap);
    debugPrint('│ Local write done. Verifying on server...');

    // Verify the write reached the server (bypasses cache)
    try {
      final serverDoc = await docRef.get(
        const GetOptions(source: Source.server),
      );
      if (serverDoc.exists) {
        debugPrint('│ ✅ Verified on Firestore server!');
        debugPrint('│ Server data keys: ${serverDoc.data()?.keys.toList()}');
        final serverImages = serverDoc.data()?['machineImages'];
        debugPrint('│ Server machineImages: $serverImages');
      } else {
        debugPrint('│ ⚠️ Document NOT found on server after write!');
      }
    } catch (e) {
      debugPrint('│ ⚠️ Server verification failed: $e');
      debugPrint('│ Data may still sync when online.');
    }

    debugPrint('└─── ADD EQUIPMENT COMPLETE ───');
    return equipment;
  }

  /// Update equipment in Firestore
  Future<void> updateEquipment(FirestoreEquipmentModel equipment) async {
    final updated = equipment.copyWith();
    await _equipmentRef.doc(equipment.id).update(updated.toMap());
  }

  /// Delete equipment from Firestore
  Future<void> deleteEquipment(String equipmentId) async {
    await _equipmentRef.doc(equipmentId).delete();
  }

  /// Toggle availability directly in Firestore
  Future<void> toggleAvailability(String equipmentId, bool status) async {
    await _equipmentRef.doc(equipmentId).update({
      'availabilityStatus': status,
      'updatedAt': Timestamp.now(),
    });
  }

  /// Get equipment by ID from Firestore
  Future<FirestoreEquipmentModel?> getEquipment(String equipmentId) async {
    final doc = await _equipmentRef.doc(equipmentId).get();
    if (!doc.exists) return null;
    return FirestoreEquipmentModel.fromDocument(doc);
  }

  /// Get all equipment for a provider from Firestore
  Future<List<FirestoreEquipmentModel>> getProviderEquipment(
    String providerId,
  ) async {
    final snapshot = await _equipmentRef
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => FirestoreEquipmentModel.fromDocument(doc))
        .toList();
  }

  /// Stream provider's equipment for real-time updates from Firestore
  Stream<List<FirestoreEquipmentModel>> streamProviderEquipment(
    String providerId,
  ) {
    return _equipmentRef
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FirestoreEquipmentModel.fromDocument(doc))
              .toList(),
        );
  }

  /// Get available equipment filtered by district & machine type
  Future<List<FirestoreEquipmentModel>> getAvailableEquipment({
    String? district,
    MachineType? machineType,
    int limit = 20,
  }) async {
    var results = await _fetchAllEquipment();
    results = results.where((item) => item.availabilityStatus).toList();

    if (district != null && district.isNotEmpty) {
      final target = district.trim().toLowerCase();
      results = results
          .where((item) => item.district.trim().toLowerCase() == target)
          .toList();
    }

    if (machineType != null) {
      results = results
          .where((item) => item.machineType == machineType)
          .toList();
    }

    if (results.length > limit) {
      results = results.sublist(0, limit);
    }

    return results;
  }

  /// Search equipment with multiple filters
  Future<List<FirestoreEquipmentModel>> searchEquipment({
    String? district,
    MachineType? machineType,
    double? maxPrice,
    double? minPrice,
    int limit = 20,
  }) async {
    var results = await getAvailableEquipment(
      district: district,
      machineType: machineType,
      limit: limit,
    );

    if (minPrice != null) {
      results = results.where((e) => e.hourlyRate >= minPrice).toList();
    }
    if (maxPrice != null) {
      results = results.where((e) => e.hourlyRate <= maxPrice).toList();
    }

    return results;
  }

  /// Get all equipment (admin)
  Future<List<FirestoreEquipmentModel>> getAllEquipment({
    int limit = 50,
  }) async {
    final all = await _fetchAllEquipment();
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (all.length > limit) {
      return all.sublist(0, limit);
    }
    return all;
  }

  /// Get nearby equipment using GeoPoint bounding box
  Future<List<FirestoreEquipmentModel>> getNearbyEquipment({
    required double latitude,
    required double longitude,
    double radiusKm = 50,
    MachineType? machineType,
  }) async {
    var results = await getAvailableEquipment(
      machineType: machineType,
      limit: 500,
    );

    results = results.where((item) {
      if (item.location.latitude == 0 && item.location.longitude == 0) {
        return false;
      }
      final dist = _calculateDistance(
        latitude,
        longitude,
        item.location.latitude,
        item.location.longitude,
      );
      return dist <= radiusKm;
    }).toList();

    results.sort((a, b) {
      final distA = _calculateDistance(
        latitude,
        longitude,
        a.location.latitude,
        a.location.longitude,
      );
      final distB = _calculateDistance(
        latitude,
        longitude,
        b.location.latitude,
        b.location.longitude,
      );
      return distA.compareTo(distB);
    });

    return results;
  }

  /// Calculate approximate distance between two points (in km)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = (lat2 - lat1) * 111.0;
    final dLon = (lon2 - lon1) * 111.0 * _cosine(lat1);
    return (dLat * dLat + dLon * dLon).sqrt();
  }

  /// Cosine approximation for latitude
  double _cosine(double degrees) {
    const pi = 3.14159265358979;
    final radians = degrees * pi / 180;
    return 1 -
        (radians * radians) / 2 +
        (radians * radians * radians * radians) / 24;
  }
}

extension on double {
  double sqrt() {
    if (this <= 0) return 0;
    var guess = this / 2;
    for (var i = 0; i < 12; i++) {
      guess = (guess + this / guess) / 2;
    }
    return guess;
  }
}

/// ChangeNotifier for Equipment state management
class EquipmentProvider extends ChangeNotifier {
  final EquipmentService _service = EquipmentService();

  List<FirestoreEquipmentModel> _equipment = [];
  List<FirestoreEquipmentModel> _allEquipment = [];
  List<FirestoreEquipmentModel> _searchResults = [];
  FirestoreEquipmentModel? _selectedEquipment;
  bool _isLoading = false;
  String? _errorMessage;

  List<FirestoreEquipmentModel> get equipment => _equipment;
  List<FirestoreEquipmentModel> get allEquipment => _allEquipment;
  List<FirestoreEquipmentModel> get searchResults => _searchResults;
  FirestoreEquipmentModel? get selectedEquipment => _selectedEquipment;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load ALL equipment (for home/search screens)
  Future<void> loadAllEquipment() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allEquipment = await _service.getAllEquipment(limit: 100);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load equipment: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load provider's own equipment
  Future<void> loadProviderEquipment(String providerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _equipment = await _service.getProviderEquipment(providerId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load equipment: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Add equipment
  Future<bool> addEquipment({
    required MachineType machineType,
    required String brand,
    required String model,
    String capacity = '',
    required double hourlyRate,
    double dailyRate = 0,
    required String district,
    String state = '',
    required double latitude,
    required double longitude,
    List<String> machineImages = const [],
    String description = '',
    List<String> specs = const [],
    String providerName = '',
    String ownerPhone = '',
    String company = '',
    String soilType = '',
    String depth = '',
    String enginePower = '',
    String bucketCapacity = '',
    String area = '',
    String operatingWeight = '',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newEquipment = await _service.addEquipment(
        machineType: machineType,
        brand: brand,
        model: model,
        capacity: capacity,
        hourlyRate: hourlyRate,
        dailyRate: dailyRate,
        district: district,
        state: state,
        location: GeoPoint(latitude, longitude),
        machineImages: machineImages,
        description: description,
        specs: specs,
        providerName: providerName,
        ownerPhone: ownerPhone,
        company: company,
        soilType: soilType,
        depth: depth,
        enginePower: enginePower,
        bucketCapacity: bucketCapacity,
        area: area,
        operatingWeight: operatingWeight,
      );
      _equipment.insert(0, newEquipment);
      _allEquipment.insert(0, newEquipment);
      _isLoading = false;
      debugPrint(
        '✅ EquipmentProvider: equipment added successfully (id: ${newEquipment.id})',
      );
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ EquipmentProvider.addEquipment FAILED: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      _errorMessage = 'Failed to add equipment: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Toggle availability
  Future<void> toggleAvailability(String equipmentId, bool status) async {
    try {
      await _service.toggleAvailability(equipmentId, status);
      final index = _equipment.indexWhere((e) => e.id == equipmentId);
      if (index != -1) {
        _equipment[index] = _equipment[index].copyWith(
          availabilityStatus: status,
        );
      }
      final allIndex = _allEquipment.indexWhere((e) => e.id == equipmentId);
      if (allIndex != -1) {
        _allEquipment[allIndex] = _allEquipment[allIndex].copyWith(
          availabilityStatus: status,
        );
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update availability: $e';
      notifyListeners();
    }
  }

  /// Update equipment
  Future<bool> updateEquipment(FirestoreEquipmentModel equipment) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.updateEquipment(equipment);
      final index = _equipment.indexWhere((e) => e.id == equipment.id);
      if (index != -1) {
        _equipment[index] = equipment;
      }
      final allIndex = _allEquipment.indexWhere((e) => e.id == equipment.id);
      if (allIndex != -1) {
        _allEquipment[allIndex] = equipment;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update equipment: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete equipment
  Future<bool> deleteEquipment(String equipmentId) async {
    try {
      await _service.deleteEquipment(equipmentId);
      _equipment.removeWhere((e) => e.id == equipmentId);
      _allEquipment.removeWhere((e) => e.id == equipmentId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete: $e';
      notifyListeners();
      return false;
    }
  }

  /// Search available equipment
  Future<void> searchAvailableEquipment({
    String? district,
    MachineType? machineType,
    double? maxPrice,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _service.searchEquipment(
        district: district,
        machineType: machineType,
        maxPrice: maxPrice,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Search failed: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Find nearby equipment
  Future<void> findNearbyEquipment({
    required double latitude,
    required double longitude,
    double radiusKm = 50,
    MachineType? machineType,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _service.getNearbyEquipment(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        machineType: machineType,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Nearby search failed: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectEquipment(FirestoreEquipmentModel eq) {
    _selectedEquipment = eq;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
