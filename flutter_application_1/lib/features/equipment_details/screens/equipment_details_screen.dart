import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/spec_card.dart';
import '../../../core/widgets/price_box.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/rating_badge.dart';
import '../../../data/models/equipment_model.dart';

/// Equipment details screen
class EquipmentDetailsScreen extends StatefulWidget {
  final Equipment equipment;

  const EquipmentDetailsScreen({super.key, required this.equipment});

  @override
  State<EquipmentDetailsScreen> createState() => _EquipmentDetailsScreenState();
}

class _EquipmentDetailsScreenState extends State<EquipmentDetailsScreen> {
  late String _selectedPricingType;
  late double _selectedPrice;

  @override
  void initState() {
    super.initState();
    _selectedPricingType = 'Day';
    _selectedPrice = widget.equipment.priceDay;
  }

  void _updatePricingType(String type, double price) {
    setState(() {
      _selectedPricingType = type;
      _selectedPrice = price;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equipment Details')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Hero Image
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  color: AppColors.surfaceDark,
                  child: Image.network(
                    widget.equipment.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.surfaceDark,
                        child: const Icon(
                          Icons.construction,
                          size: 64,
                          color: AppColors.textHint,
                        ),
                      );
                    },
                  ),
                ),

                /// Back button
                Positioned(
                  top: AppSizes.paddingLarge,
                  left: AppSizes.paddingLarge,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                /// Status badge
                Positioned(
                  top: AppSizes.paddingLarge,
                  right: AppSizes.paddingLarge,
                  child: StatusBadge(status: widget.equipment.status),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Name, Company, and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.equipment.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: AppSizes.paddingSmall),
                            Text(
                              widget.equipment.company,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      RatingBadge(
                        rating: widget.equipment.rating,
                        reviewCount: widget.equipment.reviewCount,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingLarge),

                  /// Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primary,
                        size: AppSizes.iconMedium,
                      ),
                      const SizedBox(width: AppSizes.paddingMedium),
                      Text(
                        widget.equipment.location,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingXLarge),

                  /// Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  Text(
                    widget.equipment.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXLarge),

                  /// Pricing Section
                  Text(
                    'Pricing',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  Row(
                    children: [
                      Expanded(
                        child: PriceBox(
                          label: AppStrings.hour,
                          price: widget.equipment.priceHour,
                          isSelected: _selectedPricingType == 'Hour',
                          onTap: () => _updatePricingType(
                            'Hour',
                            widget.equipment.priceHour,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingMedium),
                      Expanded(
                        child: PriceBox(
                          label: AppStrings.day,
                          price: widget.equipment.priceDay,
                          isSelected: _selectedPricingType == 'Day',
                          onTap: () => _updatePricingType(
                            'Day',
                            widget.equipment.priceDay,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingMedium),
                      Expanded(
                        child: PriceBox(
                          label: AppStrings.month,
                          price: widget.equipment.priceMonth,
                          isSelected: _selectedPricingType == 'Month',
                          onTap: () => _updatePricingType(
                            'Month',
                            widget.equipment.priceMonth,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingXLarge),

                  /// Specifications
                  Text(
                    AppStrings.specifications,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSizes.paddingMedium,
                          mainAxisSpacing: AppSizes.paddingMedium,
                          childAspectRatio: 1.2,
                        ),
                    itemCount: widget.equipment.specifications.length,
                    itemBuilder: (context, index) {
                      final entry = widget.equipment.specifications.entries
                          .toList()[index];
                      return SpecCard(label: entry.key, value: entry.value);
                    },
                  ),
                  const SizedBox(height: AppSizes.paddingXLarge),

                  /// Soil Types
                  Text(
                    AppStrings.soilTypes,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  Wrap(
                    spacing: AppSizes.paddingMedium,
                    runSpacing: AppSizes.paddingMedium,
                    children: widget.equipment.soilTypes.map((soilType) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingLarge,
                          vertical: AppSizes.paddingSmall,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(
                            AppSizes.chipRadius,
                          ),
                        ),
                        child: Text(
                          soilType,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSizes.paddingXLarge),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Contacting ${widget.equipment.company}...',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text(AppStrings.contact),
              ),
            ),
            const SizedBox(width: AppSizes.paddingLarge),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${widget.equipment.name} booking initiated for \$${_selectedPrice.toStringAsFixed(0)}',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text(AppStrings.bookNow),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
