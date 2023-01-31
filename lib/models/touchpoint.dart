import 'package:enter_cms_flutter/models/position.dart';
import 'package:enter_cms_flutter/theme.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'touchpoint.freezed.dart';
part 'touchpoint.g.dart';

@freezed
class MTouchpoint with _$MTouchpoint {
  const factory MTouchpoint({
    int? id,
    required TouchpointType type,
    @JsonKey(name: 'touchpoint_id')
    int? touchpointId,
    MPosition? position,
    @JsonKey(name: 'internal_title')
    String? internalTitle,
}) = _MTouchpoint;

  factory MTouchpoint.fromJson(Map<String, dynamic> json) =>
      _$MTouchpointFromJson(json);
}

enum TouchpointType {
  @JsonValue('audioguide')
  audioguide,
  @JsonValue('mediaplayer')
  mediaplayer,
  @JsonValue('waypoint')
  waypoint
}

extension TouchpointTypeExtension on TouchpointType {
  Color get color {
    switch (this) {
      case TouchpointType.audioguide:
        return lightColorScheme.primary;
      case TouchpointType.mediaplayer:
        return Colors.green;
      case TouchpointType.waypoint:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case TouchpointType.audioguide:
        return Icons.headphones;
      case TouchpointType.mediaplayer:
        return Icons.tv;
      case TouchpointType.waypoint:
        return Icons.location_on;
    }
  }

  String get uiTitle {
    switch (this) {
      case TouchpointType.audioguide:
        return 'Audioguide';
      case TouchpointType.mediaplayer:
        return 'Mediaplayer';
      case TouchpointType.waypoint:
        return 'Waypoint';
    }
  }
}