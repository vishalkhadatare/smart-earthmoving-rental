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

/// Beautiful Enhanced Smart Equipment Recommender screen
class RecommenderScreen extends StatelessWidget {
  const RecommenderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(AppStrings.smartRecommender),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            /// Hero Header Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 25,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 100,
                  bottom: AppSizes.paddingXLarge,
                  left: AppSizes.screenPadding,
                  right: AppSizes.screenPadding,
                ),
                child: Column(
                  children: [
                    /// AI Badge with Animation
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingLarge,
                        vertical: AppSizes.paddingSmall,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: AppSizes.paddingSmall),
                          Text(
                            'AI Powered Recommendations',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingXLarge),

                    /// Title
                    Text(
                      'Find Your Perfect Equipment',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),

                    /// Subtitle
                    Text(
                      'Answer a few questions and get personalized equipment recommendations tailored to your project needs',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                        height: 1.5,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            /// Form Section
            Padding(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              child: Consumer<RecommenderProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      /// Form Card with Glassmorphism effect
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusXLarge,
                          ),
                          border: Border.all(
                            color: AppColors.divider,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.paddingXLarge),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Project Type Section
                              _buildFormSection(
                                context,
                                title: AppStrings.projectType,
                                icon: Icons.construction_rounded,
                                child: FilterDropdown(
                                  label: 'Select Project Type',
                                  items: DummyData.projectTypes,
                                  selectedItem: provider.selectedProject,
                                  onChanged: (value) {
                                    context
                                        .read<RecommenderProvider>()
                                        .updateProjectType(value);
                                  },
                                ),
                              ),
                              const SizedBox(height: AppSizes.paddingXLarge),

                              /// Soil Type Section
                              _buildFormSection(
                                context,
                                title: AppStrings.soilType,
                                icon: Icons.terrain_rounded,
                                child: FilterDropdown(
                                  label: 'Select Soil Type',
                                  items: DummyData.soilTypeOptions,
                                  selectedItem: provider.selectedSoilType,
                                  onChanged: (value) {
                                    context
                                        .read<RecommenderProvider>()
                                        .updateSoilType(value);
                                  },
                                ),
                              ),
                              const SizedBox(height: AppSizes.paddingXLarge),

                              /// Digging Depth Slider Section
                              _buildSliderSection(
                                context,
                                title: AppStrings.diggingDepthLabel,
                                icon: Icons.arrow_downward_rounded,
                                value: provider.diggingDepth,
                                max: 10,
                                unit: ' m',
                                onChanged: (value) {
                                  context
                                      .read<RecommenderProvider>()
                                      .updateDiggingDepth(value);
                                },
                              ),
                              const SizedBox(height: AppSizes.paddingXLarge),

                              /// Max Budget Slider Section
                              _buildSliderSection(
                                context,
                                title: AppStrings.maxBudget,
                                icon: Icons.attach_money_rounded,
                                value: provider.maxBudget,
                                max: 5000,
                                unit: '/hr',
                                onChanged: (value) {
                                  context
                                      .read<RecommenderProvider>()
                                      .updateMaxBudget(value);
                                },
                              ),
                              const SizedBox(height: AppSizes.paddingXLarge),

                              /// Get Recommendations Button
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusMedium,
                                ),
                                child: AppPrimaryButton(
                                  label: 'Get Recommendations',
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
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingXLarge),

                      /// Info Card
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingLarge),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusLarge,
                          ),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(
                                AppSizes.paddingMedium,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusMedium,
                                ),
                              ),
                              child: const Icon(
                                Icons.info_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: AppSizes.paddingMedium),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Smart Recommendations',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Our AI analyzes your requirements and suggests the most suitable equipment for your project, considering cost, efficiency, and terrain conditions.',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                          height: 1.4,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingSmall),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppSizes.paddingMedium),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        child,
      ],
    );
  }

  Widget _buildSliderSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required double value,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Text(
                '${value.toStringAsFixed(1)}$unit',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLarge,
            vertical: AppSizes.paddingMedium,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(color: AppColors.divider, width: 1),
          ),
          child: SliderTheme(
            data: const SliderThemeData(
              trackHeight: 8,
              thumbShape: RoundSliderThumbShape(
                elevation: 4,
                enabledThumbRadius: 12,
              ),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.divider,
              thumbColor: AppColors.primary,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: max,
              divisions: (max * 2).toInt(),
              label: '${value.toStringAsFixed(1)}$unit',
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
