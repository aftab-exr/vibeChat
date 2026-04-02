import 'package:flutter/material.dart';

import 'package:chatapp/core/design/app_colors.dart';
import 'package:chatapp/core/design/app_radius.dart';

class AppIconBadge extends StatelessWidget {
  const AppIconBadge({
    super.key,
    required this.icon,
    this.color = AppColors.accent,
    this.backgroundColor,
    this.size = 44,
    this.iconSize = 20,
    this.radius = AppRadius.md,
  });

  final IconData icon;
  final Color color;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}
