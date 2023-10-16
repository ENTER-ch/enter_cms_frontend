import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'release.freezed.dart';
part 'release.g.dart';

enum ReleaseStatus {
  created,
  processing,
  ready,
  error,
  released,
}

extension ReleaseStatusExtension on ReleaseStatus {
  String get label => switch (this) {
        ReleaseStatus.created => 'Created',
        ReleaseStatus.processing => 'Processing',
        ReleaseStatus.ready => 'Ready',
        ReleaseStatus.error => 'Error',
        ReleaseStatus.released => 'Released',
      };

  Color get color => switch (this) {
        ReleaseStatus.created => Colors.grey,
        ReleaseStatus.processing => Colors.blue,
        ReleaseStatus.ready => Colors.green,
        ReleaseStatus.error => Colors.red,
        ReleaseStatus.released => Colors.green,
      };
}

@freezed
class MRelease with _$MRelease {
  const factory MRelease({
    String? title,
    required ReleaseStatus status,
    @JsonKey(name: 'created_at') required String createdAt,
    required int version,
  }) = _MRelease;

  const MRelease._();

  factory MRelease.fromJson(Map<String, dynamic> json) =>
      _$MReleaseFromJson(json);

  String get label => 'v$version, $createdAt';
}
