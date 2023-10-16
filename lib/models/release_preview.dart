import 'package:freezed_annotation/freezed_annotation.dart';

part 'release_preview.freezed.dart';
part 'release_preview.g.dart';

@freezed
class MReleasePreview with _$MReleasePreview {
  const factory MReleasePreview({
    required int count,
  }) = _MReleasePreview;

  const MReleasePreview._();

  factory MReleasePreview.fromJson(Map<String, dynamic> json) =>
      _$MReleasePreviewFromJson(json);
}
