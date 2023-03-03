part of 'ag_touchpoint_config_bloc.dart';

abstract class AGTouchpointConfigEvent extends Equatable {
  const AGTouchpointConfigEvent();

  @override
  bool get stringify => true;
}

class AGTouchpointConfigEventInit extends AGTouchpointConfigEvent {
  const AGTouchpointConfigEventInit();

  @override
  List<Object> get props => [];
}

class AGTouchpointConfigEventUpdateConfig extends AGTouchpointConfigEvent {
  final MAGTouchpointConfig config;

  const AGTouchpointConfigEventUpdateConfig({
    required this.config,
  });

  @override
  List<Object> get props => [config];
}

class AGTouchpointConfigEventUpdateContent extends AGTouchpointConfigEvent {
  final MAGContent content;

  const AGTouchpointConfigEventUpdateContent({
    required this.content,
  });

  @override
  List<Object> get props => [content];
}