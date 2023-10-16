import 'package:enter_cms_flutter/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'checklist.freezed.dart';
part 'checklist.g.dart';

enum MChecklistItemType {
  @JsonValue('error')
  error,
}

extension MChecklistItemTypeExtension on MChecklistItemType {
  IconData get icon {
    switch (this) {
      case MChecklistItemType.error:
        return Icons.error;
    }
  }

  Color get color {
    switch (this) {
      case MChecklistItemType.error:
        return EnterThemeColors.red;
    }
  }
}

@freezed
class MChecklistItem with _$MChecklistItem {
  static const _codeLabels = {
    "ag_touchpoint_no_content": "No Content",
    "content_media_track_null": "Missing Media",
  };

  const factory MChecklistItem({
    required MChecklistItemType type,
    required String code,
    String? message,
  }) = _MChecklistItem;

  const MChecklistItem._();

  factory MChecklistItem.fromJson(Map<String, dynamic> json) =>
      _$MChecklistItemFromJson(json);

  String get label => _codeLabels[code] ?? code;
}
