import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:enter_cms_flutter/api/content_api.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:equatable/equatable.dart';

part 'content_event.dart';
part 'content_state.dart';

class ContentBloc extends Bloc<ContentEvent, ContentState> {
  final ContentApi contentApi;

  ContentBloc({
    required this.contentApi,
  }) : super(ContentInitial()) {
    on<ContentEventLoad>(_onLoad);
    on<ContentEventSelectTouchpoint>(_onSelectTouchpoint);
    on<ContentEventCreateTouchpoint>(_onCreateTouchpoint);
    on<ContentEventUpdateTouchpoint>(_onUpdateTouchpoint);
  }

  void _onLoad(ContentEventLoad event, Emitter<ContentState> emit) async {
    emit(ContentLoading());

    final touchpoints = await contentApi.getTouchpointsOfFloorplan(floorplanId: event.floorplanId);

    emit(ContentLoaded(touchpoints: touchpoints));
    if (touchpoints.isNotEmpty) add(ContentEventSelectTouchpoint(touchpoint: touchpoints.first));
  }

  void _onSelectTouchpoint(ContentEventSelectTouchpoint event, Emitter<ContentState> emit) {
    if (state is ContentLoaded) {
      final ContentLoaded contentLoaded = state as ContentLoaded;
      emit(ContentLoaded(
        touchpoints: contentLoaded.touchpoints,
        selectedTouchpoint: event.touchpoint,
      ));
    }
  }

  void _onCreateTouchpoint(ContentEventCreateTouchpoint event, Emitter<ContentState> emit) async {
    if (state is ContentLoaded) {
      final contentLoaded = state as ContentLoaded;

      final touchpoint = await contentApi.createTouchpoint(MTouchpoint(
        type: event.type,
      ));

      final touchpoints = contentLoaded.touchpoints + [touchpoint];
      emit(contentLoaded.copyWith(
        touchpoints: touchpoints,
        selectedTouchpoint: touchpoint,
      ));
    }
  }

  void _onUpdateTouchpoint(ContentEventUpdateTouchpoint event, Emitter<ContentState> emit) async {
    if (state is ContentLoaded) {
      final contentLoaded = state as ContentLoaded;
      final touchpoints = contentLoaded.touchpoints.map((e) => e.id == event.touchpoint.id ? event.touchpoint : e).toList();
      emit(contentLoaded.copyWith(
        touchpoints: touchpoints,
        selectedTouchpoint: touchpoints.firstWhere((e) => e.id == event.touchpoint.id),
      ));
    }
  }
}
