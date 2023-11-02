import 'package:enter_cms_flutter/models/position.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:enter_cms_flutter/providers/services/cms_api_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'touchpoint_provider.g.dart';

@Riverpod(
  dependencies: [
    cmsApi,
  ],
)
class Touchpoint extends _$Touchpoint {
  Future<MTouchpoint> _fetchTouchpoint(int id) async {
    final api = ref.watch(cmsApiProvider);
    return await api.getTouchpoint(id);
  }

  @override
  FutureOr<MTouchpoint> build(int id) async {
    return _fetchTouchpoint(id);
  }

  Future<void> updateTouchpoint({
    int? touchpointId,
    MPosition? position,
    String? internalTitle,
    TouchpointStatus? status,
  }) async {
    if (state.isLoading) return;

    final api = ref.watch(cmsApiProvider);
    state = await AsyncValue.guard(() async {
      return api.updateTouchpoint(
        state.value!.id!,
        touchpointId: touchpointId,
        position: position,
        internalTitle: internalTitle,
        status: status,
      );
    });
  }
}
