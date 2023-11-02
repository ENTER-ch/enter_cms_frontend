import 'package:enter_cms_flutter/models/ag_touchpoint_config.dart';
import 'package:enter_cms_flutter/providers/model/touchpoint_provider.dart';
import 'package:enter_cms_flutter/providers/services/cms_api_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ag_config_provider.g.dart';

@Riverpod(
  dependencies: [
    cmsApi,
    Touchpoint,
  ],
)
class AGTouchpointConfig extends _$AGTouchpointConfig {
  Future<MAGTouchpointConfig> _fetch(int id) async {
    final api = ref.watch(cmsApiProvider);
    return await api.getAGTouchpointConfig(id);
  }

  @override
  FutureOr<MAGTouchpointConfig> build(int id) async {
    return _fetch(id);
  }

  Future<void> updateConfig({
    AGPlaybackMode? playbackMode,
  }) async {
    if (state.isLoading) return;

    final api = ref.watch(cmsApiProvider);
    state = await AsyncValue.guard(() async {
      return api.updateAGTouchpointConfig(
        state.value!.id!,
        playbackMode: playbackMode,
      );
    });

    ref.invalidate(touchpointProvider);
  }
}
