import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:enter_cms_flutter/models/position.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';

part 'beacon.freezed.dart';
part 'beacon.g.dart';

@freezed
class MBeacon with _$MBeacon {
  const factory MBeacon({
    @JsonKey(name: 'beacon_id')
    required String beaconId,
    required MPosition position,
    required MTouchpoint touchpoint,
    double? radius,
  }) = _MBeacon;

  factory MBeacon.fromJson(Map<String, dynamic> json) =>
      _$MBeaconFromJson(json);
}
