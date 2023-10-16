import 'package:enter_cms_flutter/models/beacon.dart';
import 'package:enter_cms_flutter/models/floorplan.dart';
import 'package:enter_cms_flutter/models/floorplan_view.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:enter_cms_flutter/providers/model/floorplan_provider.dart';
import 'package:enter_cms_flutter/providers/services/cms_api_provider.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'content_state.freezed.dart';
part 'content_state.g.dart';

/// This is a dummy provider that is overridden by the floorplanId coming
/// from the router.
/// This way we can depend on a selected floorplan in the following providers
/// without caring for async logic.
@Riverpod(dependencies: [])
int selectedFloorplanId(SelectedFloorplanIdRef ref) {
  throw UnimplementedError();
}

enum ContentView {
  map,
  list,
}

@Riverpod(dependencies: [])
class SelectedContentView extends _$SelectedContentView {
  @override
  ContentView build() {
    return ContentView.list;
  }

  void set(ContentView view) {
    state = view;
  }
}

@Riverpod(dependencies: [
  selectedFloorplanId,
  FloorplanManager,
])
MFloorplan selectedFloorplan(SelectedFloorplanRef ref) {
  final floorplanId = ref.watch(selectedFloorplanIdProvider);
  final floorplans = ref.watch(floorplanManagerProvider);
  return floorplans.value!.firstWhere((element) => element.id == floorplanId);
}

@freezed
class ContentViewState with _$ContentViewState {
  const factory ContentViewState({
    required int floorplanId,
    required MFloorplanView view,
    int? selectedTouchpointId,
  }) = _ContentViewState;
}

@Riverpod(dependencies: [
  selectedFloorplanId,
  cmsApi,
])
class ContentViewController extends _$ContentViewController {
  Future<MFloorplanView> _loadFloorplanView(int floorplanId) async {
    final cmsApi = ref.read(cmsApiProvider);
    return cmsApi.getFloorplanView(floorplanId);
  }

  @override
  FutureOr<ContentViewState> build() async {
    final floorplanId = ref.watch(selectedFloorplanIdProvider);
    final view = await _loadFloorplanView(floorplanId);

    return ContentViewState(
      floorplanId: floorplanId,
      view: view,
      selectedTouchpointId: state.hasValue
          ? state.value!.selectedTouchpointId ?? view.touchpoints.first.id
          : view.touchpoints.first.id,
    );
  }

  Future<void> refreshView() async {
    final floorplanId = ref.read(selectedFloorplanIdProvider);
    state = await AsyncValue.guard(() async {
      final view = await _loadFloorplanView(floorplanId);
      return state.value!.copyWith(
        view: view,
      );
    });
  }

  Future<void> selectTouchpoint(int touchpointId) async {
    if (state.isLoading || state.hasError) return;
    if (state.value!.selectedTouchpointId != touchpointId) {
      state = AsyncValue.data(state.value!.copyWith(
        selectedTouchpointId: touchpointId,
      ));
    }
  }

  Future<void> updateTouchpoint(
    MTouchpoint touchpoint, {
    bool select = false,
    bool refresh = true,
  }) async {
    if (state.hasError || !state.hasValue) return;

    final currentState = state.value!;

    state = AsyncValue.data(currentState.copyWith(
      view: currentState.view.addOrUpdateTouchpoint(touchpoint),
      selectedTouchpointId:
          select ? touchpoint.id : currentState.selectedTouchpointId,
    ));

    // There may have been side effects, so we refresh the FloorplanView
    // from the server.
    if (refresh) await refreshView();
  }
}

@Riverpod(dependencies: [
  ContentViewController,
])
MFloorplanView? currentFloorplanView(CurrentFloorplanViewRef ref) {
  return ref.watch(contentViewControllerProvider).maybeWhen(
        data: (state) => state.view,
        orElse: () => null,
      );
}

@Riverpod(dependencies: [
  currentFloorplanView,
])
List<MTouchpoint> touchpointsInView(TouchpointsInViewRef ref) {
  final floorplanView = ref.watch(currentFloorplanViewProvider);
  return floorplanView?.touchpoints ?? [];
}

@Riverpod(dependencies: [
  currentFloorplanView,
])
List<MBeacon> beaconsInView(BeaconsInViewRef ref) {
  final floorplanView = ref.watch(currentFloorplanViewProvider);
  return floorplanView?.beacons ?? [];
}

@Riverpod(dependencies: [
  ContentViewController,
])
int? selectedTouchpointId(SelectedTouchpointIdRef ref) {
  return ref.watch(contentViewControllerProvider).maybeWhen(
        data: (state) => state.selectedTouchpointId,
        orElse: () => null,
      );
}

@Riverpod(dependencies: [
  selectedTouchpointId,
  touchpointsInView,
])
MTouchpoint? selectedTouchpoint(SelectedTouchpointRef ref) {
  final touchpointId = ref.watch(selectedTouchpointIdProvider);
  if (touchpointId == null) return null;
  final touchpoints = ref.watch(touchpointsInViewProvider);
  return touchpoints.firstWhere((element) => element.id == touchpointId);
}

@freezed
class FloorplanViewFilter with _$FloorplanViewFilter {
  factory FloorplanViewFilter({
    required bool Function(MTouchpoint f) filterFun,
  }) = _FloorplanViewFilter;

  factory FloorplanViewFilter.all() => FloorplanViewFilter(
        filterFun: (f) => true,
      );
}

@Riverpod(dependencies: [])
class FloorplanViewFilterController extends _$FloorplanViewFilterController {
  @override
  FloorplanViewFilter build() {
    return FloorplanViewFilter.all();
  }
}

@riverpod
class FloorplanViewSearch extends _$FloorplanViewSearch {
  @override
  String build() {
    return "";
  }

  void updateQuery(String search) {
    state = search;
  }
}

@Riverpod(dependencies: [
  touchpointsInView,
  FloorplanViewFilterController,
])
List<MTouchpoint> touchpointsFiltered(TouchpointsFilteredRef ref) {
  final touchpoints = ref.watch(touchpointsInViewProvider);
  final filter = ref.watch(floorplanViewFilterControllerProvider);
  final search = ref.watch(floorplanViewSearchProvider);
  return touchpoints
      .where(search.isNotEmpty ? (e) => e.searchFields(search) : (e) => true)
      .where(filter.filterFun)
      .toList();
}

@freezed
class TouchpointListSorting with _$TouchpointListSorting {
  factory TouchpointListSorting({
    required int colIndex,
    required bool ascending,
    required List<MTouchpoint> Function(List<MTouchpoint> items) sortFun,
  }) = _TouchpointListSorting;

  factory TouchpointListSorting.byTouchpointId({
    bool ascending = true,
  }) =>
      TouchpointListSorting(
        colIndex: 1,
        sortFun: (items) => items
          ..sort((a, b) => a.touchpointId?.compareTo(b.touchpointId ?? 0) ?? 0),
        ascending: ascending,
      );

  factory TouchpointListSorting.byType({bool ascending = true}) =>
      TouchpointListSorting(
        colIndex: 0,
        sortFun: (items) =>
            items..sort((a, b) => a.type.index.compareTo(b.type.index)),
        ascending: ascending,
      );

  factory TouchpointListSorting.byInternalTitle({
    bool ascending = true,
  }) =>
      TouchpointListSorting(
        colIndex: 2,
        sortFun: (items) => items..sort((a, b) => a.title.compareTo(b.title)),
        ascending: ascending,
      );

  factory TouchpointListSorting.byStatus({
    bool ascending = true,
  }) =>
      TouchpointListSorting(
        colIndex: 3,
        sortFun: (items) =>
            items..sort((a, b) => a.statusLabel.compareTo(b.statusLabel)),
        ascending: ascending,
      );

  static TouchpointListSorting fromColIndex(
    int colIndex, {
    bool ascending = true,
  }) =>
      switch (colIndex) {
        0 => TouchpointListSorting.byType(ascending: ascending),
        1 => TouchpointListSorting.byTouchpointId(ascending: ascending),
        2 => TouchpointListSorting.byInternalTitle(ascending: ascending),
        3 => TouchpointListSorting.byStatus(ascending: ascending),
        _ => throw ArgumentError.value(
            colIndex, 'colIndex', 'Invalid column index'),
      };
}

@Riverpod(dependencies: [])
class FloorplanViewSortingState extends _$FloorplanViewSortingState {
  @override
  TouchpointListSorting build() {
    return TouchpointListSorting.byTouchpointId();
  }

  void setSorting(TouchpointListSorting sorting) {
    state = sorting;
  }

  void setByColIndex(int columnIndex, {bool ascending = true}) {
    state =
        TouchpointListSorting.fromColIndex(columnIndex, ascending: ascending);
  }
}

@Riverpod(dependencies: [
  touchpointsFiltered,
  FloorplanViewSortingState,
])
List<MTouchpoint> touchpointsSorted(TouchpointsSortedRef ref) {
  final touchpoints = ref.watch(touchpointsFilteredProvider);
  final sorting = ref.watch(floorplanViewSortingStateProvider);
  final sorted = sorting.sortFun(touchpoints);
  if (sorting.ascending) {
    return sorted;
  } else {
    return sorted.reversed.toList();
  }
}
