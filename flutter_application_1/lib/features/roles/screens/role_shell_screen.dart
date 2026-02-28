import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../auth/models/account_type.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/role_provider.dart';

class RoleShellScreen extends StatelessWidget {
  const RoleShellScreen({super.key});

  Widget _buildByAccountType(AccountType? accountType) {
    switch (accountType) {
      case AccountType.owner:
        return const ProviderNavigationScreen();
      case AccountType.hirer:
        return const ContractorNavigationScreen();
      case AccountType.manufacturer:
        return const CompanyNavigationScreen();
      case null:
        return const ProviderNavigationScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoleProvider>(
      builder: (context, roleProvider, _) {
        final role = roleProvider.selectedRole;
        if (role == null) {
          final accountType = context.read<AuthProvider>().currentAccountType;
          return _buildByAccountType(accountType);
        }

        switch (role) {
          case UserRole.provider:
            return const ProviderNavigationScreen();
          case UserRole.contractor:
            return const ContractorNavigationScreen();
          case UserRole.company:
            return const CompanyNavigationScreen();
        }
      },
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: const Center(child: Text('Use the + button to post your service.')),
    );
  }
}

class _RoleOptionCard extends StatelessWidget {
  const _RoleOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: AppSizes.paddingLarge),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSizes.paddingXSmall),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}

class ProviderNavigationScreen extends StatefulWidget {
  const ProviderNavigationScreen({super.key});

  @override
  State<ProviderNavigationScreen> createState() =>
      _ProviderNavigationScreenState();
}

class _ProviderNavigationScreenState extends State<ProviderNavigationScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const screens = [
      ProviderDashboardScreen(),
      ProviderRequestsScreen(),
      ProviderHistoryScreen(),
      ProviderAnalyticsScreen(),
      RoleProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Panel'),
        actions: [
          IconButton(
            onPressed: () => context.read<RoleProvider>().clearRole(),
            icon: const Icon(Icons.swap_horiz),
          ),
        ],
      ),
      body: screens[_index],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const PostServiceScreen()));
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class ProviderDashboardScreen extends StatelessWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      children: [
        Text(
          'Hi, Provider 👋',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSizes.paddingLarge),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          childAspectRatio: 1.8,
          crossAxisSpacing: AppSizes.paddingMedium,
          mainAxisSpacing: AppSizes.paddingMedium,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            _StatCard(label: 'Total Equipment', value: '48'),
            _StatCard(label: 'Available', value: '31'),
            _StatCard(label: 'Rented', value: '13'),
            _StatCard(label: 'Requests', value: '6'),
          ],
        ),
        const SizedBox(height: AppSizes.paddingLarge),
        Text('Equipment List', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSizes.paddingMedium),
        ...const [
          _EquipmentCard(name: 'JCB 3DX', status: 'Available'),
          _EquipmentCard(name: 'CAT D6R', status: 'Rented'),
          _EquipmentCard(name: 'Hydraulic Crane 20T', status: 'Maintenance'),
        ],
      ],
    );
  }
}

class AddEditEquipmentScreen extends StatelessWidget {
  const AddEditEquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add / Edit Equipment')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.image_outlined),
            label: const Text('Upload Image'),
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          const TextField(
            decoration: InputDecoration(labelText: 'Equipment Name'),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          const TextField(decoration: InputDecoration(labelText: 'Company')),
          const SizedBox(height: AppSizes.paddingMedium),
          const TextField(
            maxLines: 3,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          const TextField(
            maxLines: 3,
            decoration: InputDecoration(labelText: 'Specifications'),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          const TextField(
            decoration: InputDecoration(labelText: 'Price per day'),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Status: Available'),
          ),
          const SizedBox(height: AppSizes.paddingXLarge),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class PostServiceScreen extends StatelessWidget {
  const PostServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Service')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          const TextField(
            decoration: InputDecoration(labelText: 'Service Title'),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          const TextField(decoration: InputDecoration(labelText: 'Category')),
          const SizedBox(height: AppSizes.paddingMedium),
          const TextField(
            maxLines: 4,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          const TextField(decoration: InputDecoration(labelText: 'Price')),
          const SizedBox(height: AppSizes.paddingXLarge),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Post Service'),
          ),
        ],
      ),
    );
  }
}

class ProviderRequestsScreen extends StatelessWidget {
  const ProviderRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      children: const [
        _RequestCard(
          contractor: 'Kale Infra',
          equipment: 'JCB 3DX',
          duration: '5 days',
        ),
        SizedBox(height: AppSizes.paddingMedium),
        _RequestCard(
          contractor: 'Samarth Builders',
          equipment: 'Crane 20T',
          duration: '12 days',
        ),
      ],
    );
  }
}

class ProviderHistoryScreen extends StatelessWidget {
  const ProviderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Provider rental history'));
  }
}

class ProviderAnalyticsScreen extends StatelessWidget {
  const ProviderAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      children: const [
        _StatCard(label: 'Most Rented', value: 'JCB 3DX'),
        SizedBox(height: AppSizes.paddingMedium),
        _StatCard(label: 'Monthly Revenue', value: '₹4.2L'),
        SizedBox(height: AppSizes.paddingMedium),
        _StatCard(label: 'Utilization %', value: '72%'),
      ],
    );
  }
}

class ContractorNavigationScreen extends StatefulWidget {
  const ContractorNavigationScreen({super.key});

  @override
  State<ContractorNavigationScreen> createState() =>
      _ContractorNavigationScreenState();
}

class _ContractorNavigationScreenState
    extends State<ContractorNavigationScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const screens = [
      ContractorDashboardScreen(),
      SmartRecommendationScreen(),
      ContractorHistoryScreen(),
      ContractorNotificationScreen(),
      RoleProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contractor Panel'),
        actions: [
          IconButton(
            onPressed: () => context.read<RoleProvider>().clearRole(),
            icon: const Icon(Icons.swap_horiz),
          ),
        ],
      ),
      body: screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: 'Recommend',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notification',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class ContractorDashboardScreen extends StatelessWidget {
  const ContractorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = ['Excavator', 'Bulldozer', 'Crane', 'Loader'];
    return ListView(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      children: [
        const Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search equipment',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            SizedBox(width: AppSizes.paddingSmall),
            Icon(Icons.filter_list),
          ],
        ),
        const SizedBox(height: AppSizes.paddingLarge),
        Text('Categories', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSizes.paddingMedium),
        GridView.builder(
          shrinkWrap: true,
          itemCount: categories.length,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            crossAxisSpacing: AppSizes.paddingMedium,
            mainAxisSpacing: AppSizes.paddingMedium,
          ),
          itemBuilder: (_, index) =>
              Card(child: Center(child: Text(categories[index]))),
        ),
        const SizedBox(height: AppSizes.paddingLarge),
        Text(
          'Recommended Equipment',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        ...const [
          _EquipmentCard(name: 'Komatsu PC210', status: 'Available'),
          _EquipmentCard(name: 'Volvo EC220', status: 'Available'),
        ],
      ],
    );
  }
}

class SmartRecommendationScreen extends StatelessWidget {
  const SmartRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      children: [
        Text(
          'Smart Recommendation',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        const TextField(decoration: InputDecoration(labelText: 'Soil Type')),
        const SizedBox(height: AppSizes.paddingMedium),
        const TextField(decoration: InputDecoration(labelText: 'Area (sq.ft)')),
        const SizedBox(height: AppSizes.paddingMedium),
        const TextField(decoration: InputDecoration(labelText: 'Depth (ft)')),
        const SizedBox(height: AppSizes.paddingMedium),
        const TextField(
          decoration: InputDecoration(labelText: 'Bucket Capacity'),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        const TextField(decoration: InputDecoration(labelText: 'Engine Power')),
        const SizedBox(height: AppSizes.paddingMedium),
        Text('Price Range', style: Theme.of(context).textTheme.titleMedium),
        Slider(value: 5000, min: 1000, max: 20000, onChanged: (_) {}),
        const SizedBox(height: AppSizes.paddingMedium),
        ElevatedButton(onPressed: () {}, child: const Text('Recommend')),
        const SizedBox(height: AppSizes.paddingLarge),
        const _StatCard(label: 'Top Match Company', value: 'Shree Equipments'),
        const SizedBox(height: AppSizes.paddingMedium),
        const _EquipmentCard(name: 'Hitachi ZX210', status: 'Available'),
      ],
    );
  }
}

class ContractorHistoryScreen extends StatelessWidget {
  const ContractorHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      children: [
        ListTile(
          tileColor: AppColors.surfaceLight,
          title: const Text('Booking #B1024'),
          subtitle: const Text('JCB 3DX • 7 days'),
          trailing: ElevatedButton(
            onPressed: () {},
            child: const Text('Compare'),
          ),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        ListTile(
          tileColor: AppColors.surfaceLight,
          title: const Text('Booking #B1051'),
          subtitle: const Text('Crane 20T • 3 days'),
          trailing: ElevatedButton(onPressed: () {}, child: const Text('Book')),
        ),
      ],
    );
  }
}

class ContractorNotificationScreen extends StatelessWidget {
  const ContractorNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No new notifications'));
  }
}

class CompanyNavigationScreen extends StatefulWidget {
  const CompanyNavigationScreen({super.key});

  @override
  State<CompanyNavigationScreen> createState() =>
      _CompanyNavigationScreenState();
}

class _CompanyNavigationScreenState extends State<CompanyNavigationScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const screens = [
      CompanyModelsScreen(),
      CompanyExhibitionScreen(),
      CompanyAnalyticsScreen(),
      RoleProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Panel'),
        actions: [
          IconButton(
            onPressed: () => context.read<RoleProvider>().clearRole(),
            icon: const Icon(Icons.swap_horiz),
          ),
        ],
      ),
      body: screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.view_list), label: 'Models'),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Exhibition',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class CompanyModelsScreen extends StatelessWidget {
  const CompanyModelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AddModelScreen()));
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Model'),
        ),
        const SizedBox(height: AppSizes.paddingLarge),
        const _EquipmentCard(name: 'CAT 320D', status: 'Active'),
        const _EquipmentCard(name: 'Komatsu WA200', status: 'Active'),
      ],
    );
  }
}

class AddModelScreen extends StatelessWidget {
  const AddModelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Model')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          const TextField(decoration: InputDecoration(labelText: 'Model Name')),
          const SizedBox(height: AppSizes.paddingMedium),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.image),
            label: const Text('Upload Images'),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          const TextField(
            maxLines: 3,
            decoration: InputDecoration(labelText: 'Specifications'),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Upload Brochure'),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          const TextField(
            maxLines: 4,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: AppSizes.paddingXLarge),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class CompanyExhibitionScreen extends StatelessWidget {
  const CompanyExhibitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      children: const [
        _StatCard(label: 'Exhibition Banner', value: 'Summer 2026 Campaign'),
        SizedBox(height: AppSizes.paddingMedium),
        _StatCard(label: 'Featured Models', value: '12'),
      ],
    );
  }
}

class CompanyAnalyticsScreen extends StatelessWidget {
  const CompanyAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      children: const [
        _StatCard(label: 'Model Views', value: '18,420'),
        SizedBox(height: AppSizes.paddingMedium),
        _StatCard(label: 'Leads Generated', value: '1,128'),
      ],
    );
  }
}

class RoleProfileScreen extends StatelessWidget {
  const RoleProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            size: AppSizes.iconXLarge,
            color: AppColors.primary,
          ),
          SizedBox(height: AppSizes.paddingSmall),
          Text('Profile'),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}

class _EquipmentCard extends StatelessWidget {
  const _EquipmentCard({required this.name, required this.status});

  final String name;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            color: AppColors.surfaceAlt,
          ),
          child: const Icon(Icons.precision_manufacturing),
        ),
        title: Text(name),
        subtitle: _StatusChip(status: status),
        trailing: const Icon(Icons.edit_outlined),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color = normalized == 'available'
        ? AppColors.available
        : normalized == 'rented' || normalized == 'busy'
        ? AppColors.rented
        : AppColors.maintenance;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: AppSizes.paddingXSmall),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingXSmall,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.18),
          borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
          border: Border.all(color: color),
        ),
        child: Text(
          status,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.contractor,
    required this.equipment,
    required this.duration,
  });

  final String contractor;
  final String equipment;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contractor, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSizes.paddingSmall),
            Text('Equipment: $equipment'),
            Text('Duration: $duration'),
            const SizedBox(height: AppSizes.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Accept'),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Reject'),
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
