import 'package:flutter/material.dart';
import '../widgets/custom_widgets.dart';
import '../models/equipment_models.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final List<Payment> payments = [
    Payment(
      id: 'PAY001',
      clientName: 'Kumar Construction',
      amount: 64000,
      date: DateTime.now(),
      status: 'Paid',
      description: 'JCB 3DX - 8 hours rental',
      bookingId: 'BK001',
    ),
    Payment(
      id: 'PAY002',
      clientName: 'Sharma Builders',
      amount: 120000,
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: 'Pending',
      description: 'Excavator CAT 320 - 2 days rental',
      bookingId: 'BK002',
    ),
    Payment(
      id: 'PAY003',
      clientName: 'Delhi Metro',
      amount: 80000,
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: 'Paid',
      description: 'Wheel Loader - Complete job',
      bookingId: 'BK003',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final totalPending = payments
        .where((p) => p.status == 'Pending')
        .fold<double>(0, (sum, p) => sum + p.amount);

    final totalToday = payments
        .where(
          (p) =>
              p.date.year == DateTime.now().year &&
              p.date.month == DateTime.now().month &&
              p.date.day == DateTime.now().day,
        )
        .fold<double>(0, (sum, p) => sum + p.amount);

    return Scaffold(
      appBar: const TopAppBar(title: 'Payments', showNotification: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue Summary
            Text(
              'Revenue Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                DashboardCard(
                  title: 'Today',
                  value: '₹${totalToday ~/ 1000}K',
                  icon: Icons.today,
                  backgroundColor: Colors.green,
                ),
                DashboardCard(
                  title: 'Pending',
                  value: '₹${totalPending ~/ 1000}K',
                  icon: Icons.hourglass_empty,
                  backgroundColor: Colors.orange,
                ),
                const DashboardCard(
                  title: 'Weekly',
                  value: '₹245K',
                  icon: Icons.date_range,
                  backgroundColor: Colors.blue,
                ),
                const DashboardCard(
                  title: 'Monthly',
                  value: '₹980K',
                  icon: Icons.calendar_month,
                  backgroundColor: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transactions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filter transactions')),
                    );
                  },
                  child: const Text('Filter'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Payment Cards
            Column(
              children: payments
                  .map(
                    (payment) => PaymentCard(
                      clientName: payment.clientName,
                      amount: payment.amount.toStringAsFixed(0),
                      status: payment.status,
                      date:
                          '${payment.date.day}/${payment.date.month}/${payment.date.year}',
                      description: payment.description,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Generate invoice')),
                      );
                    },
                    icon: const Icon(Icons.receipt),
                    label: const Text('Invoice'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Download report')),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
}
