import 'package:flutter_test/flutter_test.dart';

import 'package:chatapp/features/chat/domain/models/chat_message_item.dart';

void main() {
  test('builds a chat message item from backend message data', () {
    final item = ChatMessageItem.fromMap({
      'text': 'hello',
      'image': 'https://example.com/image.png',
      'audio': 'https://example.com/audio.m4a',
      'user_id': '7',
      'created_at': '2026-04-02T10:15:00.000Z',
    });

    expect(item.text, 'hello');
    expect(item.imageUrl, 'https://example.com/image.png');
    expect(item.audioUrl, 'https://example.com/audio.m4a');
    expect(item.senderId, 7);
    expect(item.createdAt, DateTime.parse('2026-04-02T10:15:00.000Z'));
    expect(item.hasImage, isTrue);
    expect(item.hasAudio, isTrue);
    expect(item.isFromUser(7), isTrue);
  });
}
