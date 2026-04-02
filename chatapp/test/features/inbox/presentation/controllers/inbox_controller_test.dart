import 'package:flutter_test/flutter_test.dart';

import 'package:chatapp/features/inbox/data/inbox_repository.dart';
import 'package:chatapp/features/inbox/domain/models/inbox_filter.dart';
import 'package:chatapp/features/inbox/presentation/controllers/inbox_controller.dart';

void main() {
  test('filters inbox conversations by query and filter', () {
    final controller = InboxController(repository: const InboxRepository());

    expect(controller.value.visibleConversations, hasLength(6));

    controller.updateFilter(InboxFilter.unread);
    expect(controller.value.selectedFilter, InboxFilter.unread);
    expect(controller.value.visibleConversations, hasLength(3));

    controller.updateQuery('maya');
    expect(controller.value.query, 'maya');
    expect(controller.value.visibleConversations, hasLength(1));
    expect(controller.value.visibleConversations.first.name, 'Maya Chen');

    controller.clearQuery();
    expect(controller.value.query, isEmpty);
    expect(controller.value.visibleConversations, hasLength(3));

    controller.updateFilter(InboxFilter.pinned);
    expect(controller.value.visibleConversations, hasLength(2));

    controller.dispose();
  });
}
