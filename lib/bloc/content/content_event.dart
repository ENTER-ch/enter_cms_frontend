part of 'content_bloc.dart';

abstract class ContentEvent extends Equatable {
  const ContentEvent();

  @override
  bool get stringify => true;
}

class ContentEventLoad extends ContentEvent {
  const ContentEventLoad({
    required this.floorplanId,
  });

  final int floorplanId;

  @override
  List<Object> get props => [floorplanId];
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

class ContentEventUpdateTouchpoint extends ContentEvent {
  const ContentEventUpdateTouchpoint({
    required this.touchpoint,
  });

  final MTouchpoint touchpoint;

  @override
  List<Object> get props => [touchpoint];

  @override
  String toString() => 'ContentEventUpdateTouchpoint(${touchpoint.id})';
}