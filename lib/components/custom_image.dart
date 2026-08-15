import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ubantu/components/theme/app_colors.dart';

class CustomImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CustomImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (path.endsWith('.svg')) {
      imageWidget = SvgPicture.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (context) => Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: const Icon(
            Icons.image_outlined,
            color: AppColors.primaryGreen,
          ),
        ),
      );
    } else if (path.startsWith('http://') || path.startsWith('https://')) {
      imageWidget = Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
        ),
      );
    } else {
      imageWidget = Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image_rounded, color: Colors.grey),
        ),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
