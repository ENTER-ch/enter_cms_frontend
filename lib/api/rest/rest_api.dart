import 'package:dio/dio.dart';

class EnterRestApi {
  static const String _baseUrl = '/api';

  final Dio dio;

  EnterRestApi({
    required this.dio,
  });

  void _mapDioError(DioError e) {
    if (e.response?.statusCode == 400) {
      throw ApiErrorBadRequest(data: e.response?.data);
    }
    else if (e.response?.statusCode == 401) {
      throw ApiErrorUnauthorized(data: e.response?.data);
    }
    else if (e.response?.statusCode == 403) {
      throw ApiErrorForbidden(data: e.response?.data);
    }
    else if (e.response?.statusCode == 500) {
      throw ApiErrorInternalServer(data: e.response?.data);
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await dio.get(_baseUrl + path);
    } on DioError catch (e) {
      _mapDioError(e);
      rethrow;
    }
  }

  Future<Response> post(String path, {Map<String, dynamic>? queryParameters, dynamic data, Options? options, void Function(int, int)? onSendProgress,   void Function(int, int)? onReceiveProgress,}) async {
    try {
      return await dio.post(_baseUrl + path, data: data, options: options, onSendProgress: onSendProgress, onReceiveProgress: onReceiveProgress);
    } on DioError catch (e) {
      _mapDioError(e);
      rethrow;
    }
  }

  Future<Response> put(String path, {Map<String, dynamic>? queryParameters, dynamic data}) async {
    try {
      return await dio.put(_baseUrl + path, data: data);
    } on DioError catch (e) {
      _mapDioError(e);
      rethrow;
    }
  }

  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await dio.delete(_baseUrl + path);
    } on DioError catch (e) {
      _mapDioError(e);
      rethrow;
    }
  }

  Future<Response> patch(String path, {Map<String, dynamic>? queryParameters, dynamic data}) async {
    try {
      return await dio.patch(_baseUrl + path, data: data);
    } on DioError catch (e) {
      _mapDioError(e);
      rethrow;
    }
  }
}

class ApiError implements Exception {
  final Exception? exception;
  final Map<String, dynamic>? data;

  ApiError({
    this.exception,
    this.data
  });
}

class ApiErrorBadRequest extends ApiError {
  ApiErrorBadRequest({Map<String, dynamic> data = const {'message': 'Bad Request'}}) : super(data: data);
}

class ApiErrorUnauthorized extends ApiError {
  ApiErrorUnauthorized({Map<String, dynamic> data = const {'message': 'Unauthorized'}}) : super(data: data);
}

class ApiErrorForbidden extends ApiError {
  ApiErrorForbidden({Map<String, dynamic> data = const {'message': 'Forbidden'}}) : super(data: data);
}

class ApiErrorInternalServer extends ApiError {
  ApiErrorInternalServer({Map<String, dynamic> data = const {'message': 'Internal Server Error'}}) : super(data: data);
}