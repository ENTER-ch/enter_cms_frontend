import 'package:enter_cms_flutter/models/ag_touchpoint_config.dart';
import 'package:enter_cms_flutter/providers/state/touchpoint_detail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ag_touchpoint_editor.g.dart';

@Riverpod(dependencies: [
  TouchpointDetailState,
])
MAGTouchpointConfig? agTouchpointConfig(AgTouchpointConfigRef ref) {
  final touchpoint = ref.watch(touchpointDetailStateProvider);
  return touchpoint.valueOrNull?.agConfig;
}

@Riverpod(dependencies: [
  TouchpointDetailState,
  agTouchpointConfig,
])
class AGTouchpointPlaybackModeField extends _$AGTouchpointPlaybackModeField {
  @override
  FutureOr<AGPlaybackMode?> build() async {
    final agConfig = ref.watch(agTouchpointConfigProvider);
    return agConfig?.playbackMode;
  }

  Future<void> updateValue(AGPlaybackMode? value) async {
    final touchpoint = ref.read(touchpointDetailStateProvider.notifier);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updated = await touchpoint.updateAgConfig(
        playbackMode: value,
      );
      return updated?.agConfig?.playbackMode;
    });
  }
}
