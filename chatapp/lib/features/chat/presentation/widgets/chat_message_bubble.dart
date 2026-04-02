import 'dart:typed_data'; // 🔐 NEW: Required for Uint8List
import 'package:flutter/material.dart';

import 'package:chatapp/core/design/app_colors.dart';
import 'package:chatapp/core/design/app_radius.dart';
import 'package:chatapp/core/design/app_shadows.dart';
import 'package:chatapp/core/design/app_spacing.dart';
import 'package:chatapp/features/chat/data/encryption_service.dart'; // 🔐 NEW: Import your encryption service

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.isMe,
    required this.timeLabel,
    this.text,
    this.imageUrl,
    this.audioUrl,
    this.encryptionKey, // 🔐 NEW: Accept encryption key
    this.isAudioPlaying = false,
    this.onAudioPressed,
    this.onImagePressed,
  });

  final bool isMe;
  final String timeLabel;
  final String? text;
  final String? imageUrl;
  final String? audioUrl;
  final String? encryptionKey; // 🔐 NEW: Encryption key field
  final bool isAudioPlaying;
  final VoidCallback? onAudioPressed;
  final VoidCallback? onImagePressed;

  bool get _hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get _hasAudio => audioUrl != null && audioUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bubbleColor = isMe ? AppColors.accentDark : colorScheme.surface;
    final textColor = isMe ? Colors.white : colorScheme.onSurface;
    final secondaryColor = isMe
        ? Colors.white.withValues(alpha: 0.72)
        : colorScheme.onSurfaceVariant;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.74,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: EdgeInsets.all(_hasImage ? 6 : AppSpacing.lg),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(AppRadius.xl),
              topRight: const Radius.circular(AppRadius.xl),
              bottomLeft: Radius.circular(isMe ? AppRadius.xl : 8),
              bottomRight: Radius.circular(isMe ? 8 : AppRadius.xl),
            ),
            boxShadow: AppShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_hasImage)
                _ImageMessage(
                  imageUrl: imageUrl!, 
                  encryptionKey: encryptionKey, // 🔐 NEW: Pass key to image widget
                  onPressed: onImagePressed
                )
              else if (_hasAudio)
                _AudioMessage(
                  isMe: isMe,
                  isPlaying: isAudioPlaying,
                  onPressed: onAudioPressed,
                )
              else
                Text(
                  text ?? '',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isMe) ...[
                    Icon(
                      Icons.done_all_rounded,
                      size: 14,
                      color: secondaryColor,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    timeLabel,
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageMessage extends StatelessWidget {
  const _ImageMessage({
    required this.imageUrl, 
    this.encryptionKey, // 🔐 NEW
    this.onPressed
  });

  final String imageUrl;
  final String? encryptionKey; // 🔐 NEW
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final surfaceTint = Theme.of(context).colorScheme.surfaceContainerHighest;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 1,
              // 🔐 NEW: Replaced Image.network with FutureBuilder + Image.memory
              child: FutureBuilder<Uint8List?>(
                future: EncryptionService.downloadAndDecrypt(imageUrl, encryptionKey),
                builder: (context, snapshot) {
                  // Loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ColoredBox(
                      color: surfaceTint,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      ),
                    );
                  }
                  
                  // Success state (Image decrypted successfully)
                  if (snapshot.hasData && snapshot.data != null) {
                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    );
                  }
                  
                  // Error state (Failed to decrypt or download)
                  return ColoredBox(
                    color: surfaceTint,
                    child: Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.open_in_full_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ... _AudioMessage remains unchanged below this ...
class _AudioMessage extends StatelessWidget {
  const _AudioMessage({
    required this.isMe,
    required this.isPlaying,
    this.onPressed,
  });

  final bool isMe;
  final bool isPlaying;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = isMe ? Colors.white : colorScheme.onSurface;
    final muted = isMe
        ? Colors.white.withValues(alpha: 0.62)
        : colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onPressed,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isMe
                  ? Colors.white.withValues(alpha: 0.12)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            alignment: Alignment.center,
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(9, (index) {
                const heights = [6, 10, 14, 18, 12, 16, 9, 14, 7];
                return Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 3,
                    height: heights[index].toDouble(),
                    decoration: BoxDecoration(
                      color: isPlaying
                          ? primary
                          : primary.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isPlaying ? 'Playing voice note' : 'Voice message',
              style: TextStyle(
                color: muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}