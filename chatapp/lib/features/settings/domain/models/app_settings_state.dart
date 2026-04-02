import 'package:flutter/material.dart';

enum AppThemePreference {
  light,
  dark;

  String get label => switch (this) {
    AppThemePreference.light => 'Light',
    AppThemePreference.dark => 'Dark',
  };

  ThemeMode get themeMode => switch (this) {
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };
}

enum AppFontOption {
  inter,
  manrope,
  nunitoSans;

  String get label => switch (this) {
    AppFontOption.inter => 'Inter',
    AppFontOption.manrope => 'Manrope',
    AppFontOption.nunitoSans => 'Nunito Sans',
  };

  String get storageValue => name;

  static AppFontOption fromStorage(String? value) {
    return AppFontOption.values.firstWhere(
      (option) => option.storageValue == value,
      orElse: () => AppFontOption.inter,
    );
  }
}

enum ChatBackgroundStyle {
  mist,
  sage,
  midnight,
  paper,
  bloom;

  String get label => switch (this) {
    ChatBackgroundStyle.mist => 'Mist',
    ChatBackgroundStyle.sage => 'Sage',
    ChatBackgroundStyle.midnight => 'Midnight',
    ChatBackgroundStyle.paper => 'Paper',
    ChatBackgroundStyle.bloom => 'Bloom',
  };

  bool get isImage =>
      this == ChatBackgroundStyle.paper || this == ChatBackgroundStyle.bloom;

  Color get previewColor => switch (this) {
    ChatBackgroundStyle.mist => const Color(0xFFE8EEF4),
    ChatBackgroundStyle.sage => const Color(0xFFD8ECDD),
    ChatBackgroundStyle.midnight => const Color(0xFF111827),
    ChatBackgroundStyle.paper => const Color(0xFFF4F1EA),
    ChatBackgroundStyle.bloom => const Color(0xFFF6DDEB),
  };

  String get storageValue => name;

  static ChatBackgroundStyle fromStorage(String? value) {
    return ChatBackgroundStyle.values.firstWhere(
      (style) => style.storageValue == value,
      orElse: () => ChatBackgroundStyle.mist,
    );
  }
}

class AppSettingsState {
  const AppSettingsState({
    this.themePreference = AppThemePreference.light,
    this.fontOption = AppFontOption.inter,
    this.textScale = 1,
    this.chatBackgroundStyle = ChatBackgroundStyle.mist,
  });

  final AppThemePreference themePreference;
  final AppFontOption fontOption;
  final double textScale;
  final ChatBackgroundStyle chatBackgroundStyle;

  ThemeMode get themeMode => themePreference.themeMode;

  AppSettingsState copyWith({
    AppThemePreference? themePreference,
    AppFontOption? fontOption,
    double? textScale,
    ChatBackgroundStyle? chatBackgroundStyle,
  }) {
    return AppSettingsState(
      themePreference: themePreference ?? this.themePreference,
      fontOption: fontOption ?? this.fontOption,
      textScale: textScale ?? this.textScale,
      chatBackgroundStyle: chatBackgroundStyle ?? this.chatBackgroundStyle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themePreference': themePreference.name,
      'fontOption': fontOption.storageValue,
      'textScale': textScale,
      'chatBackgroundStyle': chatBackgroundStyle.storageValue,
    };
  }

  factory AppSettingsState.fromJson(Map<String, dynamic> json) {
    final rawTextScale = (json['textScale'] as num?)?.toDouble() ?? 1;
    return AppSettingsState(
      themePreference: AppThemePreference.values.firstWhere(
        (option) => option.name == json['themePreference'],
        orElse: () => AppThemePreference.light,
      ),
      fontOption: AppFontOption.fromStorage(json['fontOption'] as String?),
      textScale: rawTextScale.clamp(0.9, 1.25),
      chatBackgroundStyle: ChatBackgroundStyle.fromStorage(
        json['chatBackgroundStyle'] as String?,
      ),
    );
  }
}
