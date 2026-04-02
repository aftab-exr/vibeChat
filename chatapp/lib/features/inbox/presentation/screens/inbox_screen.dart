import 'package:flutter/material.dart';

import 'package:chatapp/app/routes/app_routes.dart';
import 'package:chatapp/core/design/app_spacing.dart';
import 'package:chatapp/core/widgets/app_icon_badge.dart';
import 'package:chatapp/core/widgets/app_surface_card.dart';
import 'package:chatapp/features/inbox/data/inbox_repository.dart';
import 'package:chatapp/features/inbox/domain/models/inbox_filter.dart';
import 'package:chatapp/features/inbox/presentation/controllers/inbox_controller.dart';
import 'package:chatapp/features/inbox/presentation/models/inbox_view_state.dart';
import 'package:chatapp/features/inbox/presentation/widgets/conversation_tile.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: InboxTabView());
  }
}

class InboxTabView extends StatefulWidget {
  const InboxTabView({super.key});

  @override
  State<InboxTabView> createState() => _InboxTabViewState();
}

class _InboxTabViewState extends State<InboxTabView> {
  late final TextEditingController _searchController;
  late final InboxController _controller;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _controller = InboxController(repository: const InboxRepository());
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ValueListenableBuilder<InboxViewState>(
      valueListenable: _controller,
      builder: (context, state, _) {
        final conversations = state.visibleConversations;

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xxxl,
          ),
          children: [
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const AppIconBadge(icon: Icons.forum_rounded),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'Inbox overview',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Your conversations, organized like a real messenger.',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Search, scan unread activity, and jump into any thread from one clean inbox surface.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search conversations',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: state.hasQuery
                          ? IconButton(
                              onPressed: _clearSearch,
                              icon: const Icon(Icons.close_rounded),
                            )
                          : const Icon(Icons.tune_rounded),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: InboxFilter.values.map((filter) {
                  final isSelected = filter == state.selectedFilter;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: filter == InboxFilter.values.last
                          ? 0
                          : AppSpacing.md,
                    ),
                    child: FilterChip(
                      selected: isSelected,
                      showCheckmark: false,
                      label: Text(filter.label),
                      onSelected: (_) => _controller.updateFilter(filter),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Text('Recent chats', style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(
                  '${conversations.length} threads',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (conversations.isEmpty)
              AppSurfaceCard(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                tone: AppSurfaceTone.muted,
                includeShadow: false,
                child: Column(
                  children: [
                    AppIconBadge(
                      icon: Icons.search_off_rounded,
                      color: colorScheme.onSurfaceVariant,
                      backgroundColor: colorScheme.surface,
                      size: 64,
                      iconSize: 26,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('No chats found', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Try a different search term or switch filters.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...conversations.map(
                (conversation) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: ConversationTile(
                    conversation: conversation,
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.chat,
                      arguments: conversation.toChatArgs(),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _handleSearchChanged() {
    _controller.updateQuery(_searchController.text);
  }

  void _clearSearch() {
    _searchController.clear();
    _controller.clearQuery();
  }
}
