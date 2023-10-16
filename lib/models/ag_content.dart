import 'package:freezed_annotation/freezed_annotation.dart';

part 'ag_content.freezed.dart';
part 'ag_content.g.dart';

@freezed
class MAGContent with _$MAGContent {
  const factory MAGContent({
    int? id,
    bool? dirty,
    String? label,
    String? language,
    @JsonKey(name: 'config') int? agConfigId,
    @JsonKey(name: 'media_track') int? mediaTrackId,
    @JsonKey(name: 'needs_release') bool? needsRelease,
  }) = _MAGContent;

  const MAGContent._();

  factory MAGContent.fromJson(Map<String, dynamic> json) =>
      _$MAGContentFromJson(json);

  String get shortLabel {
    return label?.replaceAll(RegExp(r'\s+'), ' ') ?? '';
  }
}
