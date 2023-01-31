import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'position.freezed.dart';
part 'position.g.dart';

@freezed
class MPosition with _$MPosition {
  const MPosition._();

  const factory MPosition({
    int? id,
    @JsonKey(name: 'parent_id')
    int? parentId,
    required double x,
    required double y,
  }) = _MPosition;

  factory MPosition.fromJson(Map<String, dynamic> json) =>
      _$MPositionFromJson(json);

  Offset toOffset() => Offset(x, y);
}
