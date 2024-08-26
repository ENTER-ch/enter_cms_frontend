import 'dart:async';

import 'package:enter_cms_flutter/models/beacon.dart';
import 'package:enter_cms_flutter/providers/services/cms_api_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'beacon_provider.g.dart';

@Riverpod(
  dependencies: [
    cmsApi,
  ],
)
class Beacon extends _$Beacon {
  Future<MBeacon> _fetchBeacon(int id) async {
    final api = ref.watch(cmsApiProvider);
    return await api.getBeacon(id);
  }

  @override
  FutureOr<MBeacon> build(int id) async {
    return _fetchBeacon(id);
  }

  Future<void> delete() async {
    final api = ref.watch(cmsApiProvider);
    await api.deleteBeacon(id);
  }
}

@riverpod
class BeaconList extends _$BeaconList {
  Future<List<MBeacon>> _fetchBeacons() async {
    final api = ref.watch(cmsApiProvider);
    return await api.getBeacons();
  }

  @override
  FutureOr<List<MBeacon>> build() {
    return _fetchBeacons();
  }
}
