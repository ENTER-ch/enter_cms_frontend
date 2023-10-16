import 'package:enter_cms_flutter/models/ag_content.dart';
import 'package:enter_cms_flutter/models/ag_touchpoint_config.dart';
import 'package:enter_cms_flutter/models/checklist.dart';
import 'package:enter_cms_flutter/models/mp_touchpoint_config.dart';
import 'package:enter_cms_flutter/models/position.dart';
import 'package:enter_cms_flutter/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'touchpoint.freezed.dart';
part 'touchpoint.g.dart';

@freezed
class MTouchpoint with _$MTouchpoint {
  const MTouchpoint._();

  const factory MTouchpoint({
    int? id,
    required TouchpointType type,
    TouchpointStatus? status,
    bool? dirty,
    @JsonKey(name: 'touchpoint_id') int? touchpointId,
    MPosition? position,
    @JsonKey(name: 'internal_title') String? internalTitle,
    @JsonKey(name: 'ag_config') MAGTouchpointConfig? agConfig,
    @JsonKey(name: 'mp_config') MMPTouchpointConfig? mpConfig,
    @Default([]) List<MChecklistItem> checklist,
  }) = _MTouchpoint;

  factory MTouchpoint.fromJson(Map<String, dynamic> json) =>
      _$MTouchpointFromJson(json);

  MTouchpoint replaceContent(MAGContent content) {
    return copyWith(
      agConfig: agConfig?.replaceContent(content),
    );
  }

  String get title => internalTitle ?? 'Touchpoint $touchpointIdString';

  String get touchpointIdString =>
      touchpointId?.toString().padLeft(3, "0") ?? '---';

  Color getStatusColor(BuildContext context) {
    if (checklist.isNotEmpty) {
      return EnterThemeColors.red;
    }

    switch (status) {
      case TouchpointStatus.draft:
        return Colors.grey;
      case TouchpointStatus.published:
        if (dirty != true) {
          return EnterThemeColors.green;
        } else {
          return EnterThemeColors.blue;
        }
      default:
        return Colors.grey;
    }
  }

  String get statusLabel {
    if (checklist.isNotEmpty) {
      return "Incomplete";
    }

    switch (status) {
      case TouchpointStatus.draft:
        return "Draft";
      case TouchpointStatus.published:
        if (dirty != true) {
          return "Released";
        } else {
          return "Ready for Release";
        }
      default:
        return "Unknown";
    }
  }

  bool searchFields(String query) {
    final q = query.toUpperCase();
    // Search internalTitle, touchpointId
    return (internalTitle?.toUpperCase().contains(q) ?? false) ||
        (touchpointId?.toString().toUpperCase().contains(q) ?? false);
  }
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
        return EnterThemeColors.green;
      case TouchpointType.waypoint:
        return EnterThemeColors.red;
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

enum TouchpointStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('published')
  published,
  @JsonValue('deleted')
  deleted,
}

extension TouchpointStatusExtension on TouchpointStatus {
  String get uiTitle {
    switch (this) {
      case TouchpointStatus.draft:
        return 'Draft';
      case TouchpointStatus.published:
        return 'Published';
      case TouchpointStatus.deleted:
        return 'Deleted';
    }
  }
}
