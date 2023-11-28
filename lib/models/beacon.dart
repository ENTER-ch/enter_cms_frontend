import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:enter_cms_flutter/models/position.dart';

part 'beacon.freezed.dart';
part 'beacon.g.dart';

@freezed
class MBeacon with _$MBeacon {
  const factory MBeacon({
    int? id,
    @JsonKey(name: 'beacon_id') int? beaconId,
    required MPosition position,
    @JsonKey(name: 'touchpoint') int? touchpointId,
    double? radius,
    String? comment,
  }) = _MBeacon;

  const MBeacon._();

  factory MBeacon.fromJson(Map<String, dynamic> json) =>
      _$MBeaconFromJson(json);

  String? get idHexString {
    if (beaconId == null) {
      return null;
    }
    final hexString = beaconId!.toRadixString(16).padLeft(8, '0');
    final decimalString = beaconId!.toString();
    return '${hexString.replaceAllMapped(RegExp(r'.{2}'), (match) => '${match.group(0)} ').trim()} ($decimalString)';
  }
}
