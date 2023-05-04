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

  factory MFloorplanView.fromJson(Map<String, dynamic> json) =>
      _$MFloorplanViewFromJson(json);
}
