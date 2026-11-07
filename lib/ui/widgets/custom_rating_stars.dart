import 'package:flutter/material.dart';

class CustomRatingStars extends StatelessWidget {
  final double rating;
  final double starSize;
  final Color starColor;

  const CustomRatingStars({
    super.key,
    required this.rating,
    this.starSize = 18,
    this.starColor = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starRating = index + 1;
        IconData icon;
        if (rating >= starRating) {
          icon = Icons.star_rounded;
        } else if (rating >= starRating - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }
        return Icon(
          icon,
          size: starSize,
          color: starColor,
        );
      }),
    );
  }
}
