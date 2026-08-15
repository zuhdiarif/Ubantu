import 'package:flutter/material.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';

enum ToastType { success, info, warning, danger }

class CustomToast {
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
  }) {
    Color bg;
    IconData icon;

    switch (type) {
      case ToastType.success:
        bg = AppColors.primaryGreen;
        icon = Icons.check_circle_rounded;
        break;
      case ToastType.info:
        bg = AppColors.primaryDark;
        icon = Icons.info_rounded;
        break;
      case ToastType.warning:
        bg = AppColors.accentOrange;
        icon = Icons.warning_rounded;
        break;
      case ToastType.danger:
        bg = const Color(0xFFEF4444);
        icon = Icons.error_rounded;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTypography.body2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
