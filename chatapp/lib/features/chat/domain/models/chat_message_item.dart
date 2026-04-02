class ChatMessageItem {
  const ChatMessageItem({
    this.text,
    this.imageUrl,
    this.audioUrl,
    this.encryptionKey, // 🔐 NEW: Added encryption key
    this.senderId,
    this.createdAt,
  });

  factory ChatMessageItem.fromMap(Map<String, dynamic> map) {
    final rawSenderId = map['user_id'];
    final rawCreatedAt = map['created_at'];

    return ChatMessageItem(
      text: map['text'] as String?,
      imageUrl: map['image'] as String?,
      audioUrl: map['audio'] as String?,
      encryptionKey: map['encryption_key'] as String?, // 🔐 NEW: Parse from map
      senderId: switch (rawSenderId) {
        int value => value,
        String value => int.tryParse(value),
        _ => null,
      },
      createdAt: switch (rawCreatedAt) {
        DateTime value => value,
        String value => DateTime.tryParse(value),
        _ => null,
      },
    );
  }

  final String? text;
  final String? imageUrl;
  final String? audioUrl;
  final String? encryptionKey; // 🔐 NEW: Store the key
  final int? senderId;
  final DateTime? createdAt;

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;

  bool isFromUser(int? userId) => senderId == userId;
}