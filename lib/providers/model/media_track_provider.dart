import 'package:enter_cms_flutter/models/media_track.dart';
import 'package:enter_cms_flutter/providers/services/cms_api_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'media_track_provider.g.dart';

@Riverpod(dependencies: [
  cmsApi,
])
class MediaTrack extends _$MediaTrack {
  Future<MMediaTrack> _fetch(int id) async {
    final api = ref.watch(cmsApiProvider);
    return await api.getMediaTrack(id);
  }

  @override
  FutureOr<MMediaTrack> build(int id) {
    return _fetch(id);
  }
}
