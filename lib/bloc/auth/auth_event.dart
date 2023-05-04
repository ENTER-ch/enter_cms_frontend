part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class AuthInit extends AuthEvent {
  const AuthInit();

  @override
  List<Object> get props => [];
}

class AuthLogin extends AuthEvent {
  final String username;
  final String password;

  const AuthLogin({
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [username, password];
}

class AuthLogout extends AuthEvent {
  const AuthLogout();

  @override
  List<Object> get props => [];
}

class AuthRefreshUser extends AuthEvent {
  const AuthRefreshUser();

  @override
  List<Object> get props => [];
}