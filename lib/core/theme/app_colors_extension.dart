import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color primaryGreen;
  final Color primaryDark;
  final Color accentOrange;

  const AppColorsExtension({
    required this.primaryGreen,
    required this.primaryDark,
    required this.accentOrange,
  });

  @override
  AppColorsExtension copyWith({
    Color? primaryGreen,
    Color? primaryDark,
    Color? accentOrange,
  }) {
    return AppColorsExtension(
      primaryGreen: primaryGreen ?? this.primaryGreen,
      primaryDark: primaryDark ?? this.primaryDark,
      accentOrange: accentOrange ?? this.accentOrange,
    );
  }

  @override
  AppColorsExtension lerp(
    ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      primaryGreen: Color.lerp(primaryGreen, other.primaryGreen, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      accentOrange: Color.lerp(accentOrange, other.accentOrange, t)!,
    );
  }
}
