part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthUnauthenticated extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthLoading extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthSuccess extends AuthState {
  final MToken token;
  final MUser? user;

  const AuthSuccess({
    required this.token,
    this.user,
  });

  AuthSuccess copyWith({
    MToken? token,
    MUser? user,
  }) {
    return AuthSuccess(
      token: token ?? this.token,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [token, user];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}
