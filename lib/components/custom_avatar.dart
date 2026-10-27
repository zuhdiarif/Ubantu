import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';

class CustomAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double radius;

  const CustomAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      final ImageProvider imageProvider;
      if (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) {
        imageProvider = NetworkImage(imageUrl!);
      } else if (imageUrl!.startsWith('assets/')) {
        imageProvider = AssetImage(imageUrl!);
      } else {
        imageProvider = FileImage(File(imageUrl!));
      }
      return CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
        backgroundColor: AppColors.primarySage.withValues(alpha: 0.3),
      );
    }

    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primarySage.withValues(alpha: 0.3),
      child: Text(
        initial,
        style: AppTypography.h5.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
