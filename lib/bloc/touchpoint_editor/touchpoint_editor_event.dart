part of 'touchpoint_editor_bloc.dart';

abstract class TouchpointEditorEvent extends Equatable {
  const TouchpointEditorEvent();
}

class TouchpointEditorEventReset extends TouchpointEditorEvent {
  const TouchpointEditorEventReset();

  @override
  List<Object> get props => [];
}

class TouchpointEditorEventLoad extends TouchpointEditorEvent {
  final int touchpointId;
  final bool silent;

  const TouchpointEditorEventLoad({
    required this.touchpointId,
    this.silent = false,
  });

  @override
  List<Object> get props => [touchpointId, silent];
}

class TouchpointEditorEventUpdateTouchpoint extends TouchpointEditorEvent {
  final MTouchpoint touchpoint;

  const TouchpointEditorEventUpdateTouchpoint({
    required this.touchpoint,
  });

  @override
  List<Object> get props => [touchpoint];
}

class TouchpointEditorEventUpdateId extends TouchpointEditorEvent {
  final String id;

  const TouchpointEditorEventUpdateId({
    required this.id,
  });

  @override
  List<Object> get props => [id];
}

class TouchpointEditorEventUpdateTitle extends TouchpointEditorEvent {
  final String title;

  const TouchpointEditorEventUpdateTitle({
    required this.title,
  });

  @override
  List<Object> get props => [title];
}

class TouchpointEditorEventUpdateStatus extends TouchpointEditorEvent {
  final TouchpointStatus status;

  const TouchpointEditorEventUpdateStatus({
    required this.status,
  });

  @override
  List<Object> get props => [status];
}

class TouchpointEditorEventUpdateAGTouchpointConfig extends TouchpointEditorEvent {
  final AGPlaybackMode? playbackMode;

  const TouchpointEditorEventUpdateAGTouchpointConfig({
    required this.playbackMode,
  });

  @override
  List<Object?> get props => [playbackMode];
}

class TouchpointEditorEventUpdateAGContent extends TouchpointEditorEvent {
  final int id;

  final String? label;
  final String? language;
  final int? mediaTrackId;

  const TouchpointEditorEventUpdateAGContent(this.id, {
    this.label,
    this.language,
    this.mediaTrackId,
  });

  @override
  List<Object?> get props => [id, label, language, mediaTrackId];
}