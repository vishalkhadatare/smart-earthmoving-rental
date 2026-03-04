import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore model for Equipment Provider (company/owner who rents out machines)
class ProviderModel {
  final String id;
  final String companyName;
  final String ownerName;
  final String phone;
  final String whatsappNumber;
  final String gstin;
  final String district;
  final String state;
  final String address;
  final GeoPoint location;
  final String? profileImageUrl;
  final bool isVerified;
  final double rating;
  final int totalEquipment;
  final int completedBookings;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProviderModel({
    required this.id,
    required this.companyName,
    required this.ownerName,
    required this.phone,
    this.whatsappNumber = '',
    this.gstin = '',
    required this.district,
    this.state = '',
    required this.address,
    required this.location,
    this.profileImageUrl,
    this.isVerified = false,
    this.rating = 0.0,
    this.totalEquipment = 0,
    this.completedBookings = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyName': companyName,
      'ownerName': ownerName,
      'phone': phone,
      'whatsappNumber': whatsappNumber,
      'gstin': gstin,
      'district': district,
      'state': state,
      'address': address,
      'location': location,
      'profileImageUrl': profileImageUrl,
      'isVerified': isVerified,
      'rating': rating,
      'totalEquipment': totalEquipment,
      'completedBookings': completedBookings,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ProviderModel.fromMap(Map<String, dynamic> map) {
    return ProviderModel(
      id: map['id'] ?? '',
      companyName: map['companyName'] ?? '',
      ownerName: map['ownerName'] ?? '',
      phone: map['phone'] ?? '',
      whatsappNumber: map['whatsappNumber'] ?? '',
      gstin: map['gstin'] ?? '',
      district: map['district'] ?? '',
      state: map['state'] ?? '',
      address: map['address'] ?? '',
      location: map['location'] ?? const GeoPoint(0, 0),
      profileImageUrl: map['profileImageUrl'],
      isVerified: map['isVerified'] ?? false,
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalEquipment: map['totalEquipment'] ?? 0,
      completedBookings: map['completedBookings'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory ProviderModel.fromDocument(DocumentSnapshot doc) {
    return ProviderModel.fromMap({
      ...doc.data() as Map<String, dynamic>,
      'id': doc.id,
    });
  }

  ProviderModel copyWith({
    String? companyName,
    String? ownerName,
    String? phone,
    String? whatsappNumber,
    String? gstin,
    String? district,
    String? state,
    String? address,
    GeoPoint? location,
    String? profileImageUrl,
    bool? isVerified,
    double? rating,
    int? totalEquipment,
    int? completedBookings,
  }) {
    return ProviderModel(
      id: id,
      companyName: companyName ?? this.companyName,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      gstin: gstin ?? this.gstin,
      district: district ?? this.district,
      state: state ?? this.state,
      address: address ?? this.address,
      location: location ?? this.location,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      totalEquipment: totalEquipment ?? this.totalEquipment,
      completedBookings: completedBookings ?? this.completedBookings,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
