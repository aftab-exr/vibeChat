import 'package:flutter/material.dart';

import 'package:chatapp/core/design/app_shadows.dart';
import 'package:chatapp/core/design/app_spacing.dart';
import 'package:chatapp/features/chat/domain/models/chat_message_item.dart';
import 'package:chatapp/features/chat/presentation/utils/chat_time_formatter.dart';
import 'package:chatapp/features/chat/presentation/widgets/chat_date_pill.dart';
import 'package:chatapp/features/chat/presentation/widgets/chat_message_bubble.dart';

class ChatMessageList extends StatelessWidget {
  const ChatMessageList({
    super.key,
    required this.scrollController,
    required this.messages,
    required this.currentUserId,
    required this.activeAudioUrl,
    required this.onAudioPressed,
    required this.onImagePressed,
  });

  final ScrollController scrollController;
  final List<ChatMessageItem> messages;
  final String? currentUserId;
  final String? activeAudioUrl;
  final ValueChanged<String> onAudioPressed;
  final ValueChanged<String> onImagePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.78 : 0.74,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
        boxShadow: AppShadows.md,
      ),
      child: ListView.builder(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        itemCount: messages.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: Center(child: ChatDatePill(label: 'Today')),
            );
          }

          final message = messages[index - 1];
          final isMe = message.isFromUser(currentUserId);

          return ChatMessageBubble(
            isMe: isMe,
            text: message.text,
            imageUrl: message.imageUrl,
            audioUrl: message.audioUrl,
            isAudioPlaying: activeAudioUrl == message.audioUrl,
            timeLabel: formatChatTimestamp(message.createdAt),
            onAudioPressed: message.hasAudio
                ? () => onAudioPressed(message.audioUrl!)
                : null,
            onImagePressed: message.hasImage
                ? () => onImagePressed(message.imageUrl!)
                : null,
          );
        },
      ),
    );
  }
}
