import 'package:flutter/foundation.dart';

import 'package:chatapp/features/inbox/data/inbox_repository.dart';
import 'package:chatapp/features/inbox/domain/models/conversation_preview.dart';
import 'package:chatapp/features/inbox/domain/models/inbox_filter.dart';
import 'package:chatapp/features/inbox/presentation/models/inbox_view_state.dart';

class InboxController extends ValueNotifier<InboxViewState> {
  InboxController({required InboxRepository repository})
    : _allConversations = List.unmodifiable(repository.getConversations()),
      super(const InboxViewState()) {
    _recompute();
  }

  final List<ConversationPreview> _allConversations;

  void updateQuery(String query) {
    final normalizedQuery = query.trim();
    if (normalizedQuery == value.query) {
      return;
    }

    _recompute(query: normalizedQuery);
  }

  void clearQuery() {
    updateQuery('');
  }

  void updateFilter(InboxFilter filter) {
    if (filter == value.selectedFilter) {
      return;
    }

    _recompute(selectedFilter: filter);
  }

  void _recompute({String? query, InboxFilter? selectedFilter}) {
    final nextQuery = query ?? value.query;
    final nextFilter = selectedFilter ?? value.selectedFilter;
    final normalizedQuery = nextQuery.toLowerCase();
    final visibleConversations = _allConversations
        .where((conversation) {
          final matchesQuery =
              normalizedQuery.isEmpty ||
              conversation.name.toLowerCase().contains(normalizedQuery) ||
              conversation.lastMessage.toLowerCase().contains(normalizedQuery);

          if (!matchesQuery) {
            return false;
          }

          switch (nextFilter) {
            case InboxFilter.all:
              return true;
            case InboxFilter.unread:
              return conversation.hasUnread;
            case InboxFilter.pinned:
              return conversation.isPinned;
          }
        })
        .toList(growable: false);

    value = value.copyWith(
      query: nextQuery,
      selectedFilter: nextFilter,
      visibleConversations: visibleConversations,
    );
  }
}
