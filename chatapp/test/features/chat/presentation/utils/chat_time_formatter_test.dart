import 'package:flutter_test/flutter_test.dart';

import 'package:chatapp/features/chat/presentation/utils/chat_time_formatter.dart';

void main() {
  test('formats same-day timestamps as time', () {
    final now = DateTime(2026, 4, 2, 18, 0);
    final timestamp = DateTime(2026, 4, 2, 9, 5);

    expect(formatChatTimestamp(timestamp, now: now), '9:05 AM');
  });

  test('formats previous-day timestamps as yesterday', () {
    final now = DateTime(2026, 4, 2, 18, 0);
    final timestamp = DateTime(2026, 4, 1, 22, 30);

    expect(formatChatTimestamp(timestamp, now: now), 'Yesterday');
  });

  test('formats older timestamps as weekday', () {
    final now = DateTime(2026, 4, 2, 18, 0);
    final timestamp = DateTime(2026, 3, 30, 12, 0);

    expect(formatChatTimestamp(timestamp, now: now), 'Mon');
  });

  test('falls back to now label when timestamp is missing', () {
    expect(formatChatTimestamp(null), 'Now');
  });
}
