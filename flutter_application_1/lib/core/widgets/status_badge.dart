import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../../data/models/equipment_model.dart';

/// Widget to display equipment status badge
class StatusBadge extends StatelessWidget {
  final EquipmentStatus status;
  final EdgeInsets padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSizes.paddingMedium,
      vertical: AppSizes.paddingSmall,
    ),
  });

  Color get _backgroundColor {
    switch (status) {
      case EquipmentStatus.available:
        return AppColors.available;
      case EquipmentStatus.rented:
        return AppColors.rented;
      case EquipmentStatus.maintenance:
        return AppColors.maintenance;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _backgroundColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Text(
        status.displayName,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
