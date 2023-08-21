part of 'content_bloc.dart';

abstract class ContentEvent extends Equatable {
  const ContentEvent();

  @override
  bool get stringify => true;
}

class ContentEventLoad extends ContentEvent {
  const ContentEventLoad({
    required this.floorplanId,
    this.touchpointId,
  });

  final int floorplanId;
  final int? touchpointId;

  @override
  List<Object?> get props => [floorplanId, touchpointId];
}

class ContentEventSelectTouchpoint extends ContentEvent {
  const ContentEventSelectTouchpoint({
    this.touchpoint,
  });

  final MTouchpoint? touchpoint;

  @override
  List<Object?> get props => [touchpoint];

  @override
  String toString() => 'ContentEventSelectTouchpoint(${touchpoint?.id})';
}

class ContentEventCreateTouchpoint extends ContentEvent {
  const ContentEventCreateTouchpoint({
    required this.type,
  });

  final TouchpointType type;

  @override
  List<Object> get props => [type];

  @override
  String toString() => 'ContentEventCreateTouchpoint($type)';
}

class ContentEventPlaceTouchpoint extends ContentEvent {
  const ContentEventPlaceTouchpoint({
    required this.touchpoint,
    required this.position,
  });

  final MTouchpoint touchpoint;
  final MPosition position;

  @override
  List<Object> get props => [touchpoint, position];

  @override
  String toString() =>
      'ContentEventPlaceTouchpoint(${touchpoint.id}, $position)';
}

class ContentEventUpdateTouchpoint extends ContentEvent {
  const ContentEventUpdateTouchpoint({
    required this.touchpoint,
    this.internal = false,
  });

  final MTouchpoint touchpoint;
  final bool internal;

  @override
  List<Object> get props => [touchpoint, internal];

  @override
  String toString() =>
      'ContentEventUpdateTouchpoint(${touchpoint.id}, INTERNAL: $internal)';
}

class ContentEventCancelIntent extends ContentEvent {
  const ContentEventCancelIntent();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'ContentEventCancelIntent()';
}
