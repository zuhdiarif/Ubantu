import 'package:flutter/material.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';

enum CustomButtonType { primary, outline, danger, dangerOutline }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final CustomButtonType type;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = CustomButtonType.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    BorderSide borderSide = BorderSide.none;

    switch (type) {
      case CustomButtonType.primary:
        backgroundColor = AppColors.greenNormal;
        textColor = Colors.white;
        break;
      case CustomButtonType.outline:
        backgroundColor = Colors.transparent;
        textColor = AppColors.greenNormal;
        borderSide = const BorderSide(color: AppColors.greenNormal, width: 1.5);
        break;
      case CustomButtonType.danger:
        backgroundColor = const Color(0xFFEF4444);
        textColor = Colors.white;
        break;
      case CustomButtonType.dangerOutline:
        backgroundColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFEF4444);
        borderSide = const BorderSide(color: Color(0xFFFCA5A5), width: 1.5);
        break;
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
            side: borderSide,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: textColor),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: AppTypography.body1.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
