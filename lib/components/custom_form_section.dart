import 'package:flutter/material.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';

class CustomFormSection extends StatelessWidget {
  final String title;
  final String? description;
  final Widget child;

  const CustomFormSection({
    super.key,
    required this.title,
    this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description!,
            style: AppTypography.body2.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
