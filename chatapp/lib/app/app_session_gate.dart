import 'package:flutter/material.dart';

import 'package:chatapp/app/auth_scope.dart';
import 'package:chatapp/core/design/app_colors.dart';
import 'package:chatapp/core/design/app_spacing.dart';
import 'package:chatapp/features/auth/presentation/controllers/auth_controller.dart';
import 'package:chatapp/features/auth/presentation/screens/login_screen.dart';
import 'package:chatapp/features/home/presentation/screens/home_screen.dart';

class AppSessionGate extends StatelessWidget {
  const AppSessionGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = AuthScope.of(context);
    final state = authController.value;

    if (state.status == AuthStatus.initializing) {
      return const _LaunchScreen();
    }

    if (state.isAuthenticated) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}

class _LaunchScreen extends StatelessWidget {
  const _LaunchScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Checking your session', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text('Loading VibeChat...', style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.xl),
            const CircularProgressIndicator(color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}
