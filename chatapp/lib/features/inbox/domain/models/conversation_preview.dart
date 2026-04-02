import 'package:flutter/material.dart';

import 'package:chatapp/features/chat/presentation/models/chat_screen_args.dart';

enum ConversationPreviewType { text, voice, image }

class ConversationPreview {
  const ConversationPreview({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.type,
    required this.unreadCount,
    required this.avatarColor,
    required this.avatarLabel,
    this.isOnline = false,
    this.isPinned = false,
    this.isMuted = false,
  });

  final String id;
  final String name;
  final String lastMessage;
  final DateTime timestamp;
  final ConversationPreviewType type;
  final int unreadCount;
  final Color avatarColor;
  final String avatarLabel;
  final bool isOnline;
  final bool isPinned;
  final bool isMuted;

  bool get hasUnread => unreadCount > 0;

  ChatScreenArgs toChatArgs() {
    return ChatScreenArgs(
      title: name,
      subtitle: isOnline ? 'online' : 'last seen recently',
      avatarLabel: avatarLabel,
    );
  }
}
