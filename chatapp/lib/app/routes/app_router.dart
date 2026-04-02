import 'package:flutter/material.dart';

import 'package:chatapp/app/auth_scope.dart';
import 'package:chatapp/app/routes/app_routes.dart';
import 'package:chatapp/features/auth/presentation/screens/login_screen.dart';
import 'package:chatapp/features/auth/presentation/screens/signup_screen.dart';
import 'package:chatapp/features/chat/presentation/models/chat_screen_args.dart';
import 'package:chatapp/features/chat/presentation/screens/chat_screen.dart';
import 'package:chatapp/features/home/presentation/models/home_tab.dart';
import 'package:chatapp/features/home/presentation/screens/home_screen.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return _page(const LoginScreen(), settings);
      case AppRoutes.signup:
        return _page(const SignupScreen(), settings);
      case AppRoutes.home:
        return _page(const HomeScreen(), settings);
      case AppRoutes.inbox:
        return _page(const HomeScreen(initialTab: HomeTab.inbox), settings);
      case AppRoutes.chat:
        final args = settings.arguments;
        return MaterialPageRoute<void>(
          builder: (context) => ChatScreen(
            session: AuthScope.of(context).value.session,
            args: args is ChatScreenArgs ? args : null,
          ),
          settings: settings,
        );
      case AppRoutes.calls:
        return _page(const HomeScreen(initialTab: HomeTab.calls), settings);
      case AppRoutes.profile:
        return _page(const HomeScreen(initialTab: HomeTab.profile), settings);
      case AppRoutes.settings:
        return _page(const HomeScreen(initialTab: HomeTab.settings), settings);
      default:
        return _page(const HomeScreen(), settings);
    }
  }

  static MaterialPageRoute<void> _page(Widget child, RouteSettings settings) {
    return MaterialPageRoute<void>(builder: (_) => child, settings: settings);
  }
}
