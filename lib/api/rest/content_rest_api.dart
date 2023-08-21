import 'package:dio/dio.dart';
import 'package:enter_cms_flutter/api/auth_api.dart';
import 'package:enter_cms_flutter/api/content_api.dart';
import 'package:enter_cms_flutter/models/ag_content.dart';
import 'package:enter_cms_flutter/models/ag_touchpoint_config.dart';
import 'package:enter_cms_flutter/models/beacon.dart';
import 'package:enter_cms_flutter/models/mp_touchpoint_config.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';

class ContentRestApi extends ContentApi {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  final Dio dio;

  ContentRestApi({required this.dio});

  @override
  Future<List<MBeacon>> getBeacons() {
    throw UnimplementedError();
  }

  @override
  Future<List<MBeacon>> getBeaconsOfFloorplan({required int floorplanId}) {
    throw UnimplementedError();
  }

  @override
  Future<MBeacon> getBeacon({required String beaconId}) {
    throw UnimplementedError();
  }

  @override
  Future<MBeacon> createBeacon(MBeacon beacon) {
    throw UnimplementedError();
  }

  @override
  Future<MBeacon> updateBeacon(MBeacon beacon) {
    throw UnimplementedError();
  }

  @override
  Future<Function> deleteBeacon({required String beaconId}) {
    throw UnimplementedError();
  }

  @override
  Future<List<MTouchpoint>> getTouchpoints() async {
    try {
      final response = await dio.get(
        '$_baseUrl/cms/touchpoints/',
      );

      final touchpoints =
          (response.data as List).map((e) => MTouchpoint.fromJson(e)).toList();

      return touchpoints;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final message = e.response?.data['detail'] ?? 'Unauthorized';
        throw ApiErrorUnauthorized(message);
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['detail'] ?? 'Bad Request';
        throw ApiErrorBadRequest(message);
      } else if (e.response?.statusCode == 500) {
        final message = e.response?.data['detail'] ?? 'Internal Server Error';
        throw ApiErrorBadRequest(message);
      }
      rethrow;
    }
  }

  @override
  Future<List<MTouchpoint>> getTouchpointsOfFloorplan(
      {required int floorplanId}) async {
    try {
      final response = await dio.get(
        '$_baseUrl/cms/touchpoints/by-floorplan/$floorplanId/',
      );

      final touchpoints =
          (response.data as List).map((e) => MTouchpoint.fromJson(e)).toList();

      return touchpoints;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final message = e.response?.data['detail'] ?? 'Unauthorized';
        throw ApiErrorUnauthorized(message);
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['detail'] ?? 'Bad Request';
        throw ApiErrorBadRequest(message);
      } else if (e.response?.statusCode == 500) {
        final message = e.response?.data['detail'] ?? 'Internal Server Error';
        throw ApiErrorBadRequest(message);
      }
      rethrow;
    }
  }

  @override
  Future<MTouchpoint> getTouchpoint({required int id}) async {
    try {
      final response = await dio.get(
        '$_baseUrl/cms/touchpoints/$id/',
      );

      return MTouchpoint.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final message = e.response?.data['detail'] ?? 'Unauthorized';
        throw ApiErrorUnauthorized(message);
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['detail'] ?? 'Bad Request';
        throw ApiErrorBadRequest(message);
      } else if (e.response?.statusCode == 500) {
        final message = e.response?.data['detail'] ?? 'Internal Server Error';
        throw ApiErrorBadRequest(message);
      }
      rethrow;
    }
  }

  @override
  Future<MTouchpoint> createTouchpoint(MTouchpoint touchpoint) async {
    try {
      final response = await dio.post(
        '$_baseUrl/cms/touchpoints/',
        data: touchpoint.toJson(),
      );

      return MTouchpoint.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final message = e.response?.data['detail'] ?? 'Unauthorized';
        throw ApiErrorUnauthorized(message);
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['detail'] ?? 'Bad Request';
        throw ApiErrorBadRequest(message);
      } else if (e.response?.statusCode == 500) {
        final message = e.response?.data['detail'] ?? 'Internal Server Error';
        throw ApiErrorBadRequest(message);
      }
      rethrow;
    }
  }

  @override
  Future<MTouchpoint> updateTouchpoint(MTouchpoint touchpoint) async {
    try {
      final response = await dio.patch(
        '$_baseUrl/cms/touchpoints/${touchpoint.id}/',
        data: touchpoint.toJson(),
      );

      return MTouchpoint.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final message = e.response?.data['detail'] ?? 'Unauthorized';
        throw ApiErrorUnauthorized(message);
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['detail'] ?? 'Bad Request';
        throw ApiErrorBadRequest(message);
      } else if (e.response?.statusCode == 500) {
        final message = e.response?.data['detail'] ?? 'Internal Server Error';
        throw ApiErrorBadRequest(message);
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteTouchpoint({required int id}) async {
    try {
      await dio.delete(
        '$_baseUrl/cms/touchpoints/$id/',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final message = e.response?.data['detail'] ?? 'Unauthorized';
        throw ApiErrorUnauthorized(message);
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['detail'] ?? 'Bad Request';
        throw ApiErrorBadRequest(message);
      } else if (e.response?.statusCode == 500) {
        final message = e.response?.data['detail'] ?? 'Internal Server Error';
        throw ApiErrorBadRequest(message);
      }
      rethrow;
    }
  }

  @override
  Future<MAGTouchpointConfig> getAGTouchpointConfig({required int id}) {
    throw UnimplementedError();
  }

  @override
  Future<MAGTouchpointConfig> getAGTouchpointConfigForTouchpoint(
      {required int touchpointId}) {
    throw UnimplementedError();
  }

  @override
  Future<MAGTouchpointConfig> createAGTouchpointConfig(
      MAGTouchpointConfig config) {
    throw UnimplementedError();
  }

  @override
  Future<MAGTouchpointConfig> updateAGTouchpointConfig(
      MAGTouchpointConfig config) {
    throw UnimplementedError();
  }

  @override
  Future<Function> deleteAGTouchpointConfig({required int id}) {
    throw UnimplementedError();
  }

  @override
  Future<MMPTouchpointConfig> getMPTouchpointConfig({required int id}) {
    throw UnimplementedError();
  }

  @override
  Future<MMPTouchpointConfig> getMPTouchpointConfigForTouchpoint(
      {required int touchpointId}) {
    throw UnimplementedError();
  }

  @override
  Future<MMPTouchpointConfig> createMPTouchpointConfig(
      MMPTouchpointConfig config) {
    throw UnimplementedError();
  }

  @override
  Future<MMPTouchpointConfig> updateMPTouchpointConfig(
      MMPTouchpointConfig config) {
    throw UnimplementedError();
  }

  @override
  Future<Function> deleteMPTouchpointConfig({required int id}) {
    throw UnimplementedError();
  }

  @override
  Future<MAGContent> getAGContent({required int id}) {
    throw UnimplementedError();
  }

  @override
  Future<MAGContent> createAGContent(MAGContent content,
      {required int touchpointId}) {
    throw UnimplementedError();
  }

  @override
  Future<MAGContent> updateAGContent(MAGContent content) {
    throw UnimplementedError();
  }

  @override
  Future<Function> deleteAGContent({required int id}) {
    throw UnimplementedError();
  }
}
