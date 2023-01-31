part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  bool get stringify => true;
}

class MapEventLoad extends MapEvent {
  const MapEventLoad();

  @override
  List<Object> get props => [];
}

class MapEventSelectFloorplan extends MapEvent {
  final MFloorplan floorplan;

  const MapEventSelectFloorplan({required this.floorplan});

  @override
  List<Object> get props => [floorplan];

  @override
  String toString() => 'MapEventSelectFloorplan(${floorplan.id})';
}
