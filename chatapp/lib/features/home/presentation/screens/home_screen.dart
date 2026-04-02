import 'package:flutter/material.dart';

import 'package:chatapp/app/auth_scope.dart';
import 'package:chatapp/app/routes/app_routes.dart';
import 'package:chatapp/core/design/app_radius.dart';
import 'package:chatapp/core/design/app_spacing.dart';
import 'package:chatapp/core/widgets/app_surface_card.dart';
import 'package:chatapp/features/calls/presentation/screens/calls_screen.dart';
import 'package:chatapp/features/home/presentation/controllers/home_controller.dart';
import 'package:chatapp/features/home/presentation/models/home_tab.dart';
import 'package:chatapp/features/inbox/presentation/screens/inbox_screen.dart';
import 'package:chatapp/features/profile/presentation/screens/profile_screen.dart';
import 'package:chatapp/features/settings/presentation/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialTab = HomeTab.inbox});

  final HomeTab initialTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController(initialTab: widget.initialTab);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _controller.syncInitialTab(widget.initialTab);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = AuthScope.of(context);
    final session = authController.value.session;
    final tabs = HomeTab.values;

    return ValueListenableBuilder<HomeTab>(
      valueListenable: _controller,
      builder: (context, currentTab, _) {
        final selectedIndex = _controller.selectedIndex;

        return Scaffold(
          appBar: _HomeAppBar(
            currentTab: currentTab,
            username: session?.user.username ?? 'Guest',
            onOpenChat: () => Navigator.of(context).pushNamed(AppRoutes.chat),
            onLogout: () async {
              await authController.logout();
              if (!context.mounted) {
                return;
              }

              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
            },
          ),
          body: SafeArea(
            top: false,
            child: IndexedStack(
              index: selectedIndex,
              children: const [
                InboxTabView(),
                CallsTabView(),
                ProfileTabView(),
                SettingsTabView(),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: AppSurfaceCard(
                padding: EdgeInsets.zero,
                radius: AppRadius.xl,
                child: NavigationBar(
                  selectedIndex: selectedIndex,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  onDestinationSelected: (index) {
                    _controller.selectTab(tabs[index]);
                  },
                  destinations: tabs
                      .map(
                        (tab) => NavigationDestination(
                          icon: Icon(tab.icon),
                          selectedIcon: Icon(tab.selectedIcon),
                          label: tab.label,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomeAppBar({
    required this.currentTab,
    required this.username,
    required this.onOpenChat,
    required this.onLogout,
  });

  final HomeTab currentTab;
  final String username;
  final VoidCallback onOpenChat;
  final VoidCallback onLogout;

  @override
  Size get preferredSize => const Size.fromHeight(88);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      toolbarHeight: 88,
      titleSpacing: 16,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(currentTab.label, style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            _subtitleText(currentTab, username),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        if (currentTab == HomeTab.inbox)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: IconButton.filledTonal(
              onPressed: onOpenChat,
              icon: const Icon(Icons.forum_rounded),
              tooltip: 'Open chat',
            ),
          ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') {
              onLogout();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
          ],
          icon: Container(
            width: 42,
            height: 42,
            margin: const EdgeInsets.only(right: AppSpacing.lg),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            alignment: Alignment.center,
            child: Text(
              username.isEmpty ? 'G' : username[0].toUpperCase(),
              style: theme.textTheme.titleMedium,
            ),
          ),
        ),
      ],
    );
  }

  String _subtitleText(HomeTab tab, String username) {
    switch (tab) {
      case HomeTab.inbox:
        return 'Pick up where you left off, $username.';
      case HomeTab.calls:
        return 'Your recent conversations and calling activity.';
      case HomeTab.profile:
        return 'Identity, contact details, and account snapshot.';
      case HomeTab.settings:
        return 'Preferences, appearance, and account controls.';
    }
  }
}
