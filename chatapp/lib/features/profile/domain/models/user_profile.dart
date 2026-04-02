import 'package:flutter/material.dart';

class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.username,
    required this.phone,
    required this.email,
    required this.avatarLabel,
    required this.status,
    required this.about,
    required this.seedColor,
    required this.userId,
  });

  final String displayName;
  final String username;
  final String phone;
  final String email;
  final String avatarLabel;
  final String status;
  final String about;
  final Color seedColor;
  final int userId;
}
