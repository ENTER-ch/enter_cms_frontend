import 'package:enter_cms_flutter/models/floorplan.dart';
import 'package:enter_cms_flutter/providers/services/cms_api_provider.dart';
import 'package:enter_cms_flutter/utils/cache_for.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'floorplan_provider.g.dart';

@Riverpod(dependencies: [
  cmsApi,
])
class FloorplanManager extends _$FloorplanManager {
  @override
  FutureOr<List<MFloorplan>> build() async {
    ref.cacheFor(const Duration(seconds: 30));
    return _loadFloorplans();
  }

  Future<List<MFloorplan>> _loadFloorplans() async {
    final cmsApi = ref.read(cmsApiProvider);
    return cmsApi.getFloorplans();
  }
}
