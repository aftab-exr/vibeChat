import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:chatapp/core/design/app_radius.dart';
import 'package:chatapp/core/design/app_shadows.dart';
import 'package:chatapp/core/design/app_spacing.dart';

class ChatCallPreview extends StatelessWidget {
  const ChatCallPreview({
    super.key,
    required this.localRenderer,
    required this.remoteRenderer,
    required this.onEndCall,
  });

  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;
  final VoidCallback onEndCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.lg),
      height: 176,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF102A43),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.lg,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: remoteRenderer.srcObject != null
                ? RTCVideoView(remoteRenderer)
                : const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF102A43), Color(0xFF0B2239)],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Connecting call...',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
          ),
          if (localRenderer.srcObject != null)
            Positioned(
              right: 12,
              bottom: 12,
              child: SizedBox(
                width: 96,
                height: 124,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: RTCVideoView(localRenderer, mirror: true),
                ),
              ),
            ),
          Positioned(
            left: 14,
            bottom: 14,
            child: _ChatCallAction(
              icon: Icons.call_end_rounded,
              background: const Color(0xFFEF4444),
              onPressed: onEndCall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatCallAction extends StatelessWidget {
  const _ChatCallAction({
    required this.icon,
    required this.background,
    required this.onPressed,
  });

  final IconData icon;
  final Color background;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}
