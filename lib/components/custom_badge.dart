import 'package:flutter/material.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';

enum BadgeType { green, blue, orange, red }

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
    Color fg;

    switch (type) {
      case BadgeType.green:
        bg = const Color(0xFFE8F5E9);
        fg = AppColors.primaryGreen;
        break;
      case BadgeType.blue:
        bg = const Color(0xFFE3F2FD);
        fg = const Color(0xFF1976D2);
        break;
      case BadgeType.orange:
        bg = AppColors.orangeLight;
        fg = AppColors.orangeNormal;
        break;
      case BadgeType.red:
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFD32F2F);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTypography.body2.copyWith(
          color: fg,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
