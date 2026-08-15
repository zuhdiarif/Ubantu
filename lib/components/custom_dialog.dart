import 'package:flutter/material.dart';
import 'package:ubantu/components/custom_button.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String? cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final IconData icon;
  final Color iconColor;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.onConfirm,
    this.cancelText,
    this.onCancel,
    this.icon = Icons.info_rounded,
    this.iconColor = AppColors.primaryGreen,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
    String? cancelText,
    VoidCallback? onCancel,
    IconData icon = Icons.info_rounded,
    Color iconColor = AppColors.primaryGreen,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        onConfirm: onConfirm,
        cancelText: cancelText,
        onCancel: onCancel,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.h4.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTypography.body1.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: confirmText,
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
            ),
            if (cancelText != null) ...[
              const SizedBox(height: 12),
              CustomButton(
                text: cancelText!,
                type: CustomButtonType.outline,
                onPressed: () {
                  Navigator.pop(context);
                  onCancel?.call();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
