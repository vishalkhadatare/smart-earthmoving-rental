import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

/// Primary button widget for main actions
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double height;
  final double? width;
  final IconData? icon;
  final bool isOutlined;

  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.height = AppSizes.buttonHeightLarge,
    this.width,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonWidget = isOutlined
        ? OutlinedButton(
            onPressed: isEnabled && !isLoading ? onPressed : null,
            style: OutlinedButton.styleFrom(
              fixedSize: Size(width ?? double.infinity, height),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingXLarge,
              ),
            ),
            child: _buildContent(),
          )
        : ElevatedButton(
            onPressed: isEnabled && !isLoading ? onPressed : null,
            style: ElevatedButton.styleFrom(
              fixedSize: Size(width ?? double.infinity, height),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingXLarge,
              ),
            ),
            child: _buildContent(),
          );

    return Opacity(opacity: isEnabled ? 1.0 : 0.5, child: buttonWidget);
  }

  Widget _buildContent() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconMedium),
          const SizedBox(width: AppSizes.paddingMedium),
          Text(label),
        ],
      );
    }

    return Text(label);
  }
}
