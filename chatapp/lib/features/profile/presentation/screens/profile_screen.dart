import 'package:flutter/material.dart';

import 'package:chatapp/app/auth_scope.dart';
import 'package:chatapp/core/design/app_radius.dart';
import 'package:chatapp/core/design/app_shadows.dart';
import 'package:chatapp/core/design/app_spacing.dart';
import 'package:chatapp/core/widgets/app_icon_badge.dart';
import 'package:chatapp/core/widgets/app_surface_card.dart';
import 'package:chatapp/core/widgets/tab_section_card.dart';
import 'package:chatapp/features/profile/data/profile_repository.dart';
import 'package:chatapp/features/profile/domain/models/user_profile.dart';
import 'package:chatapp/features/profile/presentation/widgets/profile_info_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: ProfileTabView());
  }
}

class ProfileTabView extends StatelessWidget {
  const ProfileTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = AuthScope.of(context).value.session;
    final profile = const ProfileRepository().buildProfile(session);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      children: [
        _ProfileHeroCard(profile: profile),
        const SizedBox(height: AppSpacing.xl),
        TabSectionCard(
          title: 'Profile details',
          subtitle:
              'Your core identity and contact information are now visible in one clean screen.',
          leading: AppIconBadge(
            icon: Icons.account_circle_outlined,
            color: profile.seedColor,
          ),
          child: Column(
            children: [
              ProfileInfoTile(
                icon: Icons.badge_outlined,
                label: 'Name',
                value: profile.displayName,
                supportingText: 'Shown across your conversations and account.',
              ),
              const SizedBox(height: AppSpacing.md),
              ProfileInfoTile(
                icon: Icons.call_outlined,
                label: 'Phone',
                value: profile.phone,
                supportingText: 'Primary contact number for your account.',
              ),
              const SizedBox(height: AppSpacing.md),
              ProfileInfoTile(
                icon: Icons.mail_outline_rounded,
                label: 'Email',
                value: profile.email,
                supportingText: 'Used for account communication and recovery.',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        TabSectionCard(
          title: 'Account snapshot',
          subtitle:
              'A few lightweight details that make the profile feel complete without adding backend complexity.',
          leading: AppIconBadge(
            icon: Icons.verified_user_outlined,
            color: profile.seedColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileMetaRow(label: 'Username', value: profile.username),
              const SizedBox(height: AppSpacing.md),
              _ProfileMetaRow(label: 'User ID', value: '#${profile.userId}'),
              const SizedBox(height: AppSpacing.md),
              AppSurfaceCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                tone: AppSurfaceTone.subtle,
                radius: AppRadius.lg,
                includeShadow: false,
                child: Text(profile.about, style: theme.textTheme.bodyLarge),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      includeBorder: false,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [profile.seedColor, profile.seedColor.withValues(alpha: 0.82)],
      ),
      boxShadow: AppShadows.accent(profile.seedColor),
      child: Column(
        children: [
          Container(
            width: 112,
            height: 112,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
              ),
              alignment: Alignment.center,
              child: Text(
                profile.avatarLabel,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            profile.displayName,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            profile.status,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _HeroChip(icon: Icons.image_outlined, label: 'Profile image'),
              _HeroChip(
                icon: Icons.phone_android_outlined,
                label: 'Mobile account',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMetaRow extends StatelessWidget {
  const _ProfileMetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: theme.textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
