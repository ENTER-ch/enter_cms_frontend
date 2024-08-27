import 'package:cross_file/cross_file.dart';
import 'package:enter_cms_flutter/models/ag_content.dart';
import 'package:enter_cms_flutter/models/ag_touchpoint_config.dart';
import 'package:enter_cms_flutter/models/beacon.dart';
import 'package:enter_cms_flutter/models/floorplan.dart';
import 'package:enter_cms_flutter/models/floorplan_view.dart';
import 'package:enter_cms_flutter/models/media_language.dart';
import 'package:enter_cms_flutter/models/media_track.dart';
import 'package:enter_cms_flutter/models/mp_touchpoint_config.dart';
import 'package:enter_cms_flutter/models/position.dart';
import 'package:enter_cms_flutter/models/release.dart';
import 'package:enter_cms_flutter/models/release_preview.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';

abstract class CmsApi {
  /// Floorplans
  Future<MFloorplan> uploadFloorplan(XFile image,
      {Function(int, int)? onProgress});
  Future<List<MFloorplan>> getFloorplans();
  Future<MFloorplan> getFloorplan(int id);
  Future<void> deleteFloorplan(int id);
  Future<MFloorplan> updateFloorplan(MFloorplan floorplan);
  Future<MFloorplanView> getFloorplanView(int id);

  /// Touchpoints
  Future<MTouchpoint> getTouchpoint(int id);
  Future<MTouchpoint> updateTouchpoint(
    int id, {
    int? touchpointId,
    MPosition? position,
    String? internalTitle,
    TouchpointStatus? status,
  });
  Future<void> deleteTouchpoint(int id);
  Future<MTouchpoint> createTouchpoint(TouchpointType type,
      {MPosition? position});

  Future<MAGTouchpointConfig> getAGTouchpointConfig(int id);
  Future<MAGTouchpointConfig> updateAGTouchpointConfig(
    int id, {
    AGPlaybackMode? playbackMode,
  });
  Future<MTouchpoint> updateMPTouchpointConfig(
      MMPTouchpointConfig config); // TODO

  /// Content
  Future<MAGContent> getAGContent(int id);
  Future<MAGContent> createAGContent(
    int agTouchpointId, {
    String? label,
    String? language,
    int? mediaTrackId,
  });
  Future<MAGContent> updateAGContent(
    int id, {
    String? label,
    String? language,
    int? mediaTrackId,
    bool clearMediaTrackId = false,
  });
  Future<void> deleteAGContent(int id);

  /// Media
  Future<List<MMediaTrack>> uploadMediaFile(XFile file,
      {Function(int, int)? onProgress});
  Future<MMediaTrack> getMediaTrack(int id);

  /// Releases
  Future<MReleasePreview> getReleasePreview();
  Future<MRelease> getRelease(int id);
  Future<MRelease> getCurrentRelease();
  Future<MRelease> createRelease({
    required String title,
  });

  /// Beacons
  Future<List<MBeacon>> getBeacons();
  Future<MBeacon> getBeacon(int id);
  Future<MBeacon> createBeacon({
    required int touchpointId,
    String? beaconId,
    MPosition? position,
    double? radius,
  });
  Future<MBeacon> updateBeacon(
    int id, {
    String? beaconId,
    MPosition? position,
    MTouchpoint? touchpoint,
    double? radius,
  });
  Future<void> deleteBeacon(int id);

  /// Languages
  Future<List<MMediaLanguage>> getMediaLanguages();
}
