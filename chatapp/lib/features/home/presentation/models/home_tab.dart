import 'package:flutter/material.dart';

enum HomeTab {
  inbox(
    label: 'Inbox',
    icon: Icons.chat_bubble_outline_rounded,
    selectedIcon: Icons.chat_bubble_rounded,
  ),
  calls(
    label: 'Calls',
    icon: Icons.call_outlined,
    selectedIcon: Icons.call_rounded,
  ),
  profile(
    label: 'Profile',
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
  ),
  settings(
    label: 'Settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
  );

  const HomeTab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
