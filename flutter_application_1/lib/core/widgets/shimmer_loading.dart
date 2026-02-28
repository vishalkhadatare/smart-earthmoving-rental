import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Loading shimmer widget
class ShimmerLoading extends StatefulWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;
  final bool isCircle;

  const ShimmerLoading({
    super.key,
    required this.height,
    this.width,
    this.borderRadius,
    this.isCircle = false,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width ?? double.infinity,
          decoration: BoxDecoration(
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.isCircle
                ? null
                : (widget.borderRadius ??
                      BorderRadius.circular(AppSizes.radiusMedium)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surfaceDark,
                AppColors.divider.withOpacity(0.5),
                AppColors.surfaceDark,
              ],
              stops: [0.0, _controller.value, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Loading skeleton grid
class ShimmerLoadingGrid extends StatelessWidget {
  final int itemCount;

  const ShimmerLoadingGrid({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.paddingLarge),
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const ShimmerLoading(
                  height: 160,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.radiusLarge),
                    topRight: Radius.circular(AppSizes.radiusLarge),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLoading(
                        height: 16,
                        width: 200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      ShimmerLoading(
                        height: 14,
                        width: 120,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: ShimmerLoading(
                              height: 36,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: AppSizes.paddingMedium),
                          Expanded(
                            child: ShimmerLoading(
                              height: 36,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
