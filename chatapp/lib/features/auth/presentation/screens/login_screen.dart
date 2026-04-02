import 'package:flutter/material.dart';

import 'package:chatapp/app/auth_scope.dart';
import 'package:chatapp/app/routes/app_routes.dart';
import 'package:chatapp/core/design/app_colors.dart';
import 'package:chatapp/core/design/app_spacing.dart';
import 'package:chatapp/features/auth/presentation/widgets/auth_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final authController = AuthScope.of(context);
    final success = await authController.login(
      username: _usernameController.text,
      password: _passwordController.text,
    );

    if (!mounted || !success) {
      return;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = AuthScope.of(context);
    final state = authController.value;

    return AuthShell(
      title: 'Welcome back',
      subtitle:
          'Sign in with your existing username and password to continue into your chats.',
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Need an account?', style: theme.textTheme.bodyMedium),
          TextButton(
            onPressed: state.isBusy
                ? null
                : () {
                    authController.clearError();
                    Navigator.of(context).pushNamed(AppRoutes.signup);
                  },
            child: const Text('Create one'),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _usernameController,
              enabled: !state.isBusy,
              textInputAction: TextInputAction.next,
              onChanged: (_) => authController.clearError(),
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'Enter your username',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Username is required';
                }

                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _passwordController,
              enabled: !state.isBusy,
              obscureText: _obscurePassword,
              onChanged: (_) => authController.clearError(),
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }

                return null;
              },
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  state.errorMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: state.isBusy ? null : _submit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: state.isBusy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        )
                      : const Text('Sign In'),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'New users can create an account in a few seconds.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
