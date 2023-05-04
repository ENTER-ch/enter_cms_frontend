part of 'touchpoint_editor_bloc.dart';

abstract class TouchpointEditorState extends Equatable {
  const TouchpointEditorState();
}

class TouchpointEditorInitial extends TouchpointEditorState {
  @override
  List<Object> get props => [];
}

class TouchpointEditorLoading extends TouchpointEditorState {
  @override
  List<Object> get props => [];
}

class TouchpointEditorLoaded extends TouchpointEditorState {
  final MTouchpoint touchpoint;

  final bool idLoading;
  final String? idError;
  final bool titleLoading;
  final String? titleError;
  final bool statusLoading;
  final String? statusError;

  final bool configLoading;
  final String? configError;

  const TouchpointEditorLoaded({
    required this.touchpoint,
    this.idLoading = false,
    this.idError,
    this.titleLoading = false,
    this.titleError,
    this.statusLoading = false,
    this.statusError,
    this.configLoading = false,
    this.configError,
  });

  TouchpointEditorLoaded copyWith({
    MTouchpoint? touchpoint,
    bool? idLoading,
    String? idError,
    bool? titleLoading,
    String? titleError,
    bool? statusLoading,
    String? statusError,
    bool? configLoading,
    String? configError,
    bool clearError = false,
  }) {
    return TouchpointEditorLoaded(
      touchpoint: touchpoint ?? this.touchpoint,
      idLoading: idLoading ?? this.idLoading,
      idError: clearError ? null : idError ?? this.idError,
      titleLoading: titleLoading ?? this.titleLoading,
      titleError: clearError ? null : titleError ?? this.titleError,
      statusLoading: statusLoading ?? this.statusLoading,
      statusError: clearError ? null : statusError ?? this.statusError,
      configLoading: configLoading ?? this.configLoading,
      configError: clearError ? null : configError ?? this.configError,
    );
  }

  @override
  List<Object?> get props => [touchpoint, idLoading, idError, titleLoading, titleError, configLoading, configError];
}

class TouchpointEditorError extends TouchpointEditorState {
  final String message;

  const TouchpointEditorError({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}