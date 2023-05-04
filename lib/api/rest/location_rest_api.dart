import 'package:dio/dio.dart';
import 'package:enter_cms_flutter/api/auth_api.dart';
import 'package:enter_cms_flutter/api/location_api.dart';
import 'package:enter_cms_flutter/models/floorplan.dart';

class LocationRestApi extends LocationApi {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  final Dio dio;

  LocationRestApi({required this.dio});


  @override
  Future<List<MFloorplan>> getFloorplans() async {
    try {
      final response = await dio.get(
        '$_baseUrl/cms/floorplans/',
      );

      final floorplans = (response.data as List)
          .map((e) => MFloorplan.fromJson(e))
          .toList();

      return floorplans;
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        final message = e.response?.data['detail'] ?? 'Unauthorized';
        throw ApiErrorUnauthorized(message);
      }
      else if (e.response?.statusCode == 400) {
        final message = e.response?.data['detail'] ?? 'Bad Request';
        throw ApiErrorBadRequest(message);
      }
      else if (e.response?.statusCode == 500) {
        final message = e.response?.data['detail'] ?? 'Internal Server Error';
        throw ApiErrorBadRequest(message);
      }
      rethrow;
    }
  }

  @override
  Future<MFloorplan> getFloorplan(int id) async {
    try {
      final response = await dio.get(
        '$_baseUrl/cms/floorplans /$id/',
      );

      return MFloorplan.fromJson(response.data);
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        final message = e.response?.data['detail'] ?? 'Unauthorized';
        throw ApiErrorUnauthorized(message);
      }
      else if (e.response?.statusCode == 400) {
        final message = e.response?.data['detail'] ?? 'Bad Request';
        throw ApiErrorBadRequest(message);
      }
      else if (e.response?.statusCode == 500) {
        final message = e.response?.data['detail'] ?? 'Internal Server Error';
        throw ApiErrorBadRequest(message);
      }
      rethrow;
    }
  }
}