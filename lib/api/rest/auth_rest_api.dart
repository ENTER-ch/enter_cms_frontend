import 'package:enter_cms_flutter/api/auth_api.dart';
import 'package:enter_cms_flutter/api/rest/rest_api.dart';
import 'package:enter_cms_flutter/models/token.dart';
import 'package:enter_cms_flutter/models/user.dart';

class AuthRestApi extends EnterRestApi implements AuthApi {
  AuthRestApi({required super.dio});

  @override
  Future<void> configureToken({required MToken token}) async {
    dio.options.headers['Authorization'] = 'Bearer ${token.access}';
  }

  @override
  Future<void> verifyToken({required MToken token}) async {
    await post(
      '/token/verify/',
      data: {
        'token': token.access,
      },
    );
  }

  @override
  Future<MToken> refreshToken({required MToken token}) async {
    final response = await post(
      '/token/refresh/',
      data: {
        'refresh': token.refresh,
      },
    );

    final refreshToken = MToken.fromJson(response.data);
    return token.copyWith(
      access: refreshToken.access,
    );
  }

  @override
  Future<MToken> login(
      {required String username, required String password}) async {
    final response = await post(
      '/token/',
      data: {
        'username': username,
        'password': password,
      },
    );
    return MToken.fromJson(response.data);
  }

  @override
  Future<MUser> getUser() async {
    final response = await get('/users/me/');
    return MUser.fromJson(response.data);
  }
}
