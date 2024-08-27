import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_language.freezed.dart';
part 'media_language.g.dart';

@freezed
class MMediaLanguage with _$MMediaLanguage {
  const factory MMediaLanguage({
    @JsonKey(name: 'short_code') String? shortCode,
    String? name,
  }) = _MMediaLanguage;

  const MMediaLanguage._();

  factory MMediaLanguage.fromJson(Map<String, dynamic> json) =>
      _$MMediaLanguageFromJson(json);

  factory MMediaLanguage.empty() => const MMediaLanguage(
        shortCode: '',
        name: '',
      );

  @override
  String toString() {
    return name ?? 'Unnamed';
  }
}
