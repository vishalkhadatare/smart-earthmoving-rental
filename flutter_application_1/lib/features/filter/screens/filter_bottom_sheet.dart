import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/filter_dropdown.dart';
import '../../../data/dummy_data.dart';
import '../providers/filter_provider.dart';

/// Filter bottom sheet
class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _equipmentType;
  late String? _company;
  late String? _soilType;
  late String? _location;
  late double _minPrice;
  late double _maxPrice;

  @override
  void initState() {
    super.initState();
    final filter = context.read<FilterProvider>().filter;
    _equipmentType = filter.equipmentType;
    _company = filter.company;
    _soilType = filter.soilType;
    _location = filter.location;
    _minPrice = filter.minPrice ?? 0;
    _maxPrice = filter.maxPrice ?? 5000;
  }

  void _applyFilters() {
    final provider = context.read<FilterProvider>();
    provider.updateEquipmentType(_equipmentType);
    provider.updateCompany(_company);
    provider.updateSoilType(_soilType);
    provider.updateLocation(_location);
    provider.updatePriceRange(_minPrice, _maxPrice);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FilterProvider>(
      builder: (context, provider, child) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.radiusXXLarge),
                  topRight: Radius.circular(AppSizes.radiusXXLarge),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppSizes.screenPadding),
                children: [
                  /// Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.filters,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      TextButton(
                        onPressed: () {
                          provider.clearFilters();
                          _equipmentType = null;
                          _company = null;
                          _soilType = null;
                          _location = null;
                          _minPrice = 0;
                          _maxPrice = 5000;
                          setState(() {});
                        },
                        child: const Text(AppStrings.clearAll),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingLarge),

                  /// Equipment Type Dropdown
                  FilterDropdown(
                    label: AppStrings.equipmentType,
                    items: DummyData.categories
                        .where((c) => c != 'All')
                        .toList(),
                    selectedItem: _equipmentType,
                    onChanged: (value) {
                      setState(() => _equipmentType = value);
                    },
                  ),
                  const SizedBox(height: AppSizes.paddingLarge),

                  /// Company Dropdown
                  FilterDropdown(
                    label: AppStrings.company,
                    items: DummyData.companies,
                    selectedItem: _company,
                    onChanged: (value) {
                      setState(() => _company = value);
                    },
                  ),
                  const SizedBox(height: AppSizes.paddingLarge),

                  /// Soil Type Dropdown
                  FilterDropdown(
                    label: AppStrings.soilType,
                    items: DummyData.soilTypeOptions,
                    selectedItem: _soilType,
                    onChanged: (value) {
                      setState(() => _soilType = value);
                    },
                  ),
                  const SizedBox(height: AppSizes.paddingLarge),

                  /// Location Dropdown
                  FilterDropdown(
                    label: AppStrings.location,
                    items: DummyData.locations,
                    selectedItem: _location,
                    onChanged: (value) {
                      setState(() => _location = value);
                    },
                  ),
                  const SizedBox(height: AppSizes.paddingXLarge),

                  /// Price Range Slider
                  Text(
                    AppStrings.priceRange,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${_minPrice.toStringAsFixed(0)}/hr',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            Text(
                              '\$${_maxPrice.toStringAsFixed(0)}/hr',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.paddingMedium),
                        RangeSlider(
                          values: RangeValues(_minPrice, _maxPrice),
                          min: 0,
                          max: 5000,
                          onChanged: (RangeValues values) {
                            setState(() {
                              _minPrice = values.start;
                              _maxPrice = values.end;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXLarge),

                  /// Result count
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingLarge,
                      vertical: AppSizes.paddingMedium,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${provider.resultCount} ${AppStrings.equipmentFound}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXLarge),

                  /// Apply Button
                  ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.paddingMedium,
                      ),
                    ),
                    child: const Text(AppStrings.applyFilters),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
