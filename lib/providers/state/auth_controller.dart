import 'dart:convert';

import 'package:enter_cms_flutter/api/auth_api.dart';
import 'package:enter_cms_flutter/api/rest/auth_rest_api.dart';
import 'package:enter_cms_flutter/api/rest/rest_api.dart';
import 'package:enter_cms_flutter/models/token.dart';
import 'package:enter_cms_flutter/models/user.dart';
import 'package:enter_cms_flutter/providers/services/dio_provider.dart';
import 'package:enter_cms_flutter/providers/services/shared_preferences_provider.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.freezed.dart';

part 'auth_controller.g.dart';

/// Simple provider for the Auth API.
@riverpod
AuthApi authApi(AuthApiRef ref) {
  final dio = ref.watch(dioProvider);
  return AuthRestApi(dio: dio);
}

/// AuthState holds the current authentication state.
@freezed
class AuthState with _$AuthState {
  const factory AuthState.signedIn({
    required MUser user,
    required MToken token,
  }) = AuthSignedIn;

  const factory AuthState.signedOut() = AuthSignedOut;
}

/// AsyncNotifier that holds and handles authentication state and logic.
/// On init, it will attempt to recover and refresh a previous login from a stored token.
@riverpod
class AuthController extends _$AuthController {
  final _log = Logger('AuthController');
  static const _tokenPrefsKey = 'token';

  @override
  FutureOr<AuthState> build() async {
    _listenAndStoreToken();
    return _attemptRecoverLogin();
  }

  Future<AuthState> _attemptRecoverLogin() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final tokenJson = prefs.getString(_tokenPrefsKey);
    if (tokenJson == null) {
      return const AuthState.signedOut();
    }

    try {
      final token = MToken.fromJson(jsonDecode(tokenJson));
      final authApi = ref.read(authApiProvider);
      final refreshedToken = await authApi.refreshToken(token: token);
      authApi.configureToken(token: refreshedToken);
      final user = await authApi.getUser();

      return AuthState.signedIn(
        user: user,
        token: refreshedToken,
      );
    } on Exception catch (e) {
      _log.warning('Failed to recover login', e);
      return const AuthState.signedOut();
    }
  }

  Future<void> logout() async {
    state = const AsyncValue<AuthState>.data(AuthState.signedOut());
  }

  Future<void> loginWithUsernameAndPassword({
    required String username,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<AuthState>(() async {
      final authApi = ref.read(authApiProvider);
      final token = await authApi.login(username: username, password: password);
      authApi.configureToken(token: token);
      final user = await authApi.getUser();

      return AuthState.signedIn(
        user: user,
        token: token,
      );
    });
  }

  /// Listen to auth state changes and update the persisted token in shared preferences.
  /// If the Service is in a loading state, do nothing.
  /// If the Service is in an error state, remove the token from shared preferences.
  /// If the Service is in a signed in state, store the token in shared preferences.
  /// If the Service is in a signed out state, remove the token from shared preferences.
  void _listenAndStoreToken() {
    final prefs = ref.read(sharedPreferencesProvider);
    ref.listenSelf((previous, next) {
      if (next.isLoading) return;
      if (next.hasError) {
        prefs.remove(_tokenPrefsKey);
        return;
      }

      next.requireValue.map<void>(
        signedIn: (state) {
          prefs.setString(_tokenPrefsKey, jsonEncode(state.token.toJson()));
        },
        signedOut: (_) {
          prefs.remove(_tokenPrefsKey);
        },
      );
    });
  }
}

/// Returns the current authentication state.
@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  return ref.watch(authControllerProvider).maybeWhen(
        data: (state) => state.maybeWhen(
          signedIn: (user, token) => true,
          orElse: () => false,
        ),
        orElse: () => false,
      );
}

/// Formats an auth error message.
@riverpod
String authErrorMessage(AuthErrorMessageRef ref) {
  return ref.watch(authControllerProvider).maybeWhen(
        error: (error, stackTrace) {
          if (error is ApiError) {
            return error.data?['detail'] ?? error.toString();
          }
          return error.toString();
        },
        orElse: () => '',
      );
}