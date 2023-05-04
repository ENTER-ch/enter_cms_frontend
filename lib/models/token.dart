import 'package:freezed_annotation/freezed_annotation.dart';

part 'token.freezed.dart';
part 'token.g.dart';

@freezed
class MToken with _$MToken {
  const factory MToken({
    required String access,
    String? refresh,
    String? username,
    String? password,
  }) = _MToken;

  factory MToken.fromJson(Map<String, dynamic> json) => _$MTokenFromJson(json);
}
