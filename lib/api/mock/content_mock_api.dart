import 'dart:math';

import 'package:enter_cms_flutter/api/content_api.dart';
import 'package:enter_cms_flutter/models/ag_content.dart';
import 'package:enter_cms_flutter/models/ag_touchpoint_config.dart';
import 'package:enter_cms_flutter/models/beacon.dart';
import 'package:enter_cms_flutter/models/mp_content.dart';
import 'package:enter_cms_flutter/models/mp_touchpoint_config.dart';
import 'package:enter_cms_flutter/models/position.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';

class ContentMockApi extends ContentApi {
  static const _lagDuration = Duration(milliseconds: 250);
  final _logger = Logger('ContentMockApi');

  List<MTouchpoint> _touchpoints = [
    const MTouchpoint(
      id: 1,
      touchpointId: 1,
      type: TouchpointType.audioguide,
      internalTitle: 'AG Touchpoint 1 (1)',
      position: MPosition(
        parentId: 2,
        x: 2875,
        y: 1890,
      ),
    ),
    const MTouchpoint(
      id: 2,
      touchpointId: 2,
      type: TouchpointType.audioguide,
      internalTitle: 'AG Touchpoint 2 (2)',
      position: MPosition(
        parentId: 2,
        x: 2552,
        y: 2485,
      ),
    ),
    const MTouchpoint(
      id: 3,
      touchpointId: 3,
      type: TouchpointType.mediaplayer,
      internalTitle: 'MP Touchpoint 1 (3)',
      position: MPosition(
        parentId: 2,
        x: 4164,
        y: 3470,
      ),
    ),
    const MTouchpoint(
      id: 4,
      touchpointId: 4,
      type: TouchpointType.mediaplayer,
      internalTitle: 'MP Touchpoint 2 (4)',
      position: MPosition(
        parentId: 2,
        x: 2419,
        y: 3925,
      ),
    ),
  ];

  List<MAGTouchpointConfig> _agTouchpointConfigs = [
    const MAGTouchpointConfig(
      id: 0,
      touchpointId: 1,
      contents: [
        MAGContent(
          id: 1,
          label: 'AG Content 1',
          language: 'de',
          mediaTrackId: 1,
        ),
        MAGContent(
          id: 2,
          label: 'AG Content 2',
          language: 'en',
        ),
      ],
    ),
    const MAGTouchpointConfig(
      id: 1,
      touchpointId: 2,
      contents: [
        MAGContent(
          id: 3,
          label: 'AG Content 3',
          language: 'de',
        ),
        MAGContent(
          id: 4,
          label: 'AG Content 4',
          language: 'en',
        ),
      ],
    ),
  ];

  List<MMPTouchpointConfig> _mpTouchpointConfigs = [
    const MMPTouchpointConfig(
      id: 1,
      touchpointId: 3,
      contents: [
        MMPContent(
          id: 1,
          label: 'MP Content 1',
          language: 'de',
        ),
        MMPContent(
          id: 2,
          label: 'MP Content 2',
          language: 'en',
        ),
      ],
    ),
    const MMPTouchpointConfig(
      id: 2,
      touchpointId: 4,
      contents: [
        MMPContent(
          id: 3,
          label: 'MP Content 3',
          language: 'de',
        ),
        MMPContent(
          id: 4,
          label: 'MP Content 4',
          language: 'en',
        ),
      ],
    ),
  ];

  late List<MBeacon> _beacons;

  ContentMockApi() {
    _beacons = _touchpoints
        .where((t) => t.position != null)
        .map((t) => MBeacon(
            beaconId: t.id.toString(),
            touchpointId: t.id,
            position: t.position!))
        .toList();
  }

  @override
  Future<List<MTouchpoint>> getTouchpoints() {
    return Future.delayed(
      _lagDuration,
      () => _touchpoints,
    );
  }

  @override
  deleteTouchpoint({required int id}) async {
    _touchpoints.removeWhere((touchpoint) => touchpoint.id == id);
    await Future.delayed(_lagDuration);
  }

  @override
  Future<MTouchpoint> updateTouchpoint(MTouchpoint touchpoint) {
    _touchpoints = _touchpoints
        .map((t) => t.id == touchpoint.id ? touchpoint : t)
        .toList();

    if (touchpoint.position != null) {
      final beacon = _beacons.firstWhereOrNull(
        (b) => b.touchpointId == touchpoint.id,
      );
      if (beacon != null) {
        _beacons = _beacons
            .map((b) => b.touchpointId == touchpoint.id
                ? beacon.copyWith(position: touchpoint.position!)
                : b)
            .toList();
      } else {
        _beacons.add(MBeacon(
          beaconId: touchpoint.id.toString(),
          touchpointId: touchpoint.id,
          position: touchpoint.position!,
        ));
      }
    }

    return Future.delayed(_lagDuration, () => touchpoint);
  }

  @override
  Future<MTouchpoint> createTouchpoint(MTouchpoint touchpoint) {
    final newTouchpoint = touchpoint.copyWith(
      id: _touchpoints.length + 1,
      touchpointId: _touchpoints.length + 1,
    );

    _touchpoints.add(newTouchpoint);

    if (newTouchpoint.position != null) {
      createBeacon(MBeacon(
        beaconId: newTouchpoint.id.toString(),
        touchpointId: newTouchpoint.id,
        position: newTouchpoint.position!,
      ));
    }

    return Future.delayed(_lagDuration, () => newTouchpoint);
  }

  @override
  Future<MTouchpoint> getTouchpoint({required int id}) {
    return Future.delayed(
      _lagDuration,
      () => _touchpoints.firstWhere((touchpoint) => touchpoint.id == id),
    );
  }

  @override
  Future<List<MTouchpoint>> getTouchpointsOfFloorplan(
      {required int floorplanId}) {
    return Future.delayed(
      _lagDuration,
      () => _touchpoints
          .where((touchpoint) => touchpoint.position?.parentId == floorplanId)
          .toList(),
    );
  }

  @override
  deleteMPTouchpointConfig({required int id}) async {
    _mpTouchpointConfigs.removeWhere((config) => config.id == id);
    await Future.delayed(_lagDuration);
  }

  @override
  Future<MMPTouchpointConfig> updateMPTouchpointConfig(
      MMPTouchpointConfig config) {
    _mpTouchpointConfigs = _mpTouchpointConfigs
        .map((c) => c.id == config.id ? config : c)
        .toList();
    return Future.delayed(_lagDuration, () => config);
  }

  @override
  Future<MMPTouchpointConfig> createMPTouchpointConfig(
      MMPTouchpointConfig config) {
    _mpTouchpointConfigs
        .add(config.copyWith(id: _mpTouchpointConfigs.length + 1));
    return Future.delayed(_lagDuration, () => config);
  }

  @override
  Future<MMPTouchpointConfig> getMPTouchpointConfigForTouchpoint(
      {required int touchpointId}) {
    return Future.delayed(
      _lagDuration,
      () => _mpTouchpointConfigs
          .firstWhere((config) => config.touchpointId == touchpointId),
    );
  }

  @override
  Future<MMPTouchpointConfig> getMPTouchpointConfig({required int id}) {
    return Future.delayed(
      _lagDuration,
      () => _mpTouchpointConfigs.firstWhere((config) => config.id == id),
    );
  }

  @override
  deleteAGTouchpointConfig({required int id}) async {
    _agTouchpointConfigs.removeWhere((config) => config.id == id);
    await Future.delayed(_lagDuration);
  }

  @override
  Future<MAGTouchpointConfig> updateAGTouchpointConfig(
      MAGTouchpointConfig config) {
    _agTouchpointConfigs = _agTouchpointConfigs
        .map((c) => c.id == config.id ? config : c)
        .toList();
    return Future.delayed(_lagDuration, () => config);
  }

  @override
  Future<MAGTouchpointConfig> createAGTouchpointConfig(
      MAGTouchpointConfig config) {
    _agTouchpointConfigs
        .add(config.copyWith(id: _agTouchpointConfigs.length + 1));
    return Future.delayed(_lagDuration, () => config);
  }

  @override
  Future<MAGTouchpointConfig> getAGTouchpointConfigForTouchpoint(
      {required int touchpointId}) async {
    var config = _agTouchpointConfigs.firstWhereOrNull(
      (config) => config.touchpointId == touchpointId,
    );

    if (config == null) {
      config = MAGTouchpointConfig(touchpointId: touchpointId, contents: [
        MAGContent(
          id: Random().nextInt(2 ^ 32),
          label: 'Audio DE',
          language: 'de',
        ),
        MAGContent(
          id: Random().nextInt(2 ^ 32),
          label: 'Audio EN',
          language: 'en',
        ),
        MAGContent(
          id: Random().nextInt(2 ^ 32),
          label: 'Audio FR',
          language: 'fr',
        ),
      ]);

      _agTouchpointConfigs
          .add(config.copyWith(id: _agTouchpointConfigs.length + 1));
    }

    _logger.info(config);

    return await Future.delayed(_lagDuration, () => config!);
  }

  @override
  Future<MAGTouchpointConfig> getAGTouchpointConfig({required int id}) {
    return Future.delayed(
      _lagDuration,
      () => _agTouchpointConfigs.firstWhere((config) => config.id == id),
    );
  }

  @override
  Future<void> deleteAGContent({required int id}) {
    _agTouchpointConfigs = _agTouchpointConfigs.map((config) {
      config = config.copyWith(
          contents:
              config.contents.where((content) => content.id != id).toList());
      return config;
    }).toList();
    return Future.delayed(_lagDuration, () {});
  }

  @override
  Future<MAGContent> updateAGContent(MAGContent content) {
    _agTouchpointConfigs = _agTouchpointConfigs.map((config) {
      config = config.copyWith(
          contents: config.contents
              .map((c) => c.id == content.id ? content : c)
              .toList());
      return config;
    }).toList();
    return Future.delayed(_lagDuration, () => content);
  }

  @override
  Future<MAGContent> createAGContent(MAGContent content,
      {required int touchpointId}) async {
    var config = _agTouchpointConfigs
        .firstWhere((config) => config.touchpointId == touchpointId);
    config = config.copyWith(contents: [...config.contents, content]);
    await updateAGTouchpointConfig(config);
    return Future.delayed(_lagDuration, () => content);
  }

  @override
  Future<MAGContent> getAGContent({required int id}) {
    return Future.delayed(
      _lagDuration,
      () => _agTouchpointConfigs
          .map((config) => config.contents)
          .expand((contents) => contents)
          .firstWhere((content) => content.id == id),
    );
  }

  @override
  Future<void> deleteBeacon({required String beaconId}) async {
    _beacons.removeWhere((beacon) => beacon.beaconId == beaconId);
    return Future.delayed(_lagDuration, () {});
  }

  @override
  Future<MBeacon> updateBeacon(MBeacon beacon) {
    _beacons = _beacons
        .map((b) => b.beaconId == beacon.beaconId ? beacon : b)
        .toList();
    return Future.delayed(_lagDuration, () => beacon);
  }

  @override
  Future<MBeacon> createBeacon(MBeacon beacon) {
    _beacons.add(beacon);
    return Future.delayed(_lagDuration, () => beacon);
  }

  @override
  Future<MBeacon> getBeacon({required String beaconId}) {
    return Future.delayed(_lagDuration,
        () => _beacons.firstWhere((beacon) => beacon.beaconId == beaconId));
  }

  @override
  Future<List<MBeacon>> getBeaconsOfFloorplan({required int floorplanId}) {
    return Future.delayed(_lagDuration, () => _beacons.toList());
  }

  @override
  Future<List<MBeacon>> getBeacons() {
    return Future.delayed(_lagDuration, () => _beacons);
  }
}
