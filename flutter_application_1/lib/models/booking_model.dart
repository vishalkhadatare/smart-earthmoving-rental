import 'package:cloud_firestore/cloud_firestore.dart';

/// Status of a booking
enum BookingStatus {
  pending,
  approved,
  inProgress,
  completed,
  cancelled,
  rejected,
}

extension BookingStatusX on BookingStatus {
  String get value {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.approved:
        return 'Approved';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.rejected:
        return 'Rejected';
    }
  }

  static BookingStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'approved':
        return BookingStatus.approved;
      case 'in progress':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'rejected':
        return BookingStatus.rejected;
      default:
        return BookingStatus.pending;
    }
  }
}

/// Firestore model for Bookings
class BookingModel {
  final String id;
  final String equipmentId;
  final String equipmentName; // denormalized
  final String machineType; // denormalized
  final String providerId;
  final String providerName; // denormalized
  final String userId;
  final String userName; // denormalized
  final String userPhone; // denormalized
  final DateTime bookingDate;
  final DateTime? endDate;
  final GeoPoint location;
  final String locationAddress;
  final int durationHours;
  final double hourlyRate;
  final double totalAmount;
  final double commissionRate; // e.g. 0.05 = 5%
  final double commissionAmount;
  final double providerAmount;
  final BookingStatus status;
  final String? cancellationReason;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingModel({
    required this.id,
    required this.equipmentId,
    this.equipmentName = '',
    this.machineType = '',
    required this.providerId,
    this.providerName = '',
    required this.userId,
    this.userName = '',
    this.userPhone = '',
    required this.bookingDate,
    this.endDate,
    required this.location,
    this.locationAddress = '',
    required this.durationHours,
    required this.hourlyRate,
    required this.totalAmount,
    this.commissionRate = 0.05,
    required this.commissionAmount,
    required this.providerAmount,
    this.status = BookingStatus.pending,
    this.cancellationReason,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Factory to create a booking with auto-calculated commission
  factory BookingModel.create({
    required String id,
    required String equipmentId,
    String equipmentName = '',
    String machineType = '',
    required String providerId,
    String providerName = '',
    required String userId,
    String userName = '',
    String userPhone = '',
    required DateTime bookingDate,
    DateTime? endDate,
    required GeoPoint location,
    String locationAddress = '',
    required int durationHours,
    required double hourlyRate,
    double commissionRate = 0.05,
    String? notes,
  }) {
    final totalAmount = hourlyRate * durationHours;
    final commissionAmount = totalAmount * commissionRate;
    final providerAmount = totalAmount - commissionAmount;

    return BookingModel(
      id: id,
      equipmentId: equipmentId,
      equipmentName: equipmentName,
      machineType: machineType,
      providerId: providerId,
      providerName: providerName,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      bookingDate: bookingDate,
      endDate: endDate,
      location: location,
      locationAddress: locationAddress,
      durationHours: durationHours,
      hourlyRate: hourlyRate,
      totalAmount: totalAmount,
      commissionRate: commissionRate,
      commissionAmount: commissionAmount,
      providerAmount: providerAmount,
      notes: notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'equipmentId': equipmentId,
      'equipmentName': equipmentName,
      'machineType': machineType,
      'providerId': providerId,
      'providerName': providerName,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'location': location,
      'locationAddress': locationAddress,
      'durationHours': durationHours,
      'hourlyRate': hourlyRate,
      'totalAmount': totalAmount,
      'commissionRate': commissionRate,
      'commissionAmount': commissionAmount,
      'providerAmount': providerAmount,
      'status': status.value,
      'cancellationReason': cancellationReason,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] ?? '',
      equipmentId: map['equipmentId'] ?? '',
      equipmentName: map['equipmentName'] ?? '',
      machineType: map['machineType'] ?? '',
      providerId: map['providerId'] ?? '',
      providerName: map['providerName'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      bookingDate:
          (map['bookingDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      location: map['location'] ?? const GeoPoint(0, 0),
      locationAddress: map['locationAddress'] ?? '',
      durationHours: map['durationHours'] ?? 0,
      hourlyRate: (map['hourlyRate'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      commissionRate: (map['commissionRate'] ?? 0.05).toDouble(),
      commissionAmount: (map['commissionAmount'] ?? 0).toDouble(),
      providerAmount: (map['providerAmount'] ?? 0).toDouble(),
      status: BookingStatusX.fromString(map['status'] ?? 'Pending'),
      cancellationReason: map['cancellationReason'],
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory BookingModel.fromDocument(DocumentSnapshot doc) {
    return BookingModel.fromMap({
      ...doc.data() as Map<String, dynamic>,
      'id': doc.id,
    });
  }

  BookingModel copyWith({
    BookingStatus? status,
    String? cancellationReason,
    String? notes,
    DateTime? endDate,
  }) {
    return BookingModel(
      id: id,
      equipmentId: equipmentId,
      equipmentName: equipmentName,
      machineType: machineType,
      providerId: providerId,
      providerName: providerName,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      bookingDate: bookingDate,
      endDate: endDate ?? this.endDate,
      location: location,
      locationAddress: locationAddress,
      durationHours: durationHours,
      hourlyRate: hourlyRate,
      totalAmount: totalAmount,
      commissionRate: commissionRate,
      commissionAmount: commissionAmount,
      providerAmount: providerAmount,
      status: status ?? this.status,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
