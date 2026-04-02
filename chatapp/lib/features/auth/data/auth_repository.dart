import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:chatapp/core/config/app_config.dart';
import 'package:chatapp/features/auth/domain/models/auth_session.dart';
import 'package:chatapp/features/auth/domain/models/auth_user.dart';

class AuthRepository {
  const AuthRepository();

  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username.trim(), 'password': password}),
    );

    final data = _decodeBody(response.body);
    if (response.statusCode != 200) {
      throw AuthException(_extractError(data, 'Unable to sign in.'));
    }

    return AuthSession(
      token: data['token'] as String,
      user: AuthUser.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<void> register({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username.trim(), 'password': password}),
    );

    final data = _decodeBody(response.body);
    if (response.statusCode != 200) {
      throw AuthException(_extractError(data, 'Unable to create account.'));
    }
  }

  Map<String, dynamic> _decodeBody(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }

  String _extractError(Map<String, dynamic> data, String fallback) {
    final message = data['error'] ?? data['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }

    return fallback;
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
