import 'models/equipment_model.dart';

/// Dummy data for the BuildRent application
class DummyData {
  static final List<Equipment> equipmentList = [
    Equipment(
      id: '1',
      name: 'CAT 320 Excavator',
      company: 'Caterpillar Inc.',
      imageUrl:
          'https://images.unsplash.com/photo-1581092918056-0c4c3acd3789?w=500&h=300&fit=crop',
      secondaryImageUrl:
          'https://images.unsplash.com/photo-1581092916550-e323be2ae537?w=500&h=300&fit=crop',
      location: 'New York, NY',
      rating: 4.8,
      reviewCount: 256,
      priceHour: 250.0,
      priceDay: 1800.0,
      priceMonth: 45000.0,
      status: EquipmentStatus.available,
      category: 'Excavators',
      description:
          'High-performance hydraulic excavator perfect for medium to large construction projects.',
      specifications: {
        'Engine Power': '130 HP',
        'Bucket Capacity': '1.6 m³',
        'Digging Depth': '6.7 m',
        'Operating Weight': '32,000 kg',
        'Fuel Type': 'Diesel',
      },
      soilTypes: ['Clay', 'Sandy Soil', 'Rock'],
    ),
    Equipment(
      id: '2',
      name: 'JCB 3CX Backhoe Loader',
      company: 'JCB Ltd.',
      imageUrl:
          'https://images.unsplash.com/photo-1581092162562-40038e57b0e2?w=500&h=300&fit=crop',
      location: 'Los Angeles, CA',
      rating: 4.6,
      reviewCount: 189,
      priceHour: 180.0,
      priceDay: 1200.0,
      priceMonth: 32000.0,
      status: EquipmentStatus.available,
      category: 'Backhoe Loaders',
      description:
          'Versatile backhoe loader with powerful digging and loading capabilities.',
      specifications: {
        'Engine Power': '96 HP',
        'Bucket Capacity': '1.0 m³',
        'Digging Depth': '5.9 m',
        'Operating Weight': '18,500 kg',
        'Fuel Type': 'Diesel',
      },
      soilTypes: ['Clay', 'Sandy Soil', 'Gravel'],
    ),
    Equipment(
      id: '3',
      name: 'Komatsu D65PX Bulldozer',
      company: 'Komatsu Ltd.',
      imageUrl:
          'https://images.unsplash.com/photo-1590080876003-c373d7c6a8a0?w=500&h=300&fit=crop',
      location: 'Chicago, IL',
      rating: 4.9,
      reviewCount: 342,
      priceHour: 320.0,
      priceDay: 2200.0,
      priceMonth: 55000.0,
      status: EquipmentStatus.rented,
      category: 'Bulldozers',
      description:
          'Heavy-duty bulldozer for large-scale earthmoving and grading operations.',
      specifications: {
        'Engine Power': '215 HP',
        'Blade Width': '3.7 m',
        'Operating Weight': '36,800 kg',
        'Pushing Force': '450 kN',
        'Fuel Type': 'Diesel',
      },
      soilTypes: ['Clay', 'Rock', 'Compacted Soil'],
    ),
    Equipment(
      id: '4',
      name: 'Bobcat T770 Skid Steer',
      company: 'Bobcat Company',
      imageUrl:
          'https://images.unsplash.com/photo-1581091918360-dc6fd91f1e48?w=500&h=300&fit=crop',
      location: 'Houston, TX',
      rating: 4.5,
      reviewCount: 127,
      priceHour: 120.0,
      priceDay: 800.0,
      priceMonth: 20000.0,
      status: EquipmentStatus.available,
      category: 'Skid Steers',
      description:
          'Compact skid steer loader ideal for small construction sites and landscaping.',
      specifications: {
        'Engine Power': '74 HP',
        'Bucket Capacity': '0.75 m³',
        'Operating Weight': '4,070 kg',
        'Operating Height': '2.4 m',
        'Fuel Type': 'Diesel',
      },
      soilTypes: ['Sandy Soil', 'Gravel', 'Mulch'],
    ),
    Equipment(
      id: '5',
      name: 'Volvo L220H Wheel Loader',
      company: 'Volvo Construction Equipment',
      imageUrl:
          'https://images.unsplash.com/photo-1581092898010-c3c5f6faf5f0?w=500&h=300&fit=crop',
      location: 'Phoenix, AZ',
      rating: 4.7,
      reviewCount: 198,
      priceHour: 220.0,
      priceDay: 1600.0,
      priceMonth: 40000.0,
      status: EquipmentStatus.maintenance,
      category: 'Wheel Loaders',
      description:
          'Modern wheel loader with advanced hydraulics and fuel efficiency.',
      specifications: {
        'Engine Power': '160 HP',
        'Bucket Capacity': '2.2 m³',
        'Operating Weight': '22,000 kg',
        'Max Reach': '2.9 m',
        'Fuel Type': 'Diesel',
      },
      soilTypes: ['Clay', 'Gravel', 'Sandy Soil'],
    ),
    Equipment(
      id: '6',
      name: 'CASE 845C Motor Grader',
      company: 'CASE Construction Equipment',
      imageUrl:
          'https://images.unsplash.com/photo-1581092161562-40038e57b0e2?w=500&h=300&fit=crop',
      location: 'Miami, FL',
      rating: 4.4,
      reviewCount: 95,
      priceHour: 200.0,
      priceDay: 1400.0,
      priceMonth: 35000.0,
      status: EquipmentStatus.available,
      category: 'Motor Graders',
      description:
          'Precision motor grader for road construction and surface finishing.',
      specifications: {
        'Engine Power': '165 HP',
        'Blade Width': '3.7 m',
        'Operating Weight': '16,500 kg',
        'Operating Height': '2.8 m',
        'Fuel Type': 'Diesel',
      },
      soilTypes: ['Clay', 'Sandy Soil', 'Gravel'],
    ),
    Equipment(
      id: '7',
      name: 'Dynapac CC424 Roller',
      company: 'Dynapac AB',
      imageUrl:
          'https://images.unsplash.com/photo-1581091918360-dc6fd91f1e48?w=500&h=300&fit=crop',
      location: 'Denver, CO',
      rating: 4.6,
      reviewCount: 143,
      priceHour: 150.0,
      priceDay: 1000.0,
      priceMonth: 25000.0,
      status: EquipmentStatus.available,
      category: 'Rollers',
      description: 'Tandem vibratory roller for asphalt and soil compaction.',
      specifications: {
        'Engine Power': '98 HP',
        'Compaction Force': '155 kN',
        'Operating Weight': '7,500 kg',
        'Drum Width': '2.13 m',
        'Fuel Type': 'Diesel',
      },
      soilTypes: ['Clay', 'Sandy Soil', 'Asphalt'],
    ),
    Equipment(
      id: '8',
      name: 'Volvo FM 6x4 Dump Truck',
      company: 'Volvo Trucks',
      imageUrl:
          'https://images.unsplash.com/photo-1581092901356-87fd32e2dc1f?w=500&h=300&fit=crop',
      location: 'Seattle, WA',
      rating: 4.7,
      reviewCount: 267,
      priceHour: 180.0,
      priceDay: 1300.0,
      priceMonth: 32000.0,
      status: EquipmentStatus.available,
      category: 'Dump Trucks',
      description:
          'Heavy-duty dump truck for material transportation and site logistics.',
      specifications: {
        'Engine Power': '420 HP',
        'Cargo Capacity': '20 m³',
        'Gross Weight': '32,000 kg',
        'Transmission': 'Automatic 12-speed',
        'Fuel Type': 'Diesel',
      },
      soilTypes: ['All Types'],
    ),
    Equipment(
      id: '9',
      name: 'Hitachi ZX210LC Excavator',
      company: 'Hitachi Construction Machinery',
      imageUrl:
          'https://images.unsplash.com/photo-1581092918056-0c4c3acd3789?w=500&h=300&fit=crop',
      location: 'Boston, MA',
      rating: 4.8,
      reviewCount: 213,
      priceHour: 240.0,
      priceDay: 1700.0,
      priceMonth: 42000.0,
      status: EquipmentStatus.available,
      category: 'Excavators',
      description:
          'Reliable mid-size excavator with excellent fuel efficiency.',
      specifications: {
        'Engine Power': '128 HP',
        'Bucket Capacity': '1.2 m³',
        'Digging Depth': '6.4 m',
        'Operating Weight': '21,000 kg',
        'Fuel Type': 'Diesel',
      },
      soilTypes: ['Clay', 'Sandy Soil', 'Rock'],
    ),
    Equipment(
      id: '10',
      name: 'Ford 550 Super Duty Backhoe',
      company: 'Ford Motor Company',
      imageUrl:
          'https://images.unsplash.com/photo-1581092162562-40038e57b0e2?w=500&h=300&fit=crop',
      location: 'Austin, TX',
      rating: 4.3,
      reviewCount: 78,
      priceHour: 130.0,
      priceDay: 900.0,
      priceMonth: 22000.0,
      status: EquipmentStatus.available,
      category: 'Backhoe Loaders',
      description:
          'Durable backhoe loader for small to medium construction projects.',
      specifications: {
        'Engine Power': '110 HP',
        'Bucket Capacity': '0.9 m³',
        'Digging Depth': '5.5 m',
        'Operating Weight': '17,000 kg',
        'Fuel Type': 'Diesel',
      },
      soilTypes: ['Clay', 'Sandy Soil', 'Gravel'],
    ),
  ];

  static final List<String> categories = [
    'All',
    'Excavators',
    'Backhoe Loaders',
    'Bulldozers',
    'Skid Steers',
    'Wheel Loaders',
    'Motor Graders',
    'Rollers',
    'Dump Trucks',
  ];

  static final List<String> statuses = [
    'All',
    'Available',
    'Rented',
    'Under Maintenance',
  ];

  static final List<String> companies = [
    'Caterpillar Inc.',
    'JCB Ltd.',
    'Komatsu Ltd.',
    'Bobcat Company',
    'Volvo Construction Equipment',
    'CASE Construction Equipment',
    'Dynapac AB',
    'Volvo Trucks',
    'Hitachi Construction Machinery',
    'Ford Motor Company',
  ];

  static final List<String> soilTypeOptions = [
    'Clay',
    'Sandy Soil',
    'Gravel',
    'Rock',
    'Compacted Soil',
    'Mulch',
  ];

  static final List<String> locations = [
    'New York, NY',
    'Los Angeles, CA',
    'Chicago, IL',
    'Houston, TX',
    'Phoenix, AZ',
    'Miami, FL',
    'Denver, CO',
    'Seattle, WA',
    'Boston, MA',
    'Austin, TX',
  ];

  static final List<String> projectTypes = [
    'Residential Construction',
    'Commercial Development',
    'Road Construction',
    'Demolition',
    'Landscaping',
    'Mining',
    'Infrastructure',
    'Land Clearing',
  ];

  /// Get equipment by category
  static List<Equipment> getByCategory(String category) {
    if (category == 'All') return equipmentList;
    return equipmentList.where((e) => e.category == category).toList();
  }

  /// Get equipment by status
  static List<Equipment> getByStatus(String status) {
    switch (status) {
      case 'Available':
        return equipmentList
            .where((e) => e.status == EquipmentStatus.available)
            .toList();
      case 'Rented':
        return equipmentList
            .where((e) => e.status == EquipmentStatus.rented)
            .toList();
      case 'Under Maintenance':
        return equipmentList
            .where((e) => e.status == EquipmentStatus.maintenance)
            .toList();
      default:
        return equipmentList;
    }
  }

  /// Filter equipment based on multiple criteria
  static List<Equipment> filterEquipment({
    String? category,
    String? status,
    String? company,
    String? location,
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
  }) {
    List<Equipment> filtered = List.from(equipmentList);

    if (category != null && category != 'All') {
      filtered = filtered.where((e) => e.category == category).toList();
    }

    if (status != null && status != 'All') {
      filtered = filtered.where((e) => e.status.displayName == status).toList();
    }

    if (company != null) {
      filtered = filtered.where((e) => e.company == company).toList();
    }

    if (location != null) {
      filtered = filtered.where((e) => e.location == location).toList();
    }

    if (minPrice != null) {
      filtered = filtered.where((e) => e.priceHour >= minPrice).toList();
    }

    if (maxPrice != null) {
      filtered = filtered.where((e) => e.priceHour <= maxPrice).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (e) =>
                e.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                e.company.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    return filtered;
  }

  /// Get recommended equipment based on project parameters
  static List<Equipment> getRecommendations({
    String? projectType,
    String? soilType,
    double? diggingDepth,
    double? maxBudget,
  }) {
    List<Equipment> recommended = List.from(equipmentList);

    if (maxBudget != null) {
      recommended = recommended.where((e) => e.priceHour <= maxBudget).toList();
    }

    if (soilType != null && soilType.isNotEmpty) {
      recommended = recommended
          .where((e) => e.soilTypes.contains(soilType))
          .toList();
    }

    /// Sort by rating (descending) and take top 5
    recommended.sort((a, b) => b.rating.compareTo(a.rating));
    return recommended.take(5).toList();
  }
}
