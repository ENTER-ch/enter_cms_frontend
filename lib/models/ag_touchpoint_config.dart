import 'package:enter_cms_flutter/models/ag_content.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ag_touchpoint_config.freezed.dart';
part 'ag_touchpoint_config.g.dart';

@freezed
class MAGTouchpointConfig with _$MAGTouchpointConfig {
  const MAGTouchpointConfig._();

  const factory MAGTouchpointConfig({
    int? id,
    @JsonKey(name: 'touchpoint_id')
    int? touchpointId,
    bool? dirty,
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

  MAGTouchpointConfig replaceContent(MAGContent content) {
    return copyWith(
      contents: contents.map((c) => c.id == content.id ? content : c).toList(),
    );
  }
}

enum AGPlaybackMode {
  @JsonValue('auto_single')
  autoSingle,
  @JsonValue('auto_loop')
  autoLoop,
  @JsonValue('prompt')
  prompt,
}
extension AGPlaybackModeExtension on AGPlaybackMode {
  String get label {
    switch (this) {
      case AGPlaybackMode.autoSingle:
        return 'Auto Single';
      case AGPlaybackMode.autoLoop:
        return 'Auto Loop';
      case AGPlaybackMode.prompt:
        return 'Prompt';
    }
  }

  String get jsonValue {
    switch (this) {
      case AGPlaybackMode.autoSingle:
        return 'auto_single';
      case AGPlaybackMode.autoLoop:
        return 'auto_loop';
      case AGPlaybackMode.prompt:
        return 'prompt';
    }
  }
}