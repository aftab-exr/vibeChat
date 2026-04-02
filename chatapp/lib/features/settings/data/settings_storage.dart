import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:chatapp/features/settings/domain/models/app_settings_state.dart';

class SettingsStorage {
  const SettingsStorage();

  static const String _settingsKey = 'app_settings';

  Future<AppSettingsState> readSettings() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_settingsKey);
    if (raw == null || raw.isEmpty) {
      return const AppSettingsState();
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const AppSettingsState();
      }
      return AppSettingsState.fromJson(decoded);
    } catch (_) {
      return const AppSettingsState();
    }
  }

  Future<void> saveSettings(AppSettingsState settings) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_settingsKey, jsonEncode(settings.toJson()));
  }
}
