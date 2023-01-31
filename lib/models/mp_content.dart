import 'package:freezed_annotation/freezed_annotation.dart';

part 'mp_content.freezed.dart';
part 'mp_content.g.dart';

@freezed
class MMPContent with _$MMPContent {
  const factory MMPContent({
    int? id,
    String? label,
    String? language,
    @JsonKey(name: 'needs_release')
    bool? needsRelease,
  }) = _MMPContent;

  factory MMPContent.fromJson(Map<String, dynamic> json) =>
      _$MMPContentFromJson(json);
}