import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../../data/models/equipment_model.dart';
import 'status_badge.dart';
import 'rating_badge.dart';

/// Equipment card widget displaying equipment information
class EquipmentCard extends StatelessWidget {
  final Equipment equipment;
  final VoidCallback? onViewDetails;
  final VoidCallback? onCompare;
  final bool showCompareButton;

  const EquipmentCard({
    super.key,
    required this.equipment,
    this.onViewDetails,
    this.onCompare,
    this.showCompareButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Equipment Image with badges
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.radiusLarge),
                  topRight: Radius.circular(AppSizes.radiusLarge),
                ),
                child: Container(
                  height: AppSizes.equipmentImageHeight,
                  width: double.infinity,
                  color: AppColors.surfaceDark,
                  child: Image.network(
                    equipment.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.surfaceDark,
                        child: const Icon(
                          Icons.construction,
                          size: 48,
                          color: AppColors.textHint,
                        ),
                      );
                    },
                  ),
                ),
              ),

              /// Status Badge (top-left)
              Positioned(
                top: AppSizes.paddingMedium,
                left: AppSizes.paddingMedium,
                child: StatusBadge(status: equipment.status),
              ),

              /// Rating Badge (top-right)
              Positioned(
                top: AppSizes.paddingMedium,
                right: AppSizes.paddingMedium,
                child: RatingBadge(
                  rating: equipment.rating,
                  reviewCount: equipment.reviewCount,
                ),
              ),
            ],
          ),

          /// Card Content
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Name and Company
                Text(
                  equipment.name,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSizes.paddingSmall),
                Text(
                  equipment.company,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                /// Location
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingMedium,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: AppSizes.iconSmall,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSizes.paddingSmall),
                      Expanded(
                        child: Text(
                          equipment.location,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                /// Price
                Text(
                  '\$${equipment.priceDay.toStringAsFixed(0)}/day',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                /// Action Buttons
                const SizedBox(height: AppSizes.paddingMedium),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: onViewDetails,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.paddingSmall,
                          ),
                        ),
                        child: const Text('View Details'),
                      ),
                    ),
                    if (showCompareButton) ...[
                      const SizedBox(width: AppSizes.paddingMedium),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onCompare,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSizes.paddingSmall,
                            ),
                          ),
                          child: const Text('Compare'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
