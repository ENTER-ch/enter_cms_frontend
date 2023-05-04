import 'package:enter_cms_flutter/models/token.dart';
import 'package:enter_cms_flutter/models/user.dart';

abstract class AuthApi {
  Future<MToken> login({required String username, required String password});
  Future<MToken> refreshToken({required MToken token});
  Future<void> verifyToken({required MToken token});

  Future<void> configureToken({required MToken token});

  Future<MUser> getUser();
}

class ApiErrorUnauthorized implements Exception {
  final String message;

  ApiErrorUnauthorized(this.message);
}

class ApiErrorBadRequest implements Exception {
  final String message;

  ApiErrorBadRequest(this.message);
}