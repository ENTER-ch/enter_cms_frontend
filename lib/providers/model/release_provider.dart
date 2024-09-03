import 'dart:async';

import 'package:enter_cms_flutter/models/release.dart';
import 'package:enter_cms_flutter/models/release_preview.dart';
import 'package:enter_cms_flutter/providers/services/cms_api_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'release_provider.g.dart';

@Riverpod(
  dependencies: [
    cmsApi,
  ],
)
class Release extends _$Release {
  Timer? _refreshTimer;

  Future<MRelease> _fetchRelease(int? id) async {
    final api = ref.watch(cmsApiProvider);
    if (id == null) {
      return await api.getCurrentRelease();
    }
    return await api.getRelease(id);
  }

  @override
  FutureOr<MRelease> build(int? id) async {
    final release = await _fetchRelease(id);

    if ([ReleaseStatus.created, ReleaseStatus.processing]
        .contains(release.status)) {
      _refreshTimer?.cancel();
      _refreshTimer = Timer(
        const Duration(seconds: 1),
        () => build(id),
      );
    }

    return release;
  }
}

@Riverpod(
  dependencies: [
    cmsApi,
  ],
)
class ReleasePreview extends _$ReleasePreview {
  Future<MReleasePreview> _fetchReleasePreview() async {
    final api = ref.watch(cmsApiProvider);
    return await api.getReleasePreview();
  }

  @override
  FutureOr<MReleasePreview> build() async {
    return _fetchReleasePreview();
  }
}
