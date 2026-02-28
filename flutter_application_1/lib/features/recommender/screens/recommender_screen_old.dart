import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/filter_dropdown.dart';
import '../../../data/dummy_data.dart';
import '../providers/recommender_provider.dart';
import 'recommendation_results_screen.dart';

/// Smart Equipment Recommender screen
class RecommenderScreen extends StatelessWidget {
  const RecommenderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.smartRecommender)),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// AI Powered Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSizes.chipRadius),
                  border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: AppSizes.paddingSmall),
                    Text(
                      AppStrings.aiPowered,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.paddingLarge),

              /// Title and Subtitle
              Text(
                AppStrings.smartRecommender,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              Text(
                AppStrings.recommenderDescription,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSizes.paddingXLarge),

              /// Form Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingXLarge),
                  child: Consumer<RecommenderProvider>(
                    builder: (context, provider, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Project Type
                          FilterDropdown(
                            label: AppStrings.projectType,
                            items: DummyData.projectTypes,
                            selectedItem: provider.selectedProject,
                            onChanged: (value) {
                              context
                                  .read<RecommenderProvider>()
                                  .updateProjectType(value);
                            },
                          ),
                          const SizedBox(height: AppSizes.paddingXLarge),

                          /// Soil Type
                          FilterDropdown(
                            label: AppStrings.soilType,
                            items: DummyData.soilTypeOptions,
                            selectedItem: provider.selectedSoilType,
                            onChanged: (value) {
                              context
                                  .read<RecommenderProvider>()
                                  .updateSoilType(value);
                            },
                          ),
                          const SizedBox(height: AppSizes.paddingXLarge),

                          /// Digging Depth Slider
                          Text(
                            AppStrings.diggingDepthLabel,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSizes.paddingMedium),
                          Container(
                            padding: const EdgeInsets.all(
                              AppSizes.paddingMedium,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMedium,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${provider.diggingDepth.toStringAsFixed(1)} m',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(color: AppColors.primary),
                                ),
                                const SizedBox(height: AppSizes.paddingMedium),
                                Slider(
                                  value: provider.diggingDepth,
                                  min: 0,
                                  max: 10,
                                  divisions: 20,
                                  label:
                                      '${provider.diggingDepth.toStringAsFixed(1)} m',
                                  onChanged: (value) {
                                    context
                                        .read<RecommenderProvider>()
                                        .updateDiggingDepth(value);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingXLarge),

                          /// Max Budget Slider
                          Text(
                            AppStrings.maxBudget,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSizes.paddingMedium),
                          Container(
                            padding: const EdgeInsets.all(
                              AppSizes.paddingMedium,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMedium,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '\$${provider.maxBudget.toStringAsFixed(0)}/hr',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(color: AppColors.primary),
                                ),
                                const SizedBox(height: AppSizes.paddingMedium),
                                Slider(
                                  value: provider.maxBudget,
                                  min: 0,
                                  max: 5000,
                                  divisions: 50,
                                  label:
                                      '\$${provider.maxBudget.toStringAsFixed(0)}/hr',
                                  onChanged: (value) {
                                    context
                                        .read<RecommenderProvider>()
                                        .updateMaxBudget(value);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingXLarge),

                          /// Get Recommendations Button
                          AppPrimaryButton(
                            label: AppStrings.getRecommendations,
                            isLoading: provider.isLoading,
                            onPressed: () async {
                              await context
                                  .read<RecommenderProvider>()
                                  .getRecommendations();

                              if (!context.mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RecommendationResultsScreen(
                                        recommendations:
                                            provider.recommendations,
                                      ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
