import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/chip_selector.dart';
import '../../../core/widgets/equipment_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../filter/screens/filter_bottom_sheet.dart';
import '../providers/home_provider.dart';

/// Equipment list screen - Home tab with tabs for Equipment, Requests, History, Analytics, Purchase
class EquipmentListScreen extends StatefulWidget {
  const EquipmentListScreen({super.key});

  @override
  State<EquipmentListScreen> createState() => _EquipmentListScreenState();
}

class _EquipmentListScreenState extends State<EquipmentListScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusXXLarge),
          topRight: Radius.circular(AppSizes.radiusXXLarge),
        ),
      ),
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        leading: const Padding(
          padding: EdgeInsets.only(left: AppSizes.paddingLarge),
          child: Center(
            child: Icon(
              Icons.construction,
              color: AppColors.primary,
              size: AppSizes.iconMedium,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.paddingLarge),
            child: Center(
              child: GestureDetector(
                onTap: () => _showFilterBottomSheet(context),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.menu,
                    color: AppColors.textPrimary,
                    size: AppSizes.iconMedium,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                /// Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowDark,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      context.read<HomeProvider>().updateSearchQuery(value);
                    },
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: AppStrings.searchEquipment,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusLarge,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.primary,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _searchController.clear();
                                context.read<HomeProvider>().updateSearchQuery(
                                  '',
                                );
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXLarge),

                /// Category Chips
                Text(
                  'Category',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                Consumer<HomeProvider>(
                  builder: (context, provider, child) {
                    return ChipSelector(
                      items: const [
                        'All',
                        'Excavators',
                        'Backhoe Loaders',
                        'Bulldozers',
                        'Skid Steers',
                        'Wheel Loaders',
                        'Motor Graders',
                        'Rollers',
                        'Dump Trucks',
                      ],
                      selectedItem: provider.selectedCategory,
                      onSelected: (category) {
                        context.read<HomeProvider>().updateCategory(category);
                      },
                    );
                  },
                ),
                const SizedBox(height: AppSizes.paddingXLarge),

                /// Status Chips
                Text('Status', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSizes.paddingMedium),
                Consumer<HomeProvider>(
                  builder: (context, provider, child) {
                    return ChipSelector(
                      items: const [
                        'All',
                        'Available',
                        'Rented',
                        'Under Maintenance',
                      ],
                      selectedItem: provider.selectedStatus,
                      onSelected: (status) {
                        context.read<HomeProvider>().updateStatus(status);
                      },
                    );
                  },
                ),
                const SizedBox(height: AppSizes.paddingXLarge),

                /// Equipment Grid
                Consumer<HomeProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const ShimmerLoadingGrid(itemCount: 3);
                    }

                    if (provider.filteredEquipment.isEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.search_off,
                        title: AppStrings.noEquipmentFound,
                        subtitle: AppStrings.tryAdjustingFilters,
                        onRetry: () {
                          provider.resetFilters();
                        },
                        retryLabel: 'Clear Filters',
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${provider.filteredEquipment.length} equipment available',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSizes.paddingLarge),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.filteredEquipment.length,
                          itemBuilder: (context, index) {
                            final equipment = provider.filteredEquipment[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSizes.paddingLarge,
                              ),
                              child: EquipmentCard(
                                equipment: equipment,
                                onViewDetails: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/equipment-details',
                                    arguments: equipment,
                                  );
                                },
                                onCompare: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${equipment.name} added to comparison',
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
