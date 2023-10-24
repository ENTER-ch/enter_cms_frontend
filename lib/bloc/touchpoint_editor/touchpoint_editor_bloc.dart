import 'package:bloc/bloc.dart';
import 'package:enter_cms_flutter/api/cms_api.dart';
import 'package:enter_cms_flutter/api/rest/rest_api.dart';
import 'package:enter_cms_flutter/models/ag_touchpoint_config.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';

part 'touchpoint_editor_event.dart';
part 'touchpoint_editor_state.dart';

class TouchpointEditorBloc
    extends Bloc<TouchpointEditorEvent, TouchpointEditorState> {
  final log = Logger('TouchpointEditorBloc');
  final CmsApi cmsApi;

  TouchpointEditorBloc({
    required this.cmsApi,
  }) : super(TouchpointEditorInitial()) {
    on<TouchpointEditorEventReset>((event, emit) async {
      emit(TouchpointEditorInitial());
    });

    on<TouchpointEditorEventLoad>((event, emit) async {
      if (!event.silent) emit(TouchpointEditorLoading());
      try {
        final touchpoint = await cmsApi.getTouchpoint(event.touchpointId);
        emit(TouchpointEditorLoaded(touchpoint: touchpoint));
      } catch (e) {
        log.severe(e);
        emit(TouchpointEditorError(message: e.toString()));
      }
    });

    on<TouchpointEditorEventUpdateId>((event, emit) async {
      if (state is TouchpointEditorLoaded) {
        final loadedState = state as TouchpointEditorLoaded;
        final updatedTouchpoint = loadedState.touchpoint.copyWith(
          touchpointId: int.parse(event.id),
        );

        emit(loadedState.copyWith(
          touchpoint: updatedTouchpoint,
          idLoading: true,
          clearError: true,
        ));

        try {
          final result = await cmsApi.updateTouchpoint(
              loadedState.touchpoint.id!,
              touchpointId: int.parse(event.id));
          emit(TouchpointEditorLoaded(
            touchpoint: result,
            idLoading: false,
          ));
        } catch (e) {
          log.severe(e);
          String message = e.toString();
          if (e is ApiErrorBadRequest) {
            message = e.data?.values.map((e) => e.join(', ')).join(', ') ??
                e.toString();
          }
          emit(loadedState.copyWith(
            idLoading: false,
            idError: message,
          ));
        }
      }
    });

    on<TouchpointEditorEventUpdateTitle>((event, emit) async {
      if (state is TouchpointEditorLoaded) {
        final loadedState = state as TouchpointEditorLoaded;
        final updatedTouchpoint = loadedState.touchpoint.copyWith(
          internalTitle: event.title,
        );

        emit(loadedState.copyWith(
          touchpoint: updatedTouchpoint,
          titleLoading: true,
          clearError: true,
        ));

        try {
          final result = await cmsApi.updateTouchpoint(
              loadedState.touchpoint.id!,
              internalTitle: event.title);
          emit(TouchpointEditorLoaded(
            touchpoint: result,
            titleLoading: false,
          ));
        } catch (e) {
          log.severe(e);
          emit(loadedState.copyWith(
            titleLoading: false,
            titleError: e.toString(),
          ));
        }
      }
    });

    on<TouchpointEditorEventUpdateStatus>((event, emit) async {
      if (state is TouchpointEditorLoaded) {
        final loadedState = state as TouchpointEditorLoaded;
        final updatedTouchpoint = loadedState.touchpoint.copyWith(
          status: event.status,
        );

        emit(loadedState.copyWith(
          touchpoint: updatedTouchpoint,
          statusLoading: true,
          clearError: true,
        ));

        try {
          final result = await cmsApi.updateTouchpoint(
            loadedState.touchpoint.id!,
            status: event.status,
          );
          emit(TouchpointEditorLoaded(
            touchpoint: result,
            statusLoading: false,
          ));
        } catch (e) {
          log.severe(e);
          emit(loadedState.copyWith(
            statusLoading: false,
            statusError: e.toString(),
          ));
        }
      }
    });

    // on<TouchpointEditorEventUpdateAGTouchpointConfig>((event, emit) async {
    //   if (state is TouchpointEditorLoaded) {
    //     final loadedState = state as TouchpointEditorLoaded;
    //     final updatedTouchpoint = loadedState.touchpoint.copyWith(
    //       agConfig: loadedState.touchpoint.agConfig?.copyWith(),
    //     );

    //     emit(loadedState.copyWith(
    //       touchpoint: updatedTouchpoint,
    //       configLoading: true,
    //       clearError: true,
    //     ));

    //     try {
    //       final result = await cmsApi.updateAGTouchpointConfig(
    //         loadedState.touchpoint.agConfig!.id!,
    //         playbackMode: event.playbackMode,
    //       );
    //       emit(TouchpointEditorLoaded(
    //         touchpoint: result,
    //         configLoading: false,
    //       ));
    //     } catch (e) {
    //       log.severe(e);
    //       emit(loadedState.copyWith(
    //         configLoading: false,
    //         configError: e.toString(),
    //       ));
    //     }
    //   }
    // });

    on<TouchpointEditorEventUpdateAGContent>((event, emit) async {
      if (state is TouchpointEditorLoaded) {
        final loadedState = state as TouchpointEditorLoaded;

        final content = loadedState.touchpoint.agConfig!.contents
            .firstWhere((element) => element.id == event.id);
        final updatedContent = content.copyWith(
          label: event.label ?? content.label,
          language: event.language ?? content.language,
          mediaTrackId: event.mediaTrackId ?? content.mediaTrackId,
        );

        final updatedTouchpoint =
            loadedState.touchpoint.replaceContent(updatedContent);

        emit(loadedState.copyWith(
          touchpoint: updatedTouchpoint,
          clearError: true,
        ));

        try {
          final result = await cmsApi.updateAGContent(
            event.id,
            label: event.label,
            language: event.language,
            mediaTrackId: event.mediaTrackId,
          );

          emit(TouchpointEditorLoaded(
            touchpoint: loadedState.touchpoint.replaceContent(result),
          ));

          if (result.dirty == true) {
            add(TouchpointEditorEventLoad(
              touchpointId: loadedState.touchpoint.id!,
              silent: true,
            ));
          }
        } catch (e) {
          log.severe(e);
          emit(loadedState.copyWith());
        }
      }
    });
  }
}
