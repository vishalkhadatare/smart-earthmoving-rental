import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_widgets.dart';
import '../models/equipment_models.dart';

class HomeScreenRedesigned extends StatefulWidget {
  const HomeScreenRedesigned({super.key});

  @override
  State<HomeScreenRedesigned> createState() => _HomeScreenRedesignedState();
}

class _HomeScreenRedesignedState extends State<HomeScreenRedesigned> {
  final DashboardMetrics metrics = DashboardMetrics(
    totalMachines: 12,
    activeMachines: 8,
    availableMachines: 3,
    activeJobs: 5,
    earningsToday: 15500,
    earningsWeekly: 98000,
    earningsMonthly: 425000,
    pendingPayments: 45000,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(
        title: 'Dashboard',
        showNotification: true,
        onNotificationPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No new notifications')));
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section
            _buildGreetingSection(),
            const SizedBox(height: 24),

            // Summary Cards
            _buildSummaryCards(),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildQuickActions(),
            const SizedBox(height: 24),

            // Recent Bookings
            Text(
              'Recent Bookings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildRecentBookings(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? user?.email ?? 'User';
    final userEmail = user?.email ?? 'equipment.manager@seemp.com';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B35), Color(0xFFFF8555)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back! 👋',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            userEmail,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Today\'s Summary', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            DashboardCard(
              title: 'Total Machines',
              value: metrics.totalMachines.toString(),
              icon: Icons.construction,
              backgroundColor: const Color(0xFFFF6B35),
            ),
            DashboardCard(
              title: 'Active Jobs',
              value: metrics.activeJobs.toString(),
              icon: Icons.work_outline,
              backgroundColor: Colors.blue,
            ),
            DashboardCard(
              title: 'Available',
              value: metrics.availableMachines.toString(),
              icon: Icons.check_circle,
              backgroundColor: Colors.green,
            ),
            DashboardCard(
              title: 'Earnings Today',
              value: '₹${metrics.earningsToday ~/ 1000}K',
              icon: Icons.attach_money,
              backgroundColor: Colors.purple,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_outlined, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Pending Payments: ₹${metrics.pendingPayments.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          QuickActionButton(
            icon: Icons.add_circle_outline,
            label: 'Add Equipment',
            color: const Color(0xFFFF6B35),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigate to add equipment')),
              );
            },
          ),
          const SizedBox(width: 16),
          QuickActionButton(
            icon: Icons.calendar_today_outlined,
            label: 'Book Equipment',
            color: Colors.blue,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigate to create booking')),
              );
            },
          ),
          const SizedBox(width: 16),
          QuickActionButton(
            icon: Icons.location_on_outlined,
            label: 'Track Machine',
            color: Colors.green,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigate to GPS tracking')),
              );
            },
          ),
          const SizedBox(width: 16),
          QuickActionButton(
            icon: Icons.receipt_outlined,
            label: 'Invoice',
            color: Colors.purple,
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Generate invoice')));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBookings() {
    final bookings = [
      {
        'machine': 'JCB 3DX',
        'client': 'Kumar Construction',
        'time': '09:00 - 17:00',
        'location': 'Delhi',
        'status': 'Active',
      },
      {
        'machine': 'Excavator CAT 320',
        'client': 'Sharma Builders',
        'time': '10:00 - 18:00',
        'location': 'Gurugram',
        'status': 'Upcoming',
      },
      {
        'machine': 'Wheel Loader',
        'client': 'Delhi Metro',
        'time': '08:00 - 16:00',
        'location': 'Delhi',
        'status': 'Active',
      },
    ];

    return Column(
      children: bookings
          .map(
            (booking) => BookingCard(
              machineName: booking['machine'] ?? '',
              clientName: booking['client'] ?? '',
              startTime: booking['time']?.toString().split(' - ')[0] ?? '',
              endTime: booking['time']?.toString().split(' - ')[1] ?? '',
              location: booking['location'] ?? '',
              status: booking['status'] ?? '',
            ),
          )
          .toList(),
    );
  }
}
