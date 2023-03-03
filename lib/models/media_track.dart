import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_track.freezed.dart';
part 'media_track.g.dart';

@freezed
class MMediaTrack with _$MMediaTrack {
  const factory MMediaTrack({
    int? id,
    required MediaType type,
    int? source,
    String? language,
    @JsonKey(name: 'file_name')
    String? filename,
    @JsonKey(name: 'stream_id')
    required int streamId,
    @JsonKey(name: 'preview_url')
    String? previewUrl,
  }) = _MMediaTrack;

  factory MMediaTrack.fromJson(Map<String, dynamic> json) =>
      _$MMediaTrackFromJson(json);
}

enum MediaType {
  audio,
  video,
}
extension MediaTypeExtension on MediaType {
  String get label {
    switch (this) {
      case MediaType.audio:
        return 'Audio';
      case MediaType.video:
        return 'Video';
    }
  }
}