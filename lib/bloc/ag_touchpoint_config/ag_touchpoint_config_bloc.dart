import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:enter_cms_flutter/api/content_api.dart';
import 'package:enter_cms_flutter/models/ag_content.dart';
import 'package:enter_cms_flutter/models/ag_touchpoint_config.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:equatable/equatable.dart';

part 'ag_touchpoint_config_event.dart';
part 'ag_touchpoint_config_state.dart';

class AGTouchpointConfigBloc extends Bloc<AGTouchpointConfigEvent, AGTouchpointConfigState> {
  final ContentApi contentApi;
  final MTouchpoint touchpoint;

  AGTouchpointConfigBloc({
    required this.contentApi,
    required this.touchpoint,
  }) : super(AGTouchpointConfigInitial()) {
    on<AGTouchpointConfigEventInit>(_onInit);
    on<AGTouchpointConfigEventUpdateConfig>(_onUpdateConfig);
    on<AGTouchpointConfigEventUpdateContent>(_onUpdateContent);
  }

  void _onInit(AGTouchpointConfigEventInit event, Emitter<AGTouchpointConfigState> emit) async {
    emit(AGTouchpointConfigLoading());

    try {
      final config = await contentApi.getAGTouchpointConfigForTouchpoint(touchpointId: touchpoint.id!);
      emit(AGTouchpointConfigLoaded(config: config));
    } catch (e) {
      const config = MAGTouchpointConfig();
      emit(const AGTouchpointConfigLoaded(config: config));
    }
  }

  void _onUpdateConfig(AGTouchpointConfigEventUpdateConfig event, Emitter<AGTouchpointConfigState> emit) async {
    if (state is AGTouchpointConfigLoaded) {
      final result = await contentApi.updateAGTouchpointConfig(event.config);
      emit(AGTouchpointConfigLoaded(config: result));
    }
  }

  void _onUpdateContent(AGTouchpointConfigEventUpdateContent event, Emitter<AGTouchpointConfigState> emit) async {
    if (state is AGTouchpointConfigLoaded) {
      final config = (state as AGTouchpointConfigLoaded).config;

      final content = await contentApi.updateAGContent(event.content);
      final updatedConfig = config.copyWith(contents: config.contents.map((c) => c.id == content.id ? content : c).toList());
      emit(AGTouchpointConfigLoaded(config: updatedConfig));
    }
  }
}
