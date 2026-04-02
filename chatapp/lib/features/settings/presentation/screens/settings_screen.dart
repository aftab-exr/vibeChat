import 'package:flutter/material.dart';

import 'package:chatapp/app/auth_scope.dart';
import 'package:chatapp/app/routes/app_routes.dart';
import 'package:chatapp/app/settings_scope.dart';
import 'package:chatapp/core/design/app_colors.dart';
import 'package:chatapp/core/design/app_shadows.dart';
import 'package:chatapp/core/design/app_spacing.dart';
import 'package:chatapp/core/widgets/app_icon_badge.dart';
import 'package:chatapp/core/widgets/app_surface_card.dart';
import 'package:chatapp/core/widgets/tab_section_card.dart';
import 'package:chatapp/features/settings/domain/models/app_settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SettingsTabView());
  }
}

class SettingsTabView extends StatelessWidget {
  const SettingsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = AuthScope.of(context);
    final settingsController = SettingsScope.of(context);
    final settings = settingsController.value;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      children: [
        AppSurfaceCard(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          includeBorder: false,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.accent, AppColors.accentDark],
          ),
          boxShadow: AppShadows.accent(AppColors.accent),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AppIconBadge(
                    icon: Icons.tune_rounded,
                    color: Colors.white,
                    backgroundColor: Color(0x26FFFFFF),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Preferences',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Personalize the app your way.',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Theme mode, Google Fonts, text size, background choices, and account actions all live here now.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.86),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        TabSectionCard(
          title: 'Appearance',
          subtitle:
              'Control brightness, typography, and reading comfort across the app.',
          leading: const AppIconBadge(icon: Icons.palette_outlined),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Theme', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: AppThemePreference.values.map((option) {
                  final isSelected = option == settings.themePreference;
                  return ChoiceChip(
                    label: Text(option.label),
                    selected: isSelected,
                    onSelected: (_) {
                      settingsController.updateThemePreference(option);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Font family', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: AppFontOption.values.map((option) {
                  final isSelected = option == settings.fontOption;
                  return ChoiceChip(
                    label: Text(option.label),
                    selected: isSelected,
                    onSelected: (_) {
                      settingsController.updateFontOption(option);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Text('Text size', style: theme.textTheme.titleMedium),
                  const Spacer(),
                  Text(
                    '${(settings.textScale * 100).round()}%',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              Slider(
                min: 0.9,
                max: 1.25,
                divisions: 7,
                value: settings.textScale,
                label: '${(settings.textScale * 100).round()}%',
                onChanged: (value) {
                  settingsController.updateTextScale(value);
                },
              ),
              AppSurfaceCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                tone: AppSurfaceTone.subtle,
                includeShadow: false,
                child: Text(
                  'Preview text adapts instantly so you can tune readability without leaving the screen.',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        TabSectionCard(
          title: 'Chat background',
          subtitle:
              'Choose a color or image-style backdrop for your conversation screen.',
          leading: const AppIconBadge(icon: Icons.wallpaper_outlined),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ChatBackgroundStyle.values.map((style) {
                final isSelected = style == settings.chatBackgroundStyle;
                return Padding(
                  padding: EdgeInsets.only(
                    right: style == ChatBackgroundStyle.values.last
                        ? 0
                        : AppSpacing.md,
                  ),
                  child: _BackgroundOptionCard(
                    style: style,
                    isSelected: isSelected,
                    onTap: () =>
                        settingsController.updateChatBackgroundStyle(style),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        TabSectionCard(
          title: 'Account actions',
          subtitle:
              'Sign out securely or review the delete-account flow UI before backend support is added.',
          leading: const AppIconBadge(icon: Icons.shield_outlined),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    await authController.logout();
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.login,
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Logout'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showDeleteAccountDialog(context),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Delete account'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Delete account is UI only in this step. No backend deletion request is sent yet.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete account'),
          content: const Text(
            'This step only implements the confirmation UI. No account data will be deleted yet.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Delete account UI confirmed. Backend action is not wired yet.',
          ),
        ),
      );
  }
}

class _BackgroundOptionCard extends StatelessWidget {
  const _BackgroundOptionCard({
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  final ChatBackgroundStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        width: 128,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration:
            AppSurfaceCard.decoration(
              context,
              borderColor: isSelected ? AppColors.accent : colorScheme.outline,
              boxShadow: isSelected
                  ? AppShadows.accent(AppColors.accent)
                  : null,
            ).copyWith(
              border: Border.all(
                color: isSelected ? AppColors.accent : colorScheme.outline,
                width: isSelected ? 1.5 : 1,
              ),
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: style.isImage
                    ? LinearGradient(
                        colors: [
                          style.previewColor,
                          style.previewColor.withValues(alpha: 0.7),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          style.previewColor,
                          style.previewColor.withValues(alpha: 0.72),
                        ],
                      ),
              ),
              child: Stack(
                children: [
                  if (style.isImage)
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.2,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(
                            Icons.image_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  if (isSelected)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(style.label, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              style.isImage ? 'Image style' : 'Color style',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
