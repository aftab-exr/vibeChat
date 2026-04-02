import 'package:flutter/foundation.dart';

import 'package:chatapp/features/auth/data/auth_repository.dart';
import 'package:chatapp/features/auth/data/session_storage.dart';
import 'package:chatapp/features/auth/domain/models/auth_session.dart';

enum AuthStatus { initializing, unauthenticated, authenticating, authenticated }

class AuthState {
  const AuthState({required this.status, this.session, this.errorMessage});

  const AuthState.initial()
    : status = AuthStatus.initializing,
      session = null,
      errorMessage = null;

  final AuthStatus status;
  final AuthSession? session;
  final String? errorMessage;

  bool get isAuthenticated => session != null;
  bool get isBusy =>
      status == AuthStatus.initializing || status == AuthStatus.authenticating;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    bool clearSession = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: clearSession ? null : (session ?? this.session),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthController extends ValueNotifier<AuthState> {
  AuthController({
    required AuthRepository repository,
    required SessionStorage sessionStorage,
  }) : _repository = repository,
       _sessionStorage = sessionStorage,
       super(const AuthState.initial());

  final AuthRepository _repository;
  final SessionStorage _sessionStorage;

  Future<void> bootstrap() async {
    value = value.copyWith(status: AuthStatus.initializing, clearError: true);

    final session = await _sessionStorage.readSession();
    if (session == null || session.token.isEmpty) {
      value = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    value = AuthState(status: AuthStatus.authenticated, session: session);
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    return _authenticate(() {
      return _repository.login(username: username, password: password);
    });
  }

  Future<bool> register({
    required String username,
    required String password,
  }) async {
    return _authenticate(() async {
      await _repository.register(username: username, password: password);

      return _repository.login(username: username, password: password);
    });
  }

  Future<void> logout() async {
    await _sessionStorage.clearSession();
    value = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    if (value.errorMessage == null) {
      return;
    }

    value = value.copyWith(clearError: true);
  }

  Future<bool> _authenticate(
    Future<AuthSession> Function() resolveSession,
  ) async {
    value = value.copyWith(status: AuthStatus.authenticating, clearError: true);

    try {
      final session = await resolveSession();
      await _sessionStorage.saveSession(session);
      value = AuthState(status: AuthStatus.authenticated, session: session);
      return true;
    } on AuthException catch (error) {
      value = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: error.message,
      );
      return false;
    } catch (e) {
      value = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage:
            'Error: ${e.toString()}', // <-- This will show on your phone screen!
      );
      return false;
    }
  }
}
