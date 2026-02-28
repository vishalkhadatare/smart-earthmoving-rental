import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/equipment_card.dart';
import '../../../data/models/equipment_model.dart';

/// Recommendation results screen
class RecommendationResultsScreen extends StatelessWidget {
  final List<Equipment> recommendations;

  const RecommendationResultsScreen({super.key, required this.recommendations});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.topRecommendations)),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Based on your requirements, we found ${recommendations.length} perfect matches',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingXLarge),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  final equipment = recommendations[index];
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSizes.paddingLarge,
                    ),
                    child: Column(
                      children: [
                        /// Rank Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium,
                            vertical: AppSizes.paddingSmall,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusSmall,
                            ),
                          ),
                          child: Text(
                            '#${index + 1} Recommended',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingMedium),

                        /// Equipment Card
                        SizedBox(
                          height: AppSizes.equipmentCardHeight,
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
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
