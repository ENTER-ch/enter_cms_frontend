import 'package:enter_cms_flutter/models/ag_touchpoint_config.dart';
import 'package:enter_cms_flutter/models/position.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:enter_cms_flutter/pages/content/content_state.dart';
import 'package:enter_cms_flutter/providers/services/cms_api_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'touchpoint_detail.g.dart';

@Riverpod(dependencies: [
  selectedTouchpointId,
  cmsApi,
  ContentViewController,
])
class TouchpointDetailState extends _$TouchpointDetailState {
  Future<MTouchpoint> _fetchTouchpoint(int id) async {
    final api = ref.watch(cmsApiProvider);
    return await api.getTouchpoint(id);
  }

  @override
  Future<MTouchpoint> build() {
    final id = ref.watch(selectedTouchpointIdProvider);
    if (id == null) {
      throw Exception('No touchpoint selected');
    }
    return _fetchTouchpoint(id);
  }

  Future<MTouchpoint?> updateTouchpoint({
    int? touchpointId,
    MPosition? position,
    String? internalTitle,
    TouchpointStatus? status,
  }) async {
    if (state.isLoading || state.hasError) return null;

    final api = ref.watch(cmsApiProvider);
    final result = await api.updateTouchpoint(
      state.value!.id!,
      touchpointId: touchpointId,
      position: position,
      internalTitle: internalTitle,
      status: status,
    );
    ref.read(contentViewControllerProvider.notifier).refreshView();
    state = AsyncValue.data(result);
    return result;
  }

  Future<MTouchpoint?> updateAgConfig({
    AGPlaybackMode? playbackMode,
  }) async {
    if (state.isLoading || state.hasError) return null;

    final api = ref.watch(cmsApiProvider);
    final result = await api.updateAGTouchpointConfig(
      state.value!.agConfig!.id!,
      playbackMode: playbackMode,
    );
    ref.read(contentViewControllerProvider.notifier).refreshView();
    state = AsyncValue.data(result);
    return result;
  }
}

@Riverpod(dependencies: [
  TouchpointDetailState,
])
class TouchpointIdField extends _$TouchpointIdField {
  @override
  FutureOr<int?> build() async {
    final touchpoint = ref.watch(touchpointDetailStateProvider);
    return touchpoint.valueOrNull?.touchpointId;
  }

  Future<void> updateValue(int touchpointId) async {
    final touchpoint = ref.read(touchpointDetailStateProvider.notifier);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updated = await touchpoint.updateTouchpoint(
        touchpointId: touchpointId,
      );
      return updated?.touchpointId!;
    });
  }
}

@Riverpod(dependencies: [
  TouchpointDetailState,
])
class TouchpointInternalTitleField extends _$TouchpointInternalTitleField {
  @override
  FutureOr<String?> build() async {
    final touchpoint = ref.watch(touchpointDetailStateProvider);
    return touchpoint.valueOrNull?.internalTitle;
  }

  Future<void> updateValue(String internalTitle) async {
    final touchpoint = ref.read(touchpointDetailStateProvider.notifier);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updated = await touchpoint.updateTouchpoint(
        internalTitle: internalTitle,
      );
      return updated?.internalTitle!;
    });
  }
}

@Riverpod(dependencies: [
  TouchpointDetailState,
])
class TouchpointStatusField extends _$TouchpointStatusField {
  @override
  FutureOr<TouchpointStatus?> build() async {
    final touchpoint = ref.watch(touchpointDetailStateProvider);
    return touchpoint.valueOrNull?.status;
  }

  Future<void> updateValue(TouchpointStatus status) async {
    final touchpoint = ref.read(touchpointDetailStateProvider.notifier);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updated = await touchpoint.updateTouchpoint(
        status: status,
      );
      return updated?.status!;
    });
  }
}
