import 'package:freezed_annotation/freezed_annotation.dart';

part 'floorplan.freezed.dart';
part 'floorplan.g.dart';

@freezed
class MFloorplan with _$MFloorplan {
  const factory MFloorplan({
    required int id,
    required String image,
    required int width,
    required int height,
    @JsonKey(name: 'scale_factor') @Default(1.0) double scaleFactor,
    String? title,
  }) = _MFloorplan;

  factory MFloorplan.fromJson(Map<String, dynamic> json) =>
      _$MFloorplanFromJson(json);
}
