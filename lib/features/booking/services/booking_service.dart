import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../models/booking_model.dart';

/// Service for Booking CRUD operations with Firestore
class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _collection = 'bookings';
  static const double _commissionRate = 0.05; // 5% platform commission

  String? get _uid => _auth.currentUser?.uid;

  /// Create a new booking
  Future<BookingModel> createBooking({
    required String equipmentId,
    String equipmentName = '',
    String machineType = '',
    required String providerId,
    String providerName = '',
    String userName = '',
    String userPhone = '',
    required DateTime bookingDate,
    DateTime? endDate,
    required GeoPoint location,
    String locationAddress = '',
    required int durationHours,
    required double hourlyRate,
    String? notes,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');

    final docRef = _firestore.collection(_collection).doc();

    final booking = BookingModel.create(
      id: docRef.id,
      equipmentId: equipmentId,
      equipmentName: equipmentName,
      machineType: machineType,
      providerId: providerId,
      providerName: providerName,
      userId: uid,
      userName: userName,
      userPhone: userPhone,
      bookingDate: bookingDate,
      endDate: endDate,
      location: location,
      locationAddress: locationAddress,
      durationHours: durationHours,
      hourlyRate: hourlyRate,
      commissionRate: _commissionRate,
      notes: notes,
    );

    // Use batch write for atomicity
    final batch = _firestore.batch();
    batch.set(docRef, booking.toMap());

    // Update equipment availability
    batch.update(_firestore.collection('equipment').doc(equipmentId), {
      'availabilityStatus': false,
      'totalBookings': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    return booking;
  }

  /// Update booking status (provider action)
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status, {
    String? cancellationReason,
  }) async {
    final updateData = <String, dynamic>{
      'status': status.value,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (cancellationReason != null) {
      updateData['cancellationReason'] = cancellationReason;
    }

    // If cancelled or rejected, re-enable equipment availability
    if (status == BookingStatus.cancelled || status == BookingStatus.rejected) {
      final booking = await getBooking(bookingId);
      if (booking != null) {
        await _firestore
            .collection('equipment')
            .doc(booking.equipmentId)
            .update({
              'availabilityStatus': true,
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }
    }

    // If completed, update provider earnings
    if (status == BookingStatus.completed) {
      final booking = await getBooking(bookingId);
      if (booking != null) {
        final batch = _firestore.batch();

        batch.update(
          _firestore.collection(_collection).doc(bookingId),
          updateData,
        );

        // Update/create earnings document
        batch.set(
          _firestore.collection('earnings').doc(booking.providerId),
          {
            'providerId': booking.providerId,
            'totalEarnings': FieldValue.increment(booking.providerAmount),
            'completedPayments': FieldValue.increment(booking.providerAmount),
            'totalCommissionPaid': FieldValue.increment(
              booking.commissionAmount,
            ),
            'totalBookingsCompleted': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        // Update provider's completed bookings count
        batch.set(
          _firestore.collection('providers').doc(booking.providerId),
          {
            'completedBookings': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        // Re-enable equipment
        batch.update(
          _firestore.collection('equipment').doc(booking.equipmentId),
          {
            'availabilityStatus': true,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );

        // Create payment record
        final paymentRef = _firestore.collection('payments').doc();
        batch.set(paymentRef, {
          'id': paymentRef.id,
          'bookingId': bookingId,
          'userId': booking.userId,
          'providerId': booking.providerId,
          'totalAmount': booking.totalAmount,
          'commissionAmount': booking.commissionAmount,
          'providerAmount': booking.providerAmount,
          'status': 'Completed',
          'paymentMethod': 'Cash',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update platform stats
        batch.set(
          _firestore.collection('platform_stats').doc('revenue'),
          {
            'totalRevenue': FieldValue.increment(booking.totalAmount),
            'totalCommission': FieldValue.increment(booking.commissionAmount),
            'totalBookings': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        await batch.commit();
        return;
      }
    }

    await _firestore.collection(_collection).doc(bookingId).update(updateData);
  }

  /// Get booking by ID
  Future<BookingModel?> getBooking(String bookingId) async {
    final doc = await _firestore.collection(_collection).doc(bookingId).get();
    if (!doc.exists) return null;
    return BookingModel.fromDocument(doc);
  }

  /// Get bookings for current user (as customer)
  Future<List<BookingModel>> getUserBookings() async {
    final uid = _uid;
    if (uid == null) return [];

    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => BookingModel.fromDocument(doc)).toList();
  }

  /// Get bookings for provider (incoming bookings)
  Future<List<BookingModel>> getProviderBookings(String providerId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => BookingModel.fromDocument(doc)).toList();
  }

  /// Stream provider bookings for real-time notifications
  Stream<List<BookingModel>> streamProviderBookings(String providerId) {
    return _firestore
        .collection(_collection)
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => BookingModel.fromDocument(doc)).toList(),
        );
  }

  /// Stream user bookings
  Stream<List<BookingModel>> streamUserBookings() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => BookingModel.fromDocument(doc)).toList(),
        );
  }

  /// Stream pending bookings for provider (real-time notification)
  Stream<List<BookingModel>> streamPendingBookings(String providerId) {
    return _firestore
        .collection(_collection)
        .where('providerId', isEqualTo: providerId)
        .where('status', isEqualTo: 'Pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => BookingModel.fromDocument(doc)).toList(),
        );
  }

  /// Get all bookings (admin)
  Future<List<BookingModel>> getAllBookings({int limit = 50}) async {
    final snapshot = await _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => BookingModel.fromDocument(doc)).toList();
  }
}

/// ChangeNotifier for Booking state management
class BookingProvider extends ChangeNotifier {
  final BookingService _service = BookingService();

  List<BookingModel> _userBookings = [];
  List<BookingModel> _providerBookings = [];
  BookingModel? _selectedBooking;
  bool _isLoading = false;
  String? _errorMessage;

  List<BookingModel> get userBookings => _userBookings;
  List<BookingModel> get providerBookings => _providerBookings;
  BookingModel? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get pendingBookingsCount =>
      _providerBookings.where((b) => b.status == BookingStatus.pending).length;

  /// Create a booking
  Future<bool> createBooking({
    required String equipmentId,
    String equipmentName = '',
    String machineType = '',
    required String providerId,
    String providerName = '',
    String userName = '',
    String userPhone = '',
    required DateTime bookingDate,
    DateTime? endDate,
    required double latitude,
    required double longitude,
    String locationAddress = '',
    required int durationHours,
    required double hourlyRate,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final booking = await _service.createBooking(
        equipmentId: equipmentId,
        equipmentName: equipmentName,
        machineType: machineType,
        providerId: providerId,
        providerName: providerName,
        userName: userName,
        userPhone: userPhone,
        bookingDate: bookingDate,
        endDate: endDate,
        location: GeoPoint(latitude, longitude),
        locationAddress: locationAddress,
        durationHours: durationHours,
        hourlyRate: hourlyRate,
        notes: notes,
      );
      _userBookings.insert(0, booking);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Booking failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update booking status
  Future<bool> updateStatus(
    String bookingId,
    BookingStatus status, {
    String? reason,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.updateBookingStatus(
        bookingId,
        status,
        cancellationReason: reason,
      );

      // Update local lists
      _updateLocalBooking(bookingId, status);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Status update failed: $e');
      _errorMessage = 'Status update failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void _updateLocalBooking(String bookingId, BookingStatus status) {
    final userIdx = _userBookings.indexWhere((b) => b.id == bookingId);
    if (userIdx != -1) {
      _userBookings[userIdx] = _userBookings[userIdx].copyWith(status: status);
    }
    final provIdx = _providerBookings.indexWhere((b) => b.id == bookingId);
    if (provIdx != -1) {
      _providerBookings[provIdx] = _providerBookings[provIdx].copyWith(
        status: status,
      );
    }
  }

  /// Load user's bookings
  Future<void> loadUserBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userBookings = await _service.getUserBookings();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load bookings: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load provider's incoming bookings
  Future<void> loadProviderBookings(String providerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _providerBookings = await _service.getProviderBookings(providerId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load bookings: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
