import '../../../models/firestore_equipment_model.dart';

class EquipmentProviderInfo {
  final String id;
  final String name;
  final String photoUrl;
  final String phone;
  final double rating;
  final String location;

  const EquipmentProviderInfo({
    required this.id,
    required this.name,
    this.photoUrl = '',
    required this.phone,
    this.rating = 4.5,
    this.location = '',
  });
}

class EquipmentModel {
  final String id;
  final String name;
  final String model;
  final String imageAsset;
  final List<String> imageUrls; // network URLs from Firebase Storage
  final double pricePerHour;
  final String category;
  final String description;
  final bool isAvailable;
  final double rating;
  final int reviewCount;
  final List<String> specs;
  final EquipmentProviderInfo provider;

  const EquipmentModel({
    required this.id,
    required this.name,
    required this.model,
    required this.imageAsset,
    this.imageUrls = const [],
    required this.pricePerHour,
    required this.category,
    this.description = '',
    this.isAvailable = true,
    this.rating = 4.5,
    this.reviewCount = 0,
    this.specs = const [],
    required this.provider,
  });

  /// Whether this equipment has user-uploaded photos
  bool get hasNetworkImages => imageUrls.isNotEmpty;

  /// Primary image URL (first uploaded photo) or null
  String? get primaryImageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  /// Convert a Firestore equipment document into the UI model
  factory EquipmentModel.fromFirestoreModel(FirestoreEquipmentModel fs) {
    // Map MachineType â†’ UI category
    String category;
    switch (fs.machineType) {
      case MachineType.excavator:
      case MachineType.jcb:
        category = 'Excavators';
        break;
      case MachineType.bulldozer:
        category = 'Bulldozers';
        break;
      case MachineType.loader:
        category = 'Loaders';
        break;
      case MachineType.crane:
        category = 'Cranes';
        break;
      case MachineType.dumper:
        category = 'Dumpers';
        break;
      case MachineType.roller:
      case MachineType.compactor:
      case MachineType.grader:
        category = 'Rollers';
        break;
      case MachineType.other:
        category = 'Excavators';
        break;
    }

    // Default asset image based on machine type
    String imageAsset;
    switch (fs.machineType) {
      case MachineType.excavator:
      case MachineType.jcb:
        imageAsset = 'assets/images/escavator.png';
        break;
      case MachineType.bulldozer:
      case MachineType.grader:
        imageAsset = 'assets/images/bulldozer.png';
        break;
      case MachineType.loader:
        imageAsset = 'assets/images/backhoe loader.png';
        break;
      default:
        imageAsset = 'assets/images/wheel loader.png';
        break;
    }

    return EquipmentModel(
      id: fs.id,
      name: '${fs.brand} ${fs.machineType.value}',
      model: fs.model,
      imageAsset: imageAsset,
      imageUrls: fs.machineImages,
      pricePerHour: fs.hourlyRate,
      category: category,
      description: fs.description,
      isAvailable: fs.availabilityStatus,
      rating: fs.rating,
      reviewCount: fs.reviewCount,
      specs: fs.specs.isNotEmpty
          ? fs.specs
          : [fs.capacity, '${fs.hourlyRate.toStringAsFixed(0)}/hr'],
      provider: EquipmentProviderInfo(
        id: fs.providerId,
        name: fs.providerName.isNotEmpty ? fs.providerName : 'Provider',
        phone: fs.ownerPhone,
        rating: fs.rating,
        location: '${fs.district}, ${fs.state}',
      ),
    );
  }

  static const List<String> categories = [
    'All',
    'Excavators',
    'Bulldozers',
    'Loaders',
    'Cranes',
    'Dumpers',
    'Rollers',
  ];
}
