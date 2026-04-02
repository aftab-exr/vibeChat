import 'package:flutter/material.dart';

import 'package:chatapp/core/design/app_colors.dart';

abstract final class AppShadows {
  static const List<BoxShadow> sm = [
    BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(color: AppColors.shadow, blurRadius: 24, offset: Offset(0, 12)),
  ];

  static List<BoxShadow> accent(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.22),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
    ];
  }
}
