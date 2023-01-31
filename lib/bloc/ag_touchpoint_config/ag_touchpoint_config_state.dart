part of 'ag_touchpoint_config_bloc.dart';

abstract class AGTouchpointConfigState extends Equatable {
  const AGTouchpointConfigState();

  @override
  bool get stringify => true;
}

class AGTouchpointConfigInitial extends AGTouchpointConfigState {
  @override
  List<Object> get props => [];
}

class AGTouchpointConfigLoading extends AGTouchpointConfigState {
  @override
  List<Object> get props => [];
}

class AGTouchpointConfigLoaded extends AGTouchpointConfigState {
  final MAGTouchpointConfig config;

  const AGTouchpointConfigLoaded({
    required this.config,
  });

  @override
  List<Object> get props => [config];

  @override
  String toString() => 'AGTouchpointConfigLoaded(${config.touchpointId})';
}