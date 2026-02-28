import 'package:flutter/material.dart';
import '../widgets/custom_widgets.dart';
import '../models/equipment_models.dart';

class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({super.key});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  final List<Equipment> equipmentList = [
    Equipment(
      id: '1',
      name: 'JCB 3DX',
      type: 'Backhoe Loader',
      imageUrl: 'assets/construction_truck.svg',
      status: 'Available',
      location: 'Delhi',
      rentPerHour: 1200,
      rentPerDay: 8000,
      operatorName: 'Rajesh Kumar',
      operatorPhone: '+91 9876543210',
      specifications: ['3.5 Ton', '24 HP Engine', 'Hydraulic'],
      documents: ['RC', 'Insurance', 'Pollution'],
      lastServiceDate: DateTime.now().subtract(const Duration(days: 15)),
      currentBookingId: '',
    ),
    Equipment(
      id: '2',
      name: 'Excavator CAT 320',
      type: 'Hydraulic Excavator',
      imageUrl: 'assets/construction_truck.svg',
      status: 'Busy',
      location: 'Gurugram',
      rentPerHour: 2000,
      rentPerDay: 15000,
      operatorName: 'Amit Singh',
      operatorPhone: '+91 9876543211',
      specifications: ['20 Ton', '110 HP Engine', 'AWS'],
      documents: ['RC', 'Insurance', 'Pollution'],
      lastServiceDate: DateTime.now().subtract(const Duration(days: 30)),
      currentBookingId: 'BK001',
    ),
    Equipment(
      id: '3',
      name: 'Wheel Loader',
      type: 'Front Loader',
      imageUrl: 'assets/construction_truck.svg',
      status: 'Maintenance',
      location: 'Delhi',
      rentPerHour: 1500,
      rentPerDay: 10000,
      operatorName: 'Vikram Patel',
      operatorPhone: '+91 9876543212',
      specifications: ['5 Ton', '95 HP Engine', 'Manual'],
      documents: ['RC', 'Insurance', 'Pollution'],
      lastServiceDate: DateTime.now().subtract(const Duration(days: 5)),
      currentBookingId: '',
    ),
    Equipment(
      id: '4',
      name: 'Concrete Mixer',
      type: 'Construction Equipment',
      imageUrl: 'assets/construction_truck.svg',
      status: 'Available',
      location: 'Noida',
      rentPerHour: 500,
      rentPerDay: 3000,
      operatorName: 'Pradeep Rao',
      operatorPhone: '+91 9876543213',
      specifications: ['350L', '15 HP Engine', 'Electric'],
      documents: ['RC', 'Insurance'],
      lastServiceDate: DateTime.now().subtract(const Duration(days: 10)),
      currentBookingId: '',
    ),
    Equipment(
      id: '5',
      name: 'Dumper Truck',
      type: 'Heavy Vehicle',
      imageUrl: 'assets/construction_truck.svg',
      status: 'Available',
      location: 'Delhi',
      rentPerHour: 1000,
      rentPerDay: 6500,
      operatorName: 'Mohan Singh',
      operatorPhone: '+91 9876543214',
      specifications: ['10 Ton', '85 HP Engine', 'Automatic'],
      documents: ['RC', 'Insurance', 'Pollution'],
      lastServiceDate: DateTime.now().subtract(const Duration(days: 20)),
      currentBookingId: '',
    ),
  ];

  List<Equipment> getFilteredEquipment() {
    List<Equipment> filtered = equipmentList;

    if (_selectedFilter != 'All') {
      filtered = filtered.where((e) => e.status == _selectedFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (e) =>
                e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                e.type.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredEquipment = getFilteredEquipment();

    return Scaffold(
      appBar: const TopAppBar(title: 'Equipment', showNotification: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 16),

            // Filter Buttons
            _buildFilterButtons(),
            const SizedBox(height: 16),

            // Equipment Count
            Text(
              '${filteredEquipment.length} Equipment Found',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),

            // Equipment List
            if (filteredEquipment.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.construction_outlined,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No equipment found',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: filteredEquipment
                    .map(
                      (equipment) => EquipmentCard(
                        name: equipment.name,
                        type: equipment.type,
                        status: equipment.status,
                        location: equipment.location,
                        rentPerDay: equipment.rentPerDay,
                        imageUrl: equipment.imageUrl,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EquipmentDetailScreen(equipment: equipment),
                            ),
                          );
                        },
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Add new equipment')));
        },
        backgroundColor: const Color(0xFFFF6B35),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search equipment...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildFilterButtons() {
    final filters = ['All', 'Available', 'Busy', 'Maintenance'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters
            .map(
              (filter) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter),
                  selected: _selectedFilter == filter,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  backgroundColor: Colors.grey[100],
                  selectedColor: const Color(0xFFFF6B35),
                  labelStyle: TextStyle(
                    color: _selectedFilter == filter
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class EquipmentDetailScreen extends StatelessWidget {
  final Equipment equipment;

  const EquipmentDetailScreen({required this.equipment, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(
        title: equipment.name,
        showBackButton: true,
        showNotification: false,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Equipment Image
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: const Icon(
                Icons.construction,
                size: 100,
                color: Color(0xFFFF6B35),
              ),
            ),
            const SizedBox(height: 16),

            // Machine Details
            _buildDetailSection(
              title: 'Equipment Details',
              child: Column(
                children: [
                  _buildDetailRow('Type', equipment.type),
                  _buildDetailRow('Status', equipment.status),
                  _buildDetailRow('Location', equipment.location),
                  _buildDetailRow('Rent (Hourly)', '₹${equipment.rentPerHour}'),
                  _buildDetailRow('Rent (Daily)', '₹${equipment.rentPerDay}'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Operator Details
            _buildDetailSection(
              title: 'Operator Details',
              child: Column(
                children: [
                  _buildDetailRow('Name', equipment.operatorName),
                  _buildDetailRow('Phone', equipment.operatorPhone),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Specifications
            _buildDetailSection(
              title: 'Specifications',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: equipment.specifications
                    .map(
                      (spec) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Color(0xFFFF6B35),
                            ),
                            const SizedBox(width: 8),
                            Text(spec),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Service History
            _buildDetailSection(
              title: 'Service History',
              child: Column(
                children: [
                  _buildDetailRow(
                    'Last Service',
                    '${equipment.lastServiceDate.day}/${equipment.lastServiceDate.month}/${equipment.lastServiceDate.year}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Book equipment')),
                      );
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Book Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit equipment')),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
