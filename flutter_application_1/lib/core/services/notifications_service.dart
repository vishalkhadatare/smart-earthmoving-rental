import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../models/booking_model.dart';
import '../../features/booking/services/booking_service.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  bool seen;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.seen = false,
  });
}

/// Simple in-memory notifications provider that derives user/provider notifications
/// from booking streams. This avoids changing the database schema.
class NotificationsProvider extends ChangeNotifier {
  final BookingService _bookingService = BookingService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<NotificationItem> _items = [];
  StreamSubscription<List<BookingModel>>? _userSub;
  StreamSubscription<List<BookingModel>>? _providerSub;
  final Set<String> _addedFromBooking = {};

  List<NotificationItem> get items => List.unmodifiable(_items);
  int get unseenCount => _items.where((n) => !n.seen).length;

  NotificationsProvider() {
    _init();
  }

  Future<void> _init() async {
    // Listen to user bookings
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      _userSub = _bookingService.streamUserBookings().listen((bookings) {
        _processBookings(bookings, forProvider: false);
      });

      // Also listen for provider bookings - use current user's UID as provider ID
      // (since providerId in equipment is set to the owner's UID when they add equipment)
      _providerSub = _bookingService
          .streamProviderBookings(uid)
          .listen((bookings) {
        _processBookings(bookings, forProvider: true);
      });
    }
  }

  void _processBookings(List<BookingModel> bookings, {required bool forProvider}) {
    for (final b in bookings) {
      final key = '${forProvider ? 'P' : 'U'}-${b.id}-${b.updatedAt.millisecondsSinceEpoch}';
      if (_addedFromBooking.contains(key)) continue;
      // create a friendly message
      final title = forProvider
          ? 'New booking: ${b.equipmentName}'
          : 'Booking ${b.status.value}';
      final body = forProvider
          ? '${b.userName} booked ${b.equipmentName} (${b.durationHours}h)'
          : 'Your booking for ${b.equipmentName} is ${b.status.value}';

      final n = NotificationItem(
        id: key,
        title: title,
        body: body,
        createdAt: DateTime.now(),
        seen: false,
      );
      _items.insert(0, n);
      _addedFromBooking.add(key);
    }
    notifyListeners();
  }

  void markAllSeen() {
    for (final n in _items) {
      n.seen = true;
    }
    notifyListeners();
  }

  void markSeen(String id) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx != -1) {
      _items[idx].seen = true;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _providerSub?.cancel();
    super.dispose();
  }
}
