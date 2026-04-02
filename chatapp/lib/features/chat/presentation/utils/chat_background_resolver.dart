import 'package:flutter/material.dart';

import 'package:chatapp/features/settings/domain/models/app_settings_state.dart';

BoxDecoration buildChatBackgroundDecoration(ChatBackgroundStyle style) {
  switch (style) {
    case ChatBackgroundStyle.mist:
      return const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF1F5F9), Color(0xFFE8EEF4)],
        ),
      );
    case ChatBackgroundStyle.sage:
      return const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEAF4EC), Color(0xFFD9EBDD)],
        ),
      );
    case ChatBackgroundStyle.midnight:
      return const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF111827), Color(0xFF1F2937)],
        ),
      );
    case ChatBackgroundStyle.paper:
      return const BoxDecoration(
        color: Color(0xFFF6F1E8),
        image: DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=1200&q=80',
          ),
          fit: BoxFit.cover,
          opacity: 0.12,
        ),
      );
    case ChatBackgroundStyle.bloom:
      return const BoxDecoration(
        color: Color(0xFFF8EDF4),
        image: DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1493246318656-5bfd4cfb29b8?auto=format&fit=crop&w=1200&q=80',
          ),
          fit: BoxFit.cover,
          opacity: 0.15,
        ),
      );
  }
}
