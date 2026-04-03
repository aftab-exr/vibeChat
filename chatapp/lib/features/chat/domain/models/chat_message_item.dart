class ChatMessageItem {
  const ChatMessageItem({
    this.text,
    this.imageUrl,
    this.audioUrl,
    this.encryptionKey,
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
      encryptionKey: map['encryption_key'] as String?,
      
      // 🔐 NEW: Safely parse the MongoDB String ID without trying to force it into an int
      senderId: rawSenderId?.toString(), 
      
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
  final String? encryptionKey;
  
  // 🔐 NEW: Changed from int? to String?
  final String? senderId; 
  final DateTime? createdAt;

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;

  // 🔐 NEW: Update the comparison to expect a String?
  bool isFromUser(String? userId) => senderId == userId; 
}