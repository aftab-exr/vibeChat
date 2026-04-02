import 'package:flutter/material.dart';

import 'package:chatapp/core/design/app_colors.dart';
import 'package:chatapp/core/design/app_shadows.dart';
import 'package:chatapp/core/design/app_spacing.dart';
import 'package:chatapp/features/chat/presentation/widgets/chat_status_chip.dart';

class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.title,
    required this.canSendText,
    required this.isRecording,
    required this.isSendingMedia,
    required this.onSubmitted,
    required this.onAttachmentPressed,
    required this.onCameraPressed,
    required this.onPrimaryActionPressed,
  });

  final TextEditingController controller;
  final String title;
  final bool canSendText;
  final bool isRecording;
  final bool isSendingMedia;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onAttachmentPressed;
  final VoidCallback onCameraPressed;
  final VoidCallback onPrimaryActionPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final status = _statusData;

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outline),
        boxShadow: AppShadows.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status != null)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.sm,
                right: AppSpacing.sm,
                bottom: AppSpacing.md,
              ),
              child: ChatStatusChip(
                icon: status.icon,
                label: status.label,
                color: status.color,
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: isSendingMedia ? null : onAttachmentPressed,
                icon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  onSubmitted: onSubmitted,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 10,
                    ),
                    border: InputBorder.none,
                    hintText: 'Message $title',
                    hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
              IconButton(
                onPressed: isSendingMedia ? null : onCameraPressed,
                icon: Icon(
                  Icons.photo_camera_back_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.accentDark],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: AppShadows.accent(AppColors.accent),
                ),
                child: IconButton(
                  onPressed: isSendingMedia ? null : onPrimaryActionPressed,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: isSendingMedia
                        ? const SizedBox(
                            key: ValueKey('uploading'),
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Icon(
                            canSendText
                                ? Icons.send_rounded
                                : (isRecording
                                      ? Icons.stop_rounded
                                      : Icons.mic_rounded),
                            key: ValueKey(
                              '${canSendText}_${isRecording}_$isSendingMedia',
                            ),
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _ComposerStatusData? get _statusData {
    if (isRecording) {
      return const _ComposerStatusData(
        icon: Icons.mic_rounded,
        label: 'Recording voice note... tap stop when you are ready.',
        color: AppColors.accent,
      );
    }

    if (isSendingMedia) {
      return const _ComposerStatusData(
        icon: Icons.cloud_upload_rounded,
        label: 'Uploading media...',
        color: AppColors.accent,
      );
    }

    return null;
  }
}

class _ComposerStatusData {
  const _ComposerStatusData({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;
}
