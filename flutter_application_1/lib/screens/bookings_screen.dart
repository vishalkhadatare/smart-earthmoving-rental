import 'package:flutter/material.dart';
import '../widgets/custom_widgets.dart';
import '../models/equipment_models.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  String _selectedTab = 'Upcoming';

  final List<Booking> bookings = [
    Booking(
      id: 'BK001',
      machineId: '1',
      machineName: 'JCB 3DX',
      clientName: 'Kumar Construction',
      clientPhone: '+91 9876543220',
      clientEmail: 'kumar@email.com',
      startTime: DateTime.now().add(const Duration(hours: 2)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      location: 'Delhi',
      status: 'Upcoming',
      totalCost: 64000,
      workDescription: 'Foundation digging for residential complex',
      isTimeTracked: true,
    ),
    Booking(
      id: 'BK002',
      machineId: '2',
      machineName: 'Excavator CAT 320',
      clientName: 'Sharma Builders',
      clientPhone: '+91 9876543221',
      clientEmail: 'sharma@email.com',
      startTime: DateTime.now().subtract(const Duration(hours: 2)),
      endTime: DateTime.now().add(const Duration(hours: 6)),
      location: 'Gurugram',
      status: 'Active',
      totalCost: 120000,
      workDescription: 'Earthmoving for highway construction',
      isTimeTracked: true,
    ),
    Booking(
      id: 'BK003',
      machineId: '3',
      machineName: 'Wheel Loader',
      clientName: 'Delhi Metro',
      clientPhone: '+91 9876543222',
      clientEmail: 'metro@email.com',
      startTime: DateTime.now().subtract(const Duration(days: 2, hours: 8)),
      endTime: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
      location: 'Delhi',
      status: 'Completed',
      totalCost: 80000,
      workDescription: 'Material loading and unloading',
      isTimeTracked: false,
    ),
  ];

  List<Booking> getFilteredBookings() {
    return bookings.where((b) => b.status == _selectedTab).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredBookings = getFilteredBookings();

    return Scaffold(
      appBar: const TopAppBar(title: 'Bookings & Jobs', showNotification: false),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: ['Upcoming', 'Active', 'Completed']
                    .map(
                      (tab) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(tab),
                          selected: _selectedTab == tab,
                          onSelected: (selected) {
                            setState(() {
                              _selectedTab = tab;
                            });
                          },
                          backgroundColor: Colors.grey[100],
                          selectedColor: const Color(0xFFFF6B35),
                          labelStyle: TextStyle(
                            color: _selectedTab == tab
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const Divider(height: 1),

          // Booking List
          Expanded(
            child: filteredBookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No ${_selectedTab.toLowerCase()} bookings',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BookingDetailScreen(booking: booking),
                            ),
                          );
                        },
                        child: BookingCard(
                          machineName: booking.machineName,
                          clientName: booking.clientName,
                          startTime:
                              '${booking.startTime.hour}:${booking.startTime.minute.toString().padLeft(2, '0')}',
                          endTime:
                              '${booking.endTime.hour}:${booking.endTime.minute.toString().padLeft(2, '0')}',
                          location: booking.location,
                          status: booking.status,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Create new booking')));
        },
        backgroundColor: const Color(0xFFFF6B35),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class BookingDetailScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailScreen({required this.booking, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(
        title: 'Booking Details',
        showBackButton: true,
        showNotification: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFF6B35).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.machineName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Booking ID: ${booking.id}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: booking.status == 'Active'
                              ? Colors.green.withOpacity(0.2)
                              : const Color(0xFFFF6B35).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          booking.status,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: booking.status == 'Active'
                                ? Colors.green
                                : const Color(0xFFFF6B35),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Time',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${booking.startTime.day}/${booking.startTime.month} ${booking.startTime.hour}:${booking.startTime.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.arrow_forward, color: Colors.grey[400]),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'End Time',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${booking.endTime.day}/${booking.endTime.month} ${booking.endTime.hour}:${booking.endTime.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Client Details
            Text(
              'Client Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Name', booking.clientName),
                  _buildDetailRow('Phone', booking.clientPhone),
                  _buildDetailRow('Email', booking.clientEmail),
                  _buildDetailRow('Location', booking.location),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Work Description
            Text(
              'Work Description',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                booking.workDescription,
                style: const TextStyle(height: 1.6),
              ),
            ),
            const SizedBox(height: 16),

            // Total Cost
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Cost',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '₹${booking.totalCost.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            if (booking.status == 'Active')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Job completed')),
                    );
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('End Job'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
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
