String formatChatTimestamp(DateTime? timestamp, {DateTime? now}) {
  if (timestamp == null) {
    return 'Now';
  }

  final localTime = timestamp.toLocal();
  final currentTime = now ?? DateTime.now();

  if (currentTime.year == localTime.year &&
      currentTime.month == localTime.month &&
      currentTime.day == localTime.day) {
    final hour = localTime.hour % 12 == 0 ? 12 : localTime.hour % 12;
    final minute = localTime.minute.toString().padLeft(2, '0');
    final suffix = localTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  final yesterday = currentTime.subtract(const Duration(days: 1));
  if (yesterday.year == localTime.year &&
      yesterday.month == localTime.month &&
      yesterday.day == localTime.day) {
    return 'Yesterday';
  }

  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[localTime.weekday - 1];
}
