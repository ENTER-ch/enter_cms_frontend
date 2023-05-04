part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  bool get stringify => true;
}

class MapEventLoad extends MapEvent {
  final int? floorplanId;

  const MapEventLoad({
    this.floorplanId,
  });

  @override
  List<Object?> get props => [floorplanId];
}

class MapEventSelectFloorplan extends MapEvent {
  final MFloorplan floorplan;

  const MapEventSelectFloorplan({required this.floorplan});

  @override
  List<Object> get props => [floorplan];

  @override
  String toString() => 'MapEventSelectFloorplan(${floorplan.id})';
}
