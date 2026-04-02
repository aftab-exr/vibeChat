import 'package:chatapp/features/inbox/domain/models/conversation_preview.dart';
import 'package:chatapp/features/inbox/domain/models/inbox_filter.dart';

class InboxViewState {
  const InboxViewState({
    this.query = '',
    this.selectedFilter = InboxFilter.all,
    this.visibleConversations = const [],
  });

  final String query;
  final InboxFilter selectedFilter;
  final List<ConversationPreview> visibleConversations;

  bool get hasQuery => query.isNotEmpty;

  InboxViewState copyWith({
    String? query,
    InboxFilter? selectedFilter,
    List<ConversationPreview>? visibleConversations,
  }) {
    return InboxViewState(
      query: query ?? this.query,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      visibleConversations: visibleConversations ?? this.visibleConversations,
    );
  }
}
