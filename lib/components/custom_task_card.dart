import 'package:flutter/material.dart';
import 'package:ubantu/components/custom_badge.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';

class CustomTaskCard extends StatelessWidget {
  final String name;
  final double rating;
  final int ratingCount;
  final String badgeText;
  final BadgeType badgeType;
  final String location;
  final String date;
  final String time;
  final VoidCallback onDetailPressed;

  const CustomTaskCard({
    super.key,
    required this.name,
    required this.rating,
    required this.ratingCount,
    required this.badgeText,
    required this.badgeType,
    required this.location,
    required this.date,
    required this.time,
    required this.onDetailPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primarySage.withValues(alpha: 0.3),
                child: Text(
                  name.isNotEmpty ? name[0] : 'U',
                  style: AppTypography.h5.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.body1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$rating ($ratingCount)',
                          style: AppTypography.body2.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    CustomBadge(text: badgeText, type: badgeType),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenNormal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onDetailPressed,
                child: Text(
                  'Detail',
                  style: AppTypography.body2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.primaryDark,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: AppTypography.body2.copyWith(
                    color: AppColors.primaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.primaryDark,
              ),
              const SizedBox(width: 4),
              Text(
                date,
                style: AppTypography.body2.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.access_time_rounded,
                size: 14,
                color: AppColors.primaryDark,
              ),
              const SizedBox(width: 4),
              Text(
                time,
                style: AppTypography.body2.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
