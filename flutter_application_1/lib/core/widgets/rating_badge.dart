import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Widget to display equipment rating badge
class RatingBadge extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final EdgeInsets padding;

  const RatingBadge({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSizes.paddingMedium,
      vertical: AppSizes.paddingSmall,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
          const SizedBox(width: AppSizes.paddingSmall),
          Text(
            '$rating',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSizes.paddingSmall),
          Text(
            '($reviewCount)',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
