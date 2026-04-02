import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:chatapp/core/design/app_colors.dart';
import 'package:chatapp/core/design/app_radius.dart';
import 'package:chatapp/features/settings/domain/models/app_settings_state.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData build({
    required AppSettingsState settings,
    required Brightness brightness,
  }) {
    final palette = _paletteFor(brightness);
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.accent,
          onPrimary: Colors.white,
          primaryContainer: AppColors.accentSoft,
          onPrimaryContainer: AppColors.accentDark,
          surface: palette.surface,
          surfaceContainer: palette.surfaceMuted,
          surfaceContainerHighest: palette.surfaceMuted,
          onSurface: palette.textPrimary,
          onSurfaceVariant: palette.textSecondary,
          outline: palette.border,
          outlineVariant: palette.border.withValues(alpha: 0.8),
          secondary: AppColors.accent,
          surfaceTint: Colors.transparent,
        );

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: palette.border),
    );
    final textTheme = _textThemeFor(settings: settings, palette: palette);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.scaffold,
      canvasColor: palette.surface,
      shadowColor: palette.shadow,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.scaffold,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: palette.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.textPrimary,
          side: BorderSide(color: palette.border),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.accent, width: 1.2),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: palette.textSecondary,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surfaceMuted,
        selectedColor: AppColors.accent.withValues(alpha: 0.12),
        side: BorderSide(color: palette.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        labelStyle: textTheme.labelLarge?.copyWith(color: palette.textPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor: AppColors.accent.withValues(alpha: 0.14),
        height: 72,
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelLarge?.copyWith(color: palette.textPrimary),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? AppColors.accent
              : palette.textSecondary;
          return IconThemeData(color: color);
        }),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      dividerColor: palette.border,
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.accent,
        thumbColor: AppColors.accent,
        inactiveTrackColor: palette.border,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: palette.surface,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: palette.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.accent,
        selectionColor: AppColors.accent.withValues(alpha: 0.22),
        selectionHandleColor: AppColors.accent,
      ),
    );
  }

  static TextTheme _textThemeFor({
    required AppSettingsState settings,
    required _ThemePalette palette,
  }) {
    final base =
        TextTheme(
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: palette.textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: palette.textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: palette.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            height: 1.45,
            color: palette.textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: palette.textSecondary,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: palette.textPrimary,
          ),
        ).apply(
          fontSizeFactor: settings.textScale,
          bodyColor: palette.textPrimary,
          displayColor: palette.textPrimary,
        );

    return switch (settings.fontOption) {
      AppFontOption.inter => GoogleFonts.interTextTheme(base),
      AppFontOption.manrope => GoogleFonts.manropeTextTheme(base),
      AppFontOption.nunitoSans => GoogleFonts.nunitoSansTextTheme(base),
    };
  }

  static _ThemePalette _paletteFor(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const _ThemePalette(
        scaffold: Color(0xFF0B1220),
        surface: Color(0xFF111827),
        surfaceMuted: Color(0xFF182334),
        border: Color(0xFF243041),
        textPrimary: Color(0xFFF9FAFB),
        textSecondary: Color(0xFF9CA3AF),
        shadow: Color(0x22000000),
      );
    }

    return const _ThemePalette(
      scaffold: AppColors.scaffold,
      surface: AppColors.surface,
      surfaceMuted: AppColors.surfaceMuted,
      border: AppColors.border,
      textPrimary: AppColors.textPrimary,
      textSecondary: AppColors.textSecondary,
      shadow: AppColors.shadow,
    );
  }
}

class _ThemePalette {
  const _ThemePalette({
    required this.scaffold,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.shadow,
  });

  final Color scaffold;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color shadow;
}
