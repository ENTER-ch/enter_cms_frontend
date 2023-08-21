import 'package:enter_cms_flutter/models/beacon.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'floorplan_view.freezed.dart';
part 'floorplan_view.g.dart';

@freezed
class MFloorplanView with _$MFloorplanView {
  const factory MFloorplanView({
    required List<MBeacon> beacons,
    required List<MTouchpoint> touchpoints,
  }) = _MFloorplanView;

  const MFloorplanView._();

  factory MFloorplanView.fromJson(Map<String, dynamic> json) =>
      _$MFloorplanViewFromJson(json);

  bool containsTouchpoint(int touchpointId) {
    return touchpoints.any((element) => element.id == touchpointId);
  }

  MFloorplanView addOrUpdateTouchpoint(MTouchpoint touchpoint) {
    final index =
        touchpoints.indexWhere((element) => element.id == touchpoint.id);
    if (index == -1) {
      return copyWith(
        touchpoints: [...touchpoints, touchpoint],
      );
    } else {
      return copyWith(
        touchpoints: touchpoints
            .map((e) => e.id == touchpoint.id ? touchpoint : e)
            .toList(),
      );
    }
  }

  bool containsBeacon(String beaconId) {
    return beacons.any((element) => element.beaconId == beaconId);
  }
}
