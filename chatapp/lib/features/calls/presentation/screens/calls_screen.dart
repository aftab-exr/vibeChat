import 'package:flutter/material.dart';

import 'package:chatapp/core/design/app_colors.dart';
import 'package:chatapp/core/design/app_spacing.dart';
import 'package:chatapp/core/widgets/app_icon_badge.dart';
import 'package:chatapp/core/widgets/app_surface_card.dart';
import 'package:chatapp/core/widgets/tab_section_card.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CallsTabView());
  }
}

class CallsTabView extends StatelessWidget {
  const CallsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      children: [
        const TabSectionCard(
          title: 'Call activity',
          subtitle:
              'This tab gives the calling feature its own destination in the app shell, separate from the active chat experience.',
          leading: AppIconBadge(icon: Icons.call_made_rounded),
          child: Column(
            children: [
              _CallLogTile(
                name: 'Saad Jones',
                detail: 'Incoming video call',
                time: 'Today, 10:42 AM',
                isMissed: false,
              ),
              SizedBox(height: AppSpacing.md),
              _CallLogTile(
                name: 'Product Team',
                detail: 'Missed voice call',
                time: 'Yesterday, 8:15 PM',
                isMissed: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppSurfaceCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          tone: AppSurfaceTone.subtle,
          includeShadow: false,
          child: Text(
            'Your WebRTC logic still lives in chat for now, but the navigation shell is ready for call history and dedicated call controls.',
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

class _CallLogTile extends StatelessWidget {
  const _CallLogTile({
    required this.name,
    required this.detail,
    required this.time,
    required this.isMissed,
  });

  final String name;
  final String detail;
  final String time;
  final bool isMissed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        AppIconBadge(
          icon: isMissed ? Icons.call_received_rounded : Icons.videocam_rounded,
          color: isMissed ? AppColors.danger : AppColors.accent,
          backgroundColor: colorScheme.surface,
          size: 48,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(detail, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(time, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
