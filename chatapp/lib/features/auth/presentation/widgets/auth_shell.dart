import 'package:flutter/material.dart';

import 'package:chatapp/core/design/app_colors.dart';
import 'package:chatapp/core/design/app_spacing.dart';
import 'package:chatapp/core/widgets/app_icon_badge.dart';
import 'package:chatapp/core/widgets/app_surface_card.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.footer,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ),
          Positioned(
            left: -50,
            bottom: -10,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(52),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth > 560 ? 460 : double.infinity,
                  ),
                  child: AppSurfaceCard(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppIconBadge(
                          icon: Icons.chat_bubble_rounded,
                          color: Colors.white,
                          backgroundColor: AppColors.accent,
                          size: 60,
                          iconSize: 28,
                          radius: 20,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(title, style: theme.textTheme.headlineMedium),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        child,
                        const SizedBox(height: AppSpacing.lg),
                        footer,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
