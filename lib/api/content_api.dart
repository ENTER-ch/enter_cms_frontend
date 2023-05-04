import 'package:enter_cms_flutter/models/ag_content.dart';
import 'package:enter_cms_flutter/models/ag_touchpoint_config.dart';
import 'package:enter_cms_flutter/models/beacon.dart';
import 'package:enter_cms_flutter/models/mp_touchpoint_config.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';

abstract class ContentApi {
  Future<List<MBeacon>> getBeacons();
  Future<List<MBeacon>> getBeaconsOfFloorplan({required int floorplanId});
  Future<MBeacon> getBeacon({required String beaconId});
  Future<MBeacon> createBeacon(MBeacon beacon);
  Future<MBeacon> updateBeacon(MBeacon beacon);
  Future<void> deleteBeacon({required String beaconId});

  Future<List<MTouchpoint>> getTouchpoints();
  Future<List<MTouchpoint>> getTouchpointsOfFloorplan({required int floorplanId});
  Future<MTouchpoint> getTouchpoint({required int id});
  Future<MTouchpoint> createTouchpoint(MTouchpoint touchpoint);
  Future<MTouchpoint> updateTouchpoint(MTouchpoint touchpoint);
  Future<void> deleteTouchpoint({required int id});

  Future<MAGTouchpointConfig> getAGTouchpointConfig({required int id});
  Future<MAGTouchpointConfig> getAGTouchpointConfigForTouchpoint({required int touchpointId});
  Future<MAGTouchpointConfig> createAGTouchpointConfig(MAGTouchpointConfig config);
  Future<MAGTouchpointConfig> updateAGTouchpointConfig(MAGTouchpointConfig config);
  Future<void> deleteAGTouchpointConfig({required int id});

  Future<MMPTouchpointConfig> getMPTouchpointConfig({required int id});
  Future<MMPTouchpointConfig> getMPTouchpointConfigForTouchpoint({required int touchpointId});
  Future<MMPTouchpointConfig> createMPTouchpointConfig(MMPTouchpointConfig config);
  Future<MMPTouchpointConfig> updateMPTouchpointConfig(MMPTouchpointConfig config);
  Future<void> deleteMPTouchpointConfig({required int id});

  Future<MAGContent> getAGContent({required int id});
  Future<MAGContent> createAGContent(MAGContent content, {required int touchpointId});
  Future<MAGContent> updateAGContent(MAGContent content);
  Future<void> deleteAGContent({required int id});
}