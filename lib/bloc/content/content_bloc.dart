import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:enter_cms_flutter/api/cms_api.dart';
import 'package:enter_cms_flutter/api/content_api.dart';
import 'package:enter_cms_flutter/models/beacon.dart';
import 'package:enter_cms_flutter/models/position.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:equatable/equatable.dart';

part 'content_event.dart';

part 'content_state.dart';

class ContentBloc extends Bloc<ContentEvent, ContentState> {
  final CmsApi cmsApi;

  ContentBloc({
    required this.cmsApi,
  }) : super(ContentInitial()) {
    on<ContentEventLoad>(_onLoad);
    on<ContentEventSelectTouchpoint>(_onSelectTouchpoint);
    on<ContentEventCreateTouchpoint>(_onCreateTouchpoint);
    on<ContentEventPlaceTouchpoint>(_onPlaceTouchpoint);
    on<ContentEventUpdateTouchpoint>(_onUpdateTouchpoint);
  }

  void _onLoad(ContentEventLoad event, Emitter<ContentState> emit) async {
    emit(ContentLoading());

    final floorplanView = await cmsApi.getFloorplanView(event.floorplanId);
    final touchpoints = floorplanView.touchpoints;

    emit(ContentLoaded(
      touchpoints: touchpoints,
      beacons: floorplanView.beacons,
    ));

    if (touchpoints.isNotEmpty) {
      final touchpoint = touchpoints.firstWhere(
        (e) => e.id == event.touchpointId,
        orElse: () => touchpoints.first,
      );
      add(ContentEventSelectTouchpoint(touchpoint: touchpoint));
    }
  }

  void _onSelectTouchpoint(
      ContentEventSelectTouchpoint event, Emitter<ContentState> emit) {
    if (state is ContentLoaded) {
      final ContentLoaded contentLoaded = state as ContentLoaded;
      emit(contentLoaded.copyWith(
        selectedTouchpoint: event.touchpoint,
      ));
    }
  }

  void _onCreateTouchpoint(
      ContentEventCreateTouchpoint event, Emitter<ContentState> emit) async {
    if (state is ContentLoaded) {
      final contentLoaded = state as ContentLoaded;

      final touchpoint = await cmsApi.createTouchpoint(event.type);

      final touchpoints = contentLoaded.touchpoints + [touchpoint];
      emit(contentLoaded.copyWith(
        intent: ContentIntent.placeTouchpoint,
        touchpoints: touchpoints,
        selectedTouchpoint: touchpoint,
      ));
    }
  }

  void _onPlaceTouchpoint(
      ContentEventPlaceTouchpoint event, Emitter<ContentState> emit) async {
    if (state is ContentLoaded) {
      final contentLoaded = state as ContentLoaded;
      emit(contentLoaded.copyWith(
        clearIntent: true,
      ));

      add(ContentEventUpdateTouchpoint(
        touchpoint: event.touchpoint.copyWith(
          position: event.position,
        ),
      ));
    }
  }

  void _onUpdateTouchpoint(
      ContentEventUpdateTouchpoint event, Emitter<ContentState> emit) async {
    if (state is ContentLoaded) {
      final contentLoaded = state as ContentLoaded;

      final updated = event.internal ? event.touchpoint : await cmsApi.updateTouchpoint(
        event.touchpoint.id!,
        touchpointId: event.touchpoint.touchpointId,
        position: event.touchpoint.position,
      );

      final touchpoints = contentLoaded.touchpoints
          .map((e) => e.id == updated.id ? updated : e)
          .toList();

      emit(contentLoaded.copyWith(
        touchpoints: touchpoints,
        selectedTouchpoint: touchpoints.firstWhere((e) => e.id == updated.id),
      ));
    }
  }
}
