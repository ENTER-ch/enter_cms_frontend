part of 'map_bloc.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  bool get stringify => true;
}

class MapInitial extends MapState {
  @override
  List<Object> get props => [];
}

class MapLoading extends MapState {
  @override
  List<Object> get props => [];
}

class MapLoaded extends MapState {
  final List<MFloorplan> floorplans;
  final MFloorplan? selectedFloorplan;

  const MapLoaded({
    required this.floorplans,
    this.selectedFloorplan,
  });

  @override
  List<Object?> get props => [floorplans, selectedFloorplan];

  @override
  String toString() => 'MapLoaded(${floorplans.length} floorplans, selectedFloorplan: ${selectedFloorplan?.id})';
}