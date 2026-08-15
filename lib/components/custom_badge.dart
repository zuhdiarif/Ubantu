import 'package:flutter/material.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';

enum BadgeType { green, orange, blue, success, warning, danger, info }

class CustomBadge extends StatelessWidget {
  final String text;
  final BadgeType type;

  const CustomBadge({
    super.key,
    required this.text,
    this.type = BadgeType.green,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;

    switch (type) {
      case BadgeType.green:
      case BadgeType.success:
        bg = const Color(0xFFE8F5E9);
        textColor = AppColors.primaryGreen;
        break;
      case BadgeType.orange:
      case BadgeType.warning:
        bg = AppColors.orangeLight;
        textColor = AppColors.accentOrange;
        break;
      case BadgeType.blue:
      case BadgeType.info:
        bg = const Color(0xFFEBF5FF);
        textColor = const Color(0xFF0066FF);
        break;
      case BadgeType.danger:
        bg = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFEF4444);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
