import 'package:enter_cms_flutter/models/ag_content.dart';
import 'package:enter_cms_flutter/providers/services/cms_api_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ag_content_provider.g.dart';

@Riverpod(
  dependencies: [
    cmsApi,
  ],
)
@riverpod
class AGContent extends _$AGContent {
  Future<MAGContent> _fetch(int id) async {
    final api = ref.watch(cmsApiProvider);
    return await api.getAGContent(id);
  }

  @override
  FutureOr<MAGContent> build(int id) {
    return _fetch(id);
  }
}
