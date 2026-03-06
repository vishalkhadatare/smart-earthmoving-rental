import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../features/home/screens/equipment_details_screen.dart';
import '../../../features/booking/screens/create_booking_screen.dart';
import '../models/recommendation_model.dart';
import '../services/recommendation_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Smart Recommendation Screen
// ─────────────────────────────────────────────────────────────────────────────

class SmartRecommendationScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBackPressed;

  const SmartRecommendationScreen({super.key, this.onBackPressed});

  @override
  ConsumerState<SmartRecommendationScreen> createState() =>
      _SmartRecommendationScreenState();
}

class _SmartRecommendationScreenState
    extends ConsumerState<SmartRecommendationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late PageController _pageCtrl;
  late ScrollController _scrollCtrl;
  bool _isLoading = false;

  // Theme colors
  static const Color _bg = Color(0xFFF7F7F7);
  static const Color _accent = Color(0xFFFF6B00);
  static const Color _dark = Color(0xFF1A1A2E);
  static const Color _sub = Color(0xFF8F90A6);
  static const Color _card = Colors.white;
  static const Color _green = Color(0xFF00C853);

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pageCtrl = PageController();
    _scrollCtrl = ScrollController();
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _pageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recommendations = ref.watch(recommendationsProvider);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(child: _buildHeader()),

            // Main Filter Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingXLarge,
                  vertical: AppSizes.paddingMedium,
                ),
                child: _buildFilterCard(context),
              ),
            ),

            // Results Section (only if recommendations exist)
            if (recommendations.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingXLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top ${recommendations.length} Recommendations',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _dark,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),
                      Scrollbar(
                        controller: _scrollCtrl,
                        thumbVisibility: true,
                        radius: const Radius.circular(8),
                        thickness: 8,
                        child: ListView.separated(
                          controller: _scrollCtrl,
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: recommendations.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSizes.paddingLarge),
                          itemBuilder: (context, index) {
                            final result = recommendations[index];
                            return _buildSimpleResultCard(
                              result,
                              index,
                              context,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (recommendations.isEmpty &&
                ref.watch(recommendationFilterProvider).projectType !=
                    null) ...[
              SliverToBoxAdapter(child: _buildNoResultsMessage()),
            ] else ...[
              SliverToBoxAdapter(child: _buildInitialStateMessage()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingXLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: widget.onBackPressed ?? () => Navigator.pop(context),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _card,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: _dark,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Smart Recommendations',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Get the best equipment for your project',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: _sub,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard(BuildContext context) {
    final filter = ref.watch(recommendationFilterProvider);
    final recommendationService = ref.watch(recommendationServiceProvider);

    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingXLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdowns Row
              Row(
                children: [
                  Expanded(child: _buildProjectTypeDropdown(filter)),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Expanded(child: _buildSoilTypeDropdown(filter)),
                ],
              ),

              const SizedBox(height: AppSizes.paddingXLarge),

              // Digging Depth Slider
              _buildSlider(
                label: 'Required Digging Depth',
                value: filter.diggingDepth,
                min: 0.5,
                max: 10.0,
                unit: 'm',
                onChanged: (newValue) {
                  ref.read(recommendationFilterProvider.notifier).state = filter
                      .copyWith(diggingDepth: newValue);
                },
              ),

              const SizedBox(height: AppSizes.paddingXLarge),

              // Duration Slider
              _buildSlider(
                label: 'Project Duration',
                value: filter.duration,
                min: 1,
                max: 30,
                unit: ' days',
                onChanged: (newValue) {
                  ref.read(recommendationFilterProvider.notifier).state = filter
                      .copyWith(duration: newValue);
                },
              ),

              const SizedBox(height: AppSizes.paddingXXLarge),

              // Get Recommendations Button
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeightLarge,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_accent, _accent.withValues(alpha: 0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLoading
                          ? null
                          : () async {
                              if (filter.projectType == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Please select a project type',
                                      style: GoogleFonts.poppins(),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              setState(() => _isLoading = true);

                              final recs = await recommendationService
                                  .getRecommendations(filter, topN: 5);

                              setState(() => _isLoading = false);

                              ref.read(recommendationsProvider.notifier).state =
                                  recs;

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      recs.isEmpty
                                          ? 'No equipment found matching your criteria'
                                          : 'Found ${recs.length} recommendations - scroll to see',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    backgroundColor: recs.isEmpty
                                        ? Colors.orange
                                        : _green,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );

                                if (recs.isNotEmpty) {
                                  Future.delayed(
                                    const Duration(milliseconds: 300),
                                    () {
                                      if (_scrollCtrl.hasClients) {
                                        _scrollCtrl.animateTo(
                                          _scrollCtrl.position.maxScrollExtent,
                                          duration: const Duration(
                                            milliseconds: 500,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    },
                                  );
                                }
                              }
                            },
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusXLarge,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isLoading)
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            )
                          else
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          const SizedBox(width: 8),
                          Text(
                            _isLoading ? 'Fetching...' : 'Get Recommendations',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectTypeDropdown(RecommendationFilter filter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project Type',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _dark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          child: DropdownButton<ProjectType>(
            value: filter.projectType,
            hint: Text(
              'Select project type',
              style: GoogleFonts.poppins(color: _sub, fontSize: 13),
            ),
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (ProjectType? newValue) {
              ref.read(recommendationFilterProvider.notifier).state = filter
                  .copyWith(projectType: newValue);
            },
            items: ProjectType.values.map((ProjectType value) {
              return DropdownMenuItem<ProjectType>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    value.displayName,
                    style: GoogleFonts.poppins(color: _dark, fontSize: 13),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSoilTypeDropdown(RecommendationFilter filter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Soil Type',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _dark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          child: DropdownButton<SoilType>(
            value: filter.soilType,
            hint: Text(
              'Select soil type',
              style: GoogleFonts.poppins(color: _sub, fontSize: 13),
            ),
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (SoilType? newValue) {
              ref.read(recommendationFilterProvider.notifier).state = filter
                  .copyWith(soilType: newValue);
            },
            items: SoilType.values.map((SoilType value) {
              return DropdownMenuItem<SoilType>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    value.displayName,
                    style: GoogleFonts.poppins(color: _dark, fontSize: 13),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
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
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _dark,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${value.toStringAsFixed(1)}$unit',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: const SliderThemeData(
            trackHeight: 6,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 12,
              elevation: 2,
            ),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            activeColor: _accent,
            inactiveColor: const Color(0xFFE0E0E0),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleResultCard(
    RecommendationResult result,
    int index,
    BuildContext context,
  ) {
    final equipment = result.equipment;
    final isBest = index == 0;

    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
        border: Border.all(
          color: isBest ? _accent : const Color(0xFFE0E0E0),
          width: isBest ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isBest
                ? _accent.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Image Section
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusXLarge),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.construction_rounded,
                    size: 64,
                    color: _accent.withValues(alpha: 0.4),
                  ),
                ),
                if (isBest)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Best Match',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      '${result.score.toStringAsFixed(0)}%',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _accent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            equipment.name,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _dark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            equipment.category,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _sub,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  result.reason,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: _sub,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '₹${equipment.pricePerHour.toStringAsFixed(0)}/hr',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _accent,
                      ),
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EquipmentDetailsScreen(
                                  equipment: equipment,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.info_outline, size: 16),
                          label: Text(
                            'Details',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: _dark,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateBookingScreen(
                                  equipmentId: equipment.id,
                                  equipmentName: equipment.name,
                                  machineType: equipment.category,
                                  providerId: equipment.provider.id,
                                  providerName: equipment.provider.name,
                                  hourlyRate: equipment.pricePerHour,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(
                            'Book',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: _sub.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSizes.paddingXLarge),
            Text(
              'No Recommendations Found',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters to find equipment',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: _sub,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialStateMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              size: 64,
              color: _accent.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSizes.paddingXLarge),
            Text(
              'Ready to Find Equipment?',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select your project type, soil type, and budget\nto get smart recommendations',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: _sub,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
