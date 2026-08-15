import 'package:flutter/material.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';

class CustomToggleSwitch extends StatelessWidget {
  final List<String> labels;
  final List<IconData?>? icons;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const CustomToggleSwitch({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.greenNormal : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icons != null && icons![index] != null) ...[
                      Icon(
                        icons![index],
                        size: 18,
                        color: isSelected ? Colors.white : AppColors.primaryDark,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      labels[index],
                      style: AppTypography.body2.copyWith(
                        color: isSelected ? Colors.white : AppColors.primaryDark,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
