import 'package:flutter/foundation.dart';

import 'package:chatapp/features/settings/data/settings_storage.dart';
import 'package:chatapp/features/settings/domain/models/app_settings_state.dart';

class AppSettingsController extends ValueNotifier<AppSettingsState> {
  AppSettingsController({required SettingsStorage storage})
    : _storage = storage,
      super(const AppSettingsState());

  final SettingsStorage _storage;

  Future<void> bootstrap() async {
    value = await _storage.readSettings();
  }

  Future<void> updateThemePreference(AppThemePreference preference) async {
    await _save(value.copyWith(themePreference: preference));
  }

  Future<void> updateFontOption(AppFontOption fontOption) async {
    await _save(value.copyWith(fontOption: fontOption));
  }

  Future<void> updateTextScale(double textScale) async {
    await _save(value.copyWith(textScale: textScale));
  }

  Future<void> updateChatBackgroundStyle(ChatBackgroundStyle style) async {
    await _save(value.copyWith(chatBackgroundStyle: style));
  }

  Future<void> _save(AppSettingsState nextState) async {
    value = nextState;
    await _storage.saveSettings(nextState);
  }
}
