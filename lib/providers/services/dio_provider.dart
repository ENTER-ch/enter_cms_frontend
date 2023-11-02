import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:universal_html/html.dart' as html;

part 'dio_provider.g.dart';

@riverpod
Dio dio(DioRef ref) {
  final log = Logger('DioProvider');

  String baseUrl = 'http://localhost:8000';
  // if (!kDebugMode && kIsWeb) {
  //   baseUrl = '${html.window.location.origin}/';
  // }
  log.info('Base URL: $baseUrl');

  final dio = Dio();
  dio.options.responseType = ResponseType.json;
  dio.options.baseUrl = baseUrl;

  return dio;
}
