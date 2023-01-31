import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ag_content.freezed.dart';
part 'ag_content.g.dart';

@freezed
class MAGContent with _$MAGContent {
  const factory MAGContent({
    int? id,
    required AGContentType type,
    String? label,
    String? language,
    @JsonKey(name: 'needs_release')
    bool? needsRelease,
  }) = _MAGContent;

  factory MAGContent.fromJson(Map<String, dynamic> json) =>
      _$MAGContentFromJson(json);
}

enum AGContentType {
  @JsonValue('audio')
  audio,
  @JsonValue('tts')
  tts,
}

extension AGContentTypeExtension on AGContentType {
  IconData get icon {
    switch (this) {
      case AGContentType.audio:
        return Icons.headphones;
      case AGContentType.tts:
        return Icons.record_voice_over;
    }
  }
}