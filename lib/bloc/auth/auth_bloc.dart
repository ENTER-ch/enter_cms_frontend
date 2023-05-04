import 'package:bloc/bloc.dart';
import 'package:enter_cms_flutter/api/auth_api.dart';
import 'package:enter_cms_flutter/models/token.dart';
import 'package:enter_cms_flutter/models/user.dart';
import 'package:enter_cms_flutter/services/local_preferences.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final log = Logger('AuthBloc');
  final LocalPreferencesService prefsService;
  final AuthApi authApi;

  AuthBloc({
    required this.prefsService,
    required this.authApi,
  }) : super(AuthInitial()) {
    on<AuthInit>((event, emit) async {
      final token = prefsService.token;
      if (token != null) {
        try {
          log.info("Refreshing Token $token");
          final refreshedToken = await authApi.refreshToken(token: token);
          prefsService.token = refreshedToken;
          await authApi.configureToken(token: refreshedToken);
          emit(AuthSuccess(token: refreshedToken));
          add(const AuthRefreshUser());
        } on ApiErrorUnauthorized catch (e) {
          log.warning("Token refresh failed: $e");
          prefsService.token = null;
          emit(AuthUnauthenticated());
        } on ApiErrorBadRequest catch (e) {
          log.warning("Token refresh failed: $e");
          prefsService.token = null;
          emit(AuthUnauthenticated());
        } catch (e) {
          log.warning("Token refresh failed: $e");
          emit(AuthError(message: e.toString()));
        }
      } else {
        emit(AuthUnauthenticated());
      }
    });

    on<AuthLogin>((event, emit) async {
      emit(AuthLoading());
      try {
        final token = await authApi.login(
          username: event.username,
          password: event.password,
        );
        prefsService.token = token;
        await authApi.configureToken(token: token);
        emit(AuthSuccess(token: token));
        add(const AuthRefreshUser());
      } on ApiErrorUnauthorized catch (e) {
        emit(AuthError(message: e.message));
      } on ApiErrorBadRequest catch (e) {
        emit(AuthError(message: e.message));
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }
    });

    on<AuthRefreshUser>((event, emit) async {
      if (state is AuthSuccess) {
        try {
          final user = await authApi.getUser();
          emit((state as AuthSuccess).copyWith(user: user));
        } catch (e) {
          log.warning("Error refreshing user: $e");
        }
      } else {
        log.warning("Cannot refresh user when not authenticated");
      }
    });

    on<AuthLogout>((event, emit) async {
      prefsService.token = null;
      emit(AuthUnauthenticated());
    });
  }
}
