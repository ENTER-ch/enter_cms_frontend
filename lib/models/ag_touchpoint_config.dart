import 'package:enter_cms_flutter/models/ag_content.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ag_touchpoint_config.freezed.dart';
part 'ag_touchpoint_config.g.dart';

@freezed
class MAGTouchpointConfig with _$MAGTouchpointConfig {
  const factory MAGTouchpointConfig({
    int? id,
    @JsonKey(name: 'touchpoint_id')
    int? touchpointId,
    @Default([])
    List<MAGContent> contents,
    @JsonKey(name: 'playback_mode')
    @Default(AGPlaybackMode.prompt)
    AGPlaybackMode playbackMode,
    @JsonKey(name: 'needs_release')
    bool? needsRelease,
  }) = _MAGTouchpointConfig;

  factory MAGTouchpointConfig.fromJson(Map<String, dynamic> json) =>
      _$MAGTouchpointConfigFromJson(json);
}

enum AGPlaybackMode {
  @JsonValue('auto_single')
  autoSingle,
  @JsonValue('auto_loop')
  autoLoop,
  @JsonValue('prompt')
  prompt,
}
