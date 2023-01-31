part of 'ag_content_preview_bloc.dart';

abstract class AgContentPreviewEvent extends Equatable {
  const AgContentPreviewEvent();

  @override
  bool get stringify => true;
}

class AgContentPreviewEventLoad extends AgContentPreviewEvent {
  const AgContentPreviewEventLoad();

  @override
  List<Object> get props => [];
}