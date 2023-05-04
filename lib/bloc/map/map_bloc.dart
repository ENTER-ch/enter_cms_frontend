import 'package:bloc/bloc.dart';
import 'package:enter_cms_flutter/api/cms_api.dart';
import 'package:enter_cms_flutter/models/floorplan.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';

part 'map_event.dart';

part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final CmsApi cmsApi;

  MapBloc({
    required this.cmsApi,
  }) : super(MapInitial()) {
    on<MapEventLoad>(_onLoad);
    on<MapEventSelectFloorplan>(_onSelectFloorplan);
  }

  void _onLoad(MapEventLoad event, Emitter<MapState> emit) async {
    // If there is a selected floorplan, we memorize it so we can reselect it
    int? selectedFloorplanId = event.floorplanId;
    if (state is MapLoaded) {
      selectedFloorplanId = (state as MapLoaded).selectedFloorplan?.id;
    }

    emit(MapLoading());

    final floorplans = await cmsApi.getFloorplans();

    MFloorplan? selectedFloorplan;
    if (selectedFloorplanId != null) {
      // Try to reselect the previously selected floorplan
      selectedFloorplan = floorplans
          .firstWhereOrNull((floorplan) => floorplan.id == selectedFloorplanId);
    }
    if (selectedFloorplan == null && floorplans.isNotEmpty) {
      // If we couldn't reselect the previously selected floorplan, select the first floorplan
      selectedFloorplan = floorplans.first;
    }

    emit(MapLoaded(
      floorplans: floorplans,
      selectedFloorplan: selectedFloorplan,
    ));
  }

  void _onSelectFloorplan(
      MapEventSelectFloorplan event, Emitter<MapState> emit) {
    if (state is MapLoaded) {
      final MapLoaded mapLoaded = state as MapLoaded;
      emit(MapLoaded(
        floorplans: mapLoaded.floorplans,
        selectedFloorplan: event.floorplan,
      ));
    }
  }
}
