import 'package:flutter/material.dart';

import 'package:chatapp/core/design/app_colors.dart';
import 'package:chatapp/core/design/app_radius.dart';
import 'package:chatapp/core/design/app_spacing.dart';

class ChatTypingIndicator extends StatelessWidget {
  const ChatTypingIndicator({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _TypingDots(),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingDots extends StatelessWidget {
  const _TypingDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.only(right: index == 2 ? 0 : 4),
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.35 + (index * 0.2)),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
