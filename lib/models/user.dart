import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class MUser with _$MUser {
  const MUser._();

  const factory MUser({
    required int id,
    required String username,
    String? email,
    @JsonKey(name: 'is_staff') bool? isStaff,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'date_joined') DateTime? dateJoined,
    @JsonKey(name: 'last_login') DateTime? lastLogin,
  }) = _MUser;

  factory MUser.fromJson(Map<String, dynamic> json) => _$MUserFromJson(json);

  String get fullName {
    if (firstName == null || firstName!.isEmpty || lastName == null || lastName!.isEmpty) {
      return username;
    }
    return '$firstName $lastName';
  }

  String get initials {
    if (firstName == null || firstName!.isEmpty || lastName == null || lastName!.isEmpty) {
      return username.substring(0, 2).toUpperCase();
    }
    return '${firstName![0]}${lastName![0]}'.toUpperCase();
  }
}
