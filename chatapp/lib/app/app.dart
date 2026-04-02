import 'package:flutter/material.dart';

import 'package:chatapp/app/app_session_gate.dart';
import 'package:chatapp/app/auth_scope.dart';
import 'package:chatapp/app/routes/app_router.dart';
import 'package:chatapp/app/settings_scope.dart';
import 'package:chatapp/core/theme/app_theme.dart';
import 'package:chatapp/features/auth/data/auth_repository.dart';
import 'package:chatapp/features/auth/data/session_storage.dart';
import 'package:chatapp/features/auth/presentation/controllers/auth_controller.dart';
import 'package:chatapp/features/settings/data/settings_storage.dart';
import 'package:chatapp/features/settings/presentation/controllers/app_settings_controller.dart';

class ChatApp extends StatefulWidget {
  const ChatApp({super.key});

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  late final AuthController _authController;
  late final AppSettingsController _settingsController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(
      repository: const AuthRepository(),
      sessionStorage: const SessionStorage(),
    )..bootstrap();
    _settingsController = AppSettingsController(
      storage: const SettingsStorage(),
    )..bootstrap();
  }

  @override
  void dispose() {
    _authController.dispose();
    _settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      controller: _authController,
      child: SettingsScope(
        controller: _settingsController,
        child: ValueListenableBuilder(
          valueListenable: _settingsController,
          builder: (context, settings, _) {
            return MaterialApp(
              title: 'VibeChat',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.build(
                settings: settings,
                brightness: Brightness.light,
              ),
              darkTheme: AppTheme.build(
                settings: settings,
                brightness: Brightness.dark,
              ),
              themeMode: settings.themeMode,
              onGenerateRoute: AppRouter.onGenerateRoute,
              home: const AppSessionGate(),
            );
          },
        ),
      ),
    );
  }
}
