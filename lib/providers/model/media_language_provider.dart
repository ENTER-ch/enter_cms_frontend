import 'package:enter_cms_flutter/providers/services/cms_api_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:enter_cms_flutter/models/media_language.dart';

part 'media_language_provider.g.dart';

@riverpod
class MediaLanguageList extends _$MediaLanguageList {
  Future<List<MMediaLanguage>> _fetchMediaLanguages() async {
    final api = ref.watch(cmsApiProvider);
    return await api.getMediaLanguages();
  }

  @override
  FutureOr<List<MMediaLanguage>> build() {
    return _fetchMediaLanguages();
  }
}
