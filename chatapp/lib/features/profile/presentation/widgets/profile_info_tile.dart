import 'package:flutter/material.dart';

import 'package:chatapp/core/design/app_spacing.dart';
import 'package:chatapp/core/widgets/app_icon_badge.dart';
import 'package:chatapp/core/widgets/app_surface_card.dart';

class ProfileInfoTile extends StatelessWidget {
  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.supportingText,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? supportingText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      tone: AppSurfaceTone.muted,
      includeShadow: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconBadge(
            icon: icon,
            color: theme.colorScheme.onSurface,
            backgroundColor: theme.colorScheme.surface,
            size: 42,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(value, style: theme.textTheme.titleMedium),
                if (supportingText != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(supportingText!, style: theme.textTheme.bodyMedium),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
