import 'package:flutter/material.dart';

import 'package:chatapp/core/design/app_colors.dart';
import 'package:chatapp/core/design/app_radius.dart';
import 'package:chatapp/core/design/app_shadows.dart';
import 'package:chatapp/core/design/app_spacing.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.avatarLabel,
    required this.onBack,
    required this.onVideoCall,
    required this.onVoiceCall,
  });

  final String title;
  final String subtitle;
  final String avatarLabel;
  final VoidCallback onBack;
  final VoidCallback onVideoCall;
  final VoidCallback onVoiceCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent, AppColors.accentDark],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.accent(AppColors.accent),
      ),
      child: Row(
        children: [
          _ChatHeaderAction(
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: onBack,
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              avatarLabel,
              style: const TextStyle(
                color: AppColors.accentDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _ChatHeaderAction(
            icon: Icons.videocam_rounded,
            onPressed: onVideoCall,
          ),
          const SizedBox(width: AppSpacing.sm),
          _ChatHeaderAction(icon: Icons.call_rounded, onPressed: onVoiceCall),
        ],
      ),
    );
  }
}

class _ChatHeaderAction extends StatelessWidget {
  const _ChatHeaderAction({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}
