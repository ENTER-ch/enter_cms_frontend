import 'package:enter_cms_flutter/models/media_track.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_file.freezed.dart';
part 'media_file.g.dart';

@freezed
class MMediaFile with _$MMediaFile {
  const factory MMediaFile({
    int? id,
    String? name,
    required MediaType type,
    @JsonKey(name: 'media_info')
    Map<String, dynamic>? mediaInfo,
    String? url,
  }) = _MMediaFile;

  factory MMediaFile.fromJson(Map<String, dynamic> json) =>
      _$MMediaFileFromJson(json);
}
