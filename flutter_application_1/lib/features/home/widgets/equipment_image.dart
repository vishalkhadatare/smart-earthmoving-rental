import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Displays an equipment image — network URL if available, otherwise asset fallback.
class EquipmentImage extends StatelessWidget {
  final List<String> imageUrls;
  final String fallbackAsset;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const EquipmentImage({
    super.key,
    required this.imageUrls,
    required this.fallbackAsset,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (imageUrls.isNotEmpty) {
      image = CachedNetworkImage(
        imageUrl: imageUrls.first,
        fit: fit,
        width: width,
        height: height,
        placeholder: (_, __) => Container(
          color: const Color(0xFFF3F3F3),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFFF6B00),
              ),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => Image.asset(
          fallbackAsset,
          fit: BoxFit.contain,
          width: width,
          height: height,
          errorBuilder: (_, __, ___) => Icon(
            Icons.construction_rounded,
            size: 48,
            color: const Color(0xFFFF6B00).withValues(alpha: 0.3),
          ),
        ),
      );
    } else {
      image = Image.asset(
        fallbackAsset,
        fit: BoxFit.contain,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => Icon(
          Icons.construction_rounded,
          size: 48,
          color: const Color(0xFFFF6B00).withValues(alpha: 0.3),
        ),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
