import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ubantu/core/theme/app_colors.dart';
import 'package:ubantu/core/theme/app_typography.dart';

class CustomAvatar extends StatefulWidget {
  final String name;
  final String? imageUrl;
  final double radius;

  const CustomAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 24,
  });

  @override
  State<CustomAvatar> createState() => _CustomAvatarState();
}

class _CustomAvatarState extends State<CustomAvatar> {
  bool _hasError = false;

  @override
  void didUpdateWidget(CustomAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _hasError = false;
    }
  }

  Widget _buildFallback() {
    final initial = widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'U';
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: AppColors.primarySage.withValues(alpha: 0.3),
      child: Text(
        initial,
        style: AppTypography.h5.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.bold,
          fontSize: widget.radius * 0.8,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      return _buildFallback();
    }

    final url = widget.imageUrl!;
    final bool isNetwork = url.startsWith('http://') || url.startsWith('https://');
    final bool isAsset = url.startsWith('assets/');

    if (!isNetwork && !isAsset) {
      try {
        final file = File(url);
        if (!file.existsSync()) {
          return _buildFallback();
        }
      } catch (_) {
        return _buildFallback();
      }
    }

    final ImageProvider imageProvider;
    if (isNetwork) {
      imageProvider = NetworkImage(url);
    } else if (isAsset) {
      imageProvider = AssetImage(url);
    } else {
      imageProvider = FileImage(File(url));
    }

    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: AppColors.primarySage.withValues(alpha: 0.3),
      backgroundImage: imageProvider,
      onBackgroundImageError: (exception, stackTrace) {
        if (mounted && !_hasError) {
          setState(() {
            _hasError = true;
          });
        }
      },
    );
  }
}
