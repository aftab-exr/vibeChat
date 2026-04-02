import 'package:flutter/material.dart';

import 'package:chatapp/core/design/app_radius.dart';
import 'package:chatapp/core/design/app_shadows.dart';
import 'package:chatapp/core/design/app_spacing.dart';

enum AppSurfaceTone { base, muted, subtle }

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.margin,
    this.tone = AppSurfaceTone.base,
    this.radius = AppRadius.xl,
    this.backgroundColor,
    this.borderColor,
    this.gradient,
    this.boxShadow,
    this.includeBorder = true,
    this.includeShadow = true,
    this.clipBehavior = Clip.none,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final AppSurfaceTone tone;
  final double radius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final bool includeBorder;
  final bool includeShadow;
  final Clip clipBehavior;

  static BoxDecoration decoration(
    BuildContext context, {
    AppSurfaceTone tone = AppSurfaceTone.base,
    double radius = AppRadius.xl,
    Color? backgroundColor,
    Color? borderColor,
    Gradient? gradient,
    List<BoxShadow>? boxShadow,
    bool includeBorder = true,
    bool includeShadow = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedColor =
        backgroundColor ??
        switch (tone) {
          AppSurfaceTone.base => colorScheme.surface,
          AppSurfaceTone.muted => colorScheme.surfaceContainerHighest,
          AppSurfaceTone.subtle => colorScheme.surfaceContainer,
        };
    final resolvedBorderColor =
        borderColor ??
        switch (tone) {
          AppSurfaceTone.base => colorScheme.outline,
          AppSurfaceTone.muted => colorScheme.outlineVariant,
          AppSurfaceTone.subtle => colorScheme.outlineVariant,
        };

    return BoxDecoration(
      color: gradient == null ? resolvedColor : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      border: includeBorder ? Border.all(color: resolvedBorderColor) : null,
      boxShadow: boxShadow ?? (includeShadow ? AppShadows.md : null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      clipBehavior: clipBehavior,
      decoration: decoration(
        context,
        tone: tone,
        radius: radius,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        gradient: gradient,
        boxShadow: boxShadow,
        includeBorder: includeBorder,
        includeShadow: includeShadow,
      ),
      child: child,
    );
  }
}
