import 'package:flutter/material.dart';

import 'package:chatapp/features/inbox/domain/models/conversation_preview.dart';

class InboxRepository {
  const InboxRepository();

  List<ConversationPreview> getConversations() {
    final now = DateTime.now();

    return [
      ConversationPreview(
        id: 'saad-jones',
        name: 'Saad Jones',
        lastMessage: 'Can you send the voice note after the call?',
        timestamp: now.subtract(const Duration(minutes: 2)),
        type: ConversationPreviewType.voice,
        unreadCount: 3,
        avatarColor: const Color(0xFFD8F3DC),
        avatarLabel: 'SJ',
        isOnline: true,
        isPinned: true,
      ),
      ConversationPreview(
        id: 'maya-chen',
        name: 'Maya Chen',
        lastMessage: 'The latest onboarding screens look much cleaner now.',
        timestamp: now.subtract(const Duration(minutes: 18)),
        type: ConversationPreviewType.text,
        unreadCount: 1,
        avatarColor: const Color(0xFFFFE8CC),
        avatarLabel: 'MC',
        isOnline: true,
      ),
      ConversationPreview(
        id: 'design-sync',
        name: 'Design Sync',
        lastMessage: 'Shared 4 new references',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 20)),
        type: ConversationPreviewType.image,
        unreadCount: 0,
        avatarColor: const Color(0xFFE9D5FF),
        avatarLabel: 'DS',
        isPinned: true,
        isMuted: true,
      ),
      ConversationPreview(
        id: 'alex-morgan',
        name: 'Alex Morgan',
        lastMessage: 'Let us keep the MVP lightweight and clean.',
        timestamp: now.subtract(const Duration(hours: 3, minutes: 5)),
        type: ConversationPreviewType.text,
        unreadCount: 0,
        avatarColor: const Color(0xFFDCEEFB),
        avatarLabel: 'AM',
      ),
      ConversationPreview(
        id: 'product-team',
        name: 'Product Team',
        lastMessage: 'Sprint review starts at 4:30 PM.',
        timestamp: now.subtract(const Duration(hours: 6)),
        type: ConversationPreviewType.text,
        unreadCount: 8,
        avatarColor: const Color(0xFFFFEDD5),
        avatarLabel: 'PT',
        isMuted: true,
      ),
      ConversationPreview(
        id: 'nina-singh',
        name: 'Nina Singh',
        lastMessage: 'Photo',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        type: ConversationPreviewType.image,
        unreadCount: 0,
        avatarColor: const Color(0xFFFDE2E4),
        avatarLabel: 'NS',
      ),
    ];
  }
}
