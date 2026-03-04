import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Platform statistics model
class PlatformStats {
  final int totalEquipment;
  final int totalProviders;
  final int totalCities;
  final double avgRating;
  final int totalBookings;
  final int totalUsers;

  const PlatformStats({
    this.totalEquipment = 0,
    this.totalProviders = 0,
    this.totalCities = 0,
    this.avgRating = 0.0,
    this.totalBookings = 0,
    this.totalUsers = 0,
  });

  factory PlatformStats.fromMap(Map<String, dynamic> map) {
    return PlatformStats(
      totalEquipment: map['totalEquipment'] ?? 0,
      totalProviders: map['totalProviders'] ?? 0,
      totalCities: map['totalCities'] ?? 0,
      avgRating: (map['avgRating'] ?? 0.0).toDouble(),
      totalBookings: map['totalBookings'] ?? 0,
      totalUsers: map['totalUsers'] ?? 0,
    );
  }
}

/// User statistics model
class UserStats {
  final int listings;
  final int bookings;
  final int reviews;

  const UserStats({this.listings = 0, this.bookings = 0, this.reviews = 0});
}

/// Service to fetch platform and user stats from Firestore
class StatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  /// Get platform-wide statistics
  Future<PlatformStats> getPlatformStats() async {
    try {
      // Try to get from platform_stats document first
      final statsDoc = await _firestore
          .collection('platform_stats')
          .doc('global')
          .get();

      if (statsDoc.exists) {
        return PlatformStats.fromMap(statsDoc.data()!);
      }

      // If no stats doc, compute from collections
      final equipmentCount = await _firestore
          .collection('equipment')
          .count()
          .get();
      final providersCount = await _firestore
          .collection('providers')
          .count()
          .get();
      final usersCount = await _firestore.collection('users').count().get();
      final bookingsCount = await _firestore
          .collection('bookings')
          .count()
          .get();

      // Get unique cities from equipment
      final equipmentDocs = await _firestore.collection('equipment').get();
      final cities = <String>{};
      for (final doc in equipmentDocs.docs) {
        final district = doc.data()['district'] as String?;
        if (district != null && district.isNotEmpty) {
          cities.add(district.toLowerCase());
        }
      }

      final stats = PlatformStats(
        totalEquipment: equipmentCount.count ?? 0,
        totalProviders: providersCount.count ?? 0,
        totalCities: cities.isNotEmpty ? cities.length : 1,
        avgRating: 4.8,
        totalBookings: bookingsCount.count ?? 0,
        totalUsers: usersCount.count ?? 0,
      );

      // Cache the stats
      await _firestore.collection('platform_stats').doc('global').set({
        'totalEquipment': stats.totalEquipment,
        'totalProviders': stats.totalProviders,
        'totalCities': stats.totalCities,
        'avgRating': stats.avgRating,
        'totalBookings': stats.totalBookings,
        'totalUsers': stats.totalUsers,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return stats;
    } catch (e) {
      debugPrint('Failed to get platform stats: $e');
      return const PlatformStats();
    }
  }

  /// Get user-specific statistics
  Future<UserStats> getUserStats() async {
    final uid = _uid;
    if (uid == null) return const UserStats();

    try {
      // Count user's equipment listings
      final listingsCount = await _firestore
          .collection('equipment')
          .where('providerId', isEqualTo: uid)
          .count()
          .get();

      // Count user's bookings (as user or provider)
      final userBookingsCount = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: uid)
          .count()
          .get();

      final providerBookingsCount = await _firestore
          .collection('bookings')
          .where('providerId', isEqualTo: uid)
          .count()
          .get();

      return UserStats(
        listings: listingsCount.count ?? 0,
        bookings:
            (userBookingsCount.count ?? 0) + (providerBookingsCount.count ?? 0),
        reviews: 0, // TODO: implement reviews collection
      );
    } catch (e) {
      debugPrint('Failed to get user stats: $e');
      return const UserStats();
    }
  }
}

/// ChangeNotifier for stats state management
class StatsProvider extends ChangeNotifier {
  final StatsService _service = StatsService();

  PlatformStats _platformStats = const PlatformStats();
  UserStats _userStats = const UserStats();
  bool _isLoading = false;
  bool _statsLoaded = false;

  PlatformStats get platformStats => _platformStats;
  UserStats get userStats => _userStats;
  bool get isLoading => _isLoading;
  bool get statsLoaded => _statsLoaded;

  /// Load platform stats
  Future<void> loadPlatformStats() async {
    _isLoading = true;
    notifyListeners();

    _platformStats = await _service.getPlatformStats();

    _statsLoaded = true;
    _isLoading = false;
    notifyListeners();
  }

  /// Load user stats
  Future<void> loadUserStats() async {
    _userStats = await _service.getUserStats();
    notifyListeners();
  }

  /// Load all stats
  Future<void> loadAllStats() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      _service.getPlatformStats().then((s) => _platformStats = s),
      _service.getUserStats().then((s) => _userStats = s),
    ]);

    _isLoading = false;
    notifyListeners();
  }
}
