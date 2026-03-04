import 'package:cloud_firestore/cloud_firestore.dart';

/// Machine types available in the platform
enum MachineType {
  excavator,
  jcb,
  bulldozer,
  crane,
  loader,
  dumper,
  roller,
  grader,
  compactor,
  other,
}

extension MachineTypeX on MachineType {
  String get value {
    switch (this) {
      case MachineType.excavator:
        return 'Excavator';
      case MachineType.jcb:
        return 'JCB';
      case MachineType.bulldozer:
        return 'Bulldozer';
      case MachineType.crane:
        return 'Crane';
      case MachineType.loader:
        return 'Loader';
      case MachineType.dumper:
        return 'Dumper';
      case MachineType.roller:
        return 'Roller';
      case MachineType.grader:
        return 'Grader';
      case MachineType.compactor:
        return 'Compactor';
      case MachineType.other:
        return 'Other';
    }
  }

  static MachineType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'excavator':
        return MachineType.excavator;
      case 'jcb':
        return MachineType.jcb;
      case 'bulldozer':
        return MachineType.bulldozer;
      case 'crane':
        return MachineType.crane;
      case 'loader':
        return MachineType.loader;
      case 'dumper':
        return MachineType.dumper;
      case 'roller':
        return MachineType.roller;
      case 'grader':
        return MachineType.grader;
      case 'compactor':
        return MachineType.compactor;
      default:
        return MachineType.other;
    }
  }
}

/// Firestore model for Equipment / Machine
class FirestoreEquipmentModel {
  final String id;
  final String providerId;
  final String providerName; // denormalized for quick display
  final MachineType machineType;
  final String brand;
  final String model;
  final String capacity;
  final double hourlyRate;
  final double dailyRate;
  final bool availabilityStatus;
  final String district;
  final String state;
  final GeoPoint location;
  final List<String> machineImages;
  final String description;
  final List<String> specs;
  final double rating;
  final int reviewCount;
  final int totalBookings;
  final String ownerPhone;
  final DateTime createdAt;
  final DateTime updatedAt;

  FirestoreEquipmentModel({
    required this.id,
    required this.providerId,
    this.providerName = '',
    required this.machineType,
    required this.brand,
    required this.model,
    this.capacity = '',
    required this.hourlyRate,
    this.dailyRate = 0,
    this.availabilityStatus = true,
    required this.district,
    this.state = '',
    required this.location,
    this.machineImages = const [],
    this.description = '',
    this.specs = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.totalBookings = 0,
    this.ownerPhone = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'providerId': providerId,
      'providerName': providerName,
      'machineType': machineType.value,
      'brand': brand,
      'model': model,
      'capacity': capacity,
      'hourlyRate': hourlyRate,
      'dailyRate': dailyRate,
      'availabilityStatus': availabilityStatus,
      'district': district,
      'state': state,
      'location': location,
      'machineImages': machineImages,
      'description': description,
      'specs': specs,
      'rating': rating,
      'reviewCount': reviewCount,
      'totalBookings': totalBookings,
      'ownerPhone': ownerPhone,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory FirestoreEquipmentModel.fromMap(Map<String, dynamic> map) {
    return FirestoreEquipmentModel(
      id: map['id'] ?? '',
      providerId: map['providerId'] ?? '',
      providerName: map['providerName'] ?? '',
      machineType: MachineTypeX.fromString(map['machineType'] ?? 'other'),
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      capacity: map['capacity'] ?? '',
      hourlyRate: (map['hourlyRate'] ?? 0).toDouble(),
      dailyRate: (map['dailyRate'] ?? 0).toDouble(),
      availabilityStatus: map['availabilityStatus'] ?? true,
      district: map['district'] ?? '',
      state: map['state'] ?? '',
      location: map['location'] ?? const GeoPoint(0, 0),
      machineImages: List<String>.from(map['machineImages'] ?? []),
      description: map['description'] ?? '',
      specs: List<String>.from(map['specs'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      totalBookings: map['totalBookings'] ?? 0,
      ownerPhone: map['ownerPhone'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory FirestoreEquipmentModel.fromDocument(DocumentSnapshot doc) {
    return FirestoreEquipmentModel.fromMap({
      ...doc.data() as Map<String, dynamic>,
      'id': doc.id,
    });
  }

  FirestoreEquipmentModel copyWith({
    String? providerName,
    MachineType? machineType,
    String? brand,
    String? model,
    String? capacity,
    double? hourlyRate,
    double? dailyRate,
    bool? availabilityStatus,
    String? district,
    String? state,
    GeoPoint? location,
    List<String>? machineImages,
    String? description,
    List<String>? specs,
    double? rating,
    int? reviewCount,
    int? totalBookings,
    String? ownerPhone,
  }) {
    return FirestoreEquipmentModel(
      id: id,
      providerId: providerId,
      providerName: providerName ?? this.providerName,
      machineType: machineType ?? this.machineType,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      capacity: capacity ?? this.capacity,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      dailyRate: dailyRate ?? this.dailyRate,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      district: district ?? this.district,
      state: state ?? this.state,
      location: location ?? this.location,
      machineImages: machineImages ?? this.machineImages,
      description: description ?? this.description,
      specs: specs ?? this.specs,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      totalBookings: totalBookings ?? this.totalBookings,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
