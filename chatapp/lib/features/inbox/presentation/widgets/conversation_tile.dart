import 'package:flutter/material.dart';

import 'package:chatapp/core/design/app_colors.dart';
import 'package:chatapp/core/design/app_radius.dart';
import 'package:chatapp/core/design/app_spacing.dart';
import 'package:chatapp/core/widgets/app_surface_card.dart';
import 'package:chatapp/features/inbox/domain/models/conversation_preview.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  final ConversationPreview conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: AppSurfaceCard.decoration(context),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ConversationAvatar(conversation: conversation),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        _formatTime(conversation.timestamp),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: conversation.hasUnread
                              ? AppColors.accent
                              : colorScheme.onSurfaceVariant,
                          fontWeight: conversation.hasUnread
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              _previewIcon(conversation.type),
                              size: 18,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                conversation.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (conversation.isMuted)
                            Icon(
                              Icons.volume_off_rounded,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          if (conversation.hasUnread) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Container(
                              constraints: const BoxConstraints(minWidth: 24),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 3,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xl,
                                ),
                              ),
                              child: Text(
                                '${conversation.unreadCount}',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ] else if (conversation.isPinned) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Icon(
                              Icons.push_pin_outlined,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _previewIcon(ConversationPreviewType type) {
    switch (type) {
      case ConversationPreviewType.text:
        return Icons.done_all_rounded;
      case ConversationPreviewType.voice:
        return Icons.mic_none_rounded;
      case ConversationPreviewType.image:
        return Icons.photo_outlined;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final local = time.toLocal();

    if (now.year == local.year &&
        now.month == local.month &&
        now.day == local.day) {
      final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
      final minute = local.minute.toString().padLeft(2, '0');
      final suffix = local.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $suffix';
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (yesterday.year == local.year &&
        yesterday.month == local.month &&
        yesterday.day == local.day) {
      return 'Yesterday';
    }

    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[local.weekday - 1];
  }
}

class _ConversationAvatar extends StatelessWidget {
  const _ConversationAvatar({required this.conversation});

  final ConversationPreview conversation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: conversation.avatarColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            conversation.avatarLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (conversation.isOnline)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
