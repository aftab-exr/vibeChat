import 'package:flutter/material.dart';

import 'package:chatapp/features/auth/domain/models/auth_session.dart';
import 'package:chatapp/features/profile/domain/models/user_profile.dart';

class ProfileRepository {
  const ProfileRepository();

  static const List<Color> _palette = [
    Color(0xFF1F6FEB),
    Color(0xFF0F8B7E),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFF14B8A6),
  ];

  UserProfile buildProfile(AuthSession? session) {
    final authUser = session?.user;
    final rawUsername = authUser?.username.trim();
    final username = (rawUsername != null && rawUsername.isNotEmpty)
        ? rawUsername
        : 'guest_user';
    final userId = authUser?.id ?? 0;
    final displayName = _displayName(username);
    final slug = _slug(username);

    return UserProfile(
      displayName: displayName,
      username: '@$slug',
      phone: _phoneForId(userId),
      email: '$slug@vibechat.app',
      avatarLabel: _avatarLabel(displayName),
      status: 'Available on VibeChat',
      about: 'Building cleaner conversations with a lightweight MVP mindset.',
      seedColor: _palette[userId % _palette.length],
      userId: userId,
    );
  }

  String _displayName(String username) {
    final cleaned = username.replaceAll(RegExp(r'[_\-.]+'), ' ').trim();
    if (cleaned.isEmpty) {
      return 'Guest User';
    }

    return cleaned
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _slug(String username) {
    final cleaned = username.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '.',
    );
    return cleaned.replaceAll(RegExp(r'^\.|\.$'), '').replaceAll('..', '.');
  }

  String _avatarLabel(String displayName) {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'GU';
    }
    if (parts.length == 1) {
      final word = parts.first;
      return word.length >= 2
          ? word.substring(0, 2).toUpperCase()
          : word.toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _phoneForId(int userId) {
    final base = (userId * 1731 + 54892).abs().toString().padLeft(10, '0');
    final digits = base.substring(base.length - 10);
    return '+91 ${digits.substring(0, 5)} ${digits.substring(5)}';
  }
}
