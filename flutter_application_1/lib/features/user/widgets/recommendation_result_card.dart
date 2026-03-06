import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../models/recommendation_model.dart';

class RecommendationResultCard extends StatefulWidget {
  final RecommendationResult result;
  final VoidCallback onViewDetails;
  final VoidCallback onBookNow;

  const RecommendationResultCard({
    super.key,
    required this.result,
    required this.onViewDetails,
    required this.onBookNow,
  });

  @override
  State<RecommendationResultCard> createState() =>
      _RecommendationResultCardState();
}

class _RecommendationResultCardState extends State<RecommendationResultCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverCtrl;

  static const Color _accent = Color(0xFFFF6B00);
  static const Color _dark = Color(0xFF1A1A2E);
  static const Color _sub = Color(0xFF8F90A6);
  static const Color _card = Colors.white;
  static const Color _green = Color(0xFF00C853);
  static const Color _yellow = Color(0xFFFFB800);

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final equipment = widget.result.equipment;

    return MouseRegion(
      onEnter: (_) => _hoverCtrl.forward(),
      onExit: (_) => _hoverCtrl.reverse(),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 1.0,
          end: 1.02,
        ).animate(CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeInOut)),
        child: Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top Section: Equipment Image & Match Badge
              Container(
                height: 140,
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
                        Icons.construction,
                        size: 64,
                        color: _accent.withValues(alpha: 0.4),
                      ),
                    ),

                    // Best Match Badge
                    if (widget.result.isBestMatch)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_accent, _accent.withValues(alpha: 0.8)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: _accent.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
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

                    // Match Score
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
                          '${widget.result.score.toStringAsFixed(0)}% Match',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _accent,
                          ),
                        ),
                      ),
                    ),

                    // Availability badge
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: equipment.isAvailable ? _green : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              equipment.isAvailable
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              equipment.isAvailable ? 'Available' : 'Booked',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  equipment.category,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: _sub,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSizes.paddingMedium),

                      // Rating
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (i) => Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: i < equipment.rating.floor()
                                  ? _yellow
                                  : const Color(0xFFE0E0E0),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            equipment.rating.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _dark,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${equipment.reviewCount} reviews)',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: _sub,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSizes.paddingMedium),

                      // Spec (model)
                      if (equipment.specs.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium,
                            vertical: AppSizes.paddingSmall,
                          ),
                          decoration: BoxDecoration(
                            color: _accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Model: ${equipment.model}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _accent,
                            ),
                          ),
                        ),

                      const SizedBox(height: AppSizes.paddingMedium),

                      // Recommendation Reason
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingSmall,
                          vertical: AppSizes.paddingSmall,
                        ),
                        child: Text(
                          widget.result.reason,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: _sub,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const Spacer(),

                      // Price and Buttons
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hourly Rate',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: _sub,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '₹${equipment.pricePerHour.toStringAsFixed(0)}/hr',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: _accent,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Provider',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: _sub,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    equipment.provider.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _dark,
                                    ),
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSizes.paddingLarge),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: widget.onViewDetails,
                                  child: Container(
                                    height: AppSizes.buttonHeightMedium,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.radiusMedium,
                                      ),
                                      border: Border.all(
                                        color: _accent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Details',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: _accent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSizes.paddingMedium),

                              Expanded(
                                child: GestureDetector(
                                  onTap: widget.onBookNow,
                                  child: Container(
                                    height: AppSizes.buttonHeightMedium,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _accent,
                                          _accent.withValues(alpha: 0.85),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.radiusMedium,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _accent.withValues(alpha: 0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Book Now',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSizes.paddingMedium),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Added to compare list',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  backgroundColor: _accent,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F0F0),
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusMedium,
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.compare_arrows_rounded,
                                      size: 14,
                                      color: _sub,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Compare',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _sub,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
