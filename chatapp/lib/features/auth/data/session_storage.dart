import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:chatapp/features/auth/domain/models/auth_session.dart';

class SessionStorage {
  const SessionStorage();

  static const String _sessionKey = 'auth_session';

  Future<AuthSession?> readSession() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_sessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return AuthSession.fromJson(decoded);
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  Future<void> saveSession(AuthSession session) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  Future<void> clearSession() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_sessionKey);
  }
}
