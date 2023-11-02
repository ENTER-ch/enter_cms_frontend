import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';
import 'package:enter_cms_flutter/api/cms_api.dart';
import 'package:enter_cms_flutter/api/rest/rest_api.dart';
import 'package:enter_cms_flutter/models/ag_content.dart';
import 'package:enter_cms_flutter/models/ag_touchpoint_config.dart';
import 'package:enter_cms_flutter/models/beacon.dart';
import 'package:enter_cms_flutter/models/floorplan.dart';
import 'package:enter_cms_flutter/models/floorplan_view.dart';
import 'package:enter_cms_flutter/models/media_track.dart';
import 'package:enter_cms_flutter/models/mp_touchpoint_config.dart';
import 'package:enter_cms_flutter/models/position.dart';
import 'package:enter_cms_flutter/models/release.dart';
import 'package:enter_cms_flutter/models/release_preview.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:mime/mime.dart';

class CmsRestApi extends EnterRestApi implements CmsApi {
  CmsRestApi({required super.dio});

  @override
  Future<MFloorplan> uploadFloorplan(XFile image,
      {Function(int, int)? onProgress}) {
    throw UnimplementedError();
  }

  @override
  Future<List<MFloorplan>> getFloorplans() async {
    final response = await get('/cms/floorplans/');
    return (response.data as List)
        .map((e) => MFloorplan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MFloorplan> getFloorplan(int id) async {
    final response = await get('/cms/floorplans/$id/');
    return MFloorplan.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteFloorplan(int id) async {
    await delete('/cms/floorplans/$id/');
  }

  @override
  Future<MFloorplan> updateFloorplan(MFloorplan floorplan) async {
    final response = await patch(
      '/cms/floorplans/${floorplan.id}/',
      data: floorplan.toJson(),
    );
    return MFloorplan.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MFloorplanView> getFloorplanView(int id) async {
    final response = await get('/cms/floorplans/$id/view/');
    return MFloorplanView.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MTouchpoint> getTouchpoint(int id) async {
    final response = await get('/cms/touchpoints/$id/');
    return MTouchpoint.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MTouchpoint> updateTouchpoint(
    int id, {
    int? touchpointId,
    MPosition? position,
    String? internalTitle,
    TouchpointStatus? status,
  }) async {
    final response = await patch(
      '/cms/touchpoints/$id/',
      data: {
        if (touchpointId != null) 'touchpoint_id': touchpointId,
        if (position != null) 'position': position.toJson(),
        if (internalTitle != null) 'internal_title': internalTitle,
        if (status != null) 'status': status.name,
      },
    );
    return MTouchpoint.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteTouchpoint(int id) async {
    await delete('/cms/touchpoints/$id/');
  }

  @override
  Future<MTouchpoint> createTouchpoint(TouchpointType type,
      {MPosition? position}) async {
    final response = await post('/cms/touchpoints/', data: {
      'type': type.name,
      if (position != null) 'position': position.toJson(),
    });
    return MTouchpoint.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MAGTouchpointConfig> getAGTouchpointConfig(int id) async {
    final response = await get('/cms/touchpoints/ag/$id/');
    return MAGTouchpointConfig.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MAGTouchpointConfig> updateAGTouchpointConfig(
    int id, {
    AGPlaybackMode? playbackMode,
  }) async {
    final response = await patch(
      '/cms/touchpoints/ag/$id/',
      data: {
        if (playbackMode != null) 'playback_mode': playbackMode.jsonValue,
      },
    );
    return MAGTouchpointConfig.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MTouchpoint> updateMPTouchpointConfig(MMPTouchpointConfig config) {
    throw UnimplementedError();
  }

  @override
  Future<MAGContent> getAGContent(int id) async {
    final response = await get('/cms/content/ag/$id/');
    return MAGContent.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MAGContent> createAGContent(
    int agTouchpointId, {
    String? label,
    String? language,
    int? mediaTrackId,
  }) async {
    final response = await post(
      '/cms/content/ag/',
      data: {
        'config': agTouchpointId,
        if (label != null) 'label': label,
        if (language != null) 'language': language,
        if (mediaTrackId != null) 'media_track': mediaTrackId,
      },
    );
    return MAGContent.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MAGContent> updateAGContent(
    int id, {
    String? label,
    String? language,
    int? mediaTrackId,
    bool clearMediaTrackId = false,
  }) async {
    final response = await patch(
      '/cms/content/ag/$id/',
      data: {
        if (label != null) 'label': label,
        if (language != null) 'language': language,
        if (mediaTrackId != null) 'media_track': mediaTrackId,
        if (clearMediaTrackId) 'media_track': null,
      },
    );
    return MAGContent.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteAGContent(int id) async {
    await delete('/cms/content/ag/$id/');
  }

  @override
  Future<List<MMediaTrack>> uploadMediaFile(XFile file,
      {Function(int, int)? onProgress}) async {
    final String? mimeType = lookupMimeType(file.path);
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(await file.readAsBytes(),
          filename: file.name,
          contentType: http_parser.MediaType.parse(mimeType!)),
    });

    final response = await post(
      '/media/upload/',
      options: Options(
        contentType: 'multipart/form-data',
      ),
      data: formData,
      onSendProgress: onProgress,
    );

    return (response.data as List)
        .map((e) => MMediaTrack.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MMediaTrack> getMediaTrack(int id) async {
    final response = await get('/media/tracks/$id/');
    return MMediaTrack.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MRelease> createRelease({
    required String title,
  }) async {
    final response = await post(
      '/cms/releases/',
      data: {
        'title': title,
      },
    );
    return MRelease.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MRelease> getCurrentRelease() async {
    final response = await get(
      '/cms/releases/current/',
    );
    return MRelease.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MReleasePreview> getReleasePreview() async {
    final response = await get('/cms/releases/preview/');
    return MReleasePreview.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MRelease> getRelease(int id) async {
    final response = await get('/cms/releases/$id/');
    return MRelease.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MBeacon> createBeacon(
      {required int touchpointId,
      String? beaconId,
      MPosition? position,
      double? radius}) async {
    final response = await post(
      '/cms/beacons/',
      data: {
        'touchpoint': touchpointId,
        'beacon_id': beaconId,
        'position': position?.toJson(),
        'radius': radius ?? 200,
      },
    );
    return MBeacon.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteBeacon(int id) async {
    await delete('/cms/beacons/$id/');
  }

  @override
  Future<MBeacon> getBeacon(int id) async {
    final response = await get('/cms/beacons/$id/');
    return MBeacon.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MBeacon> updateBeacon(int id,
      {String? beaconId,
      MPosition? position,
      MTouchpoint? touchpoint,
      double? radius}) async {
    final response = await put(
      '/cms/beacons/$id/',
      data: {
        'beacon_id': beaconId,
        'position': position?.toJson(),
        'touchpoint': touchpoint?.toJson(),
        'radius': radius,
      },
    );
    return MBeacon.fromJson(response.data as Map<String, dynamic>);
  }
}
