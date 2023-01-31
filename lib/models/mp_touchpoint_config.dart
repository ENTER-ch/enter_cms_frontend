import 'package:enter_cms_flutter/models/mp_content.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'mp_touchpoint_config.freezed.dart';
part 'mp_touchpoint_config.g.dart';

@freezed
class MMPTouchpointConfig with _$MMPTouchpointConfig {
  const factory MMPTouchpointConfig({
    int? id,
    @JsonKey(name: 'touchpoint_id')
    int? touchpointId,
    @Default([])
    List<MMPContent> contents,
  }) = _MMPTouchpointConfig;

  factory MMPTouchpointConfig.fromJson(Map<String, dynamic> json) =>
      _$MMPTouchpointConfigFromJson(json);
}
