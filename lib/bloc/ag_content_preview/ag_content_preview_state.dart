part of 'ag_content_preview_bloc.dart';

abstract class AgContentPreviewState extends Equatable {
  const AgContentPreviewState();

  @override
  bool get stringify => true;
}

class AgContentPreviewInitial extends AgContentPreviewState {
  @override
  List<Object> get props => [];
}

class AgContentPreviewLoading extends AgContentPreviewState {
  @override
  List<Object> get props => [];
}

class AgContentPreviewLoaded extends AgContentPreviewState {
  final Map<int, ui.Image> assets;

  const AgContentPreviewLoaded({
    required this.assets,
  });

  @override
  List<Object> get props => [assets];

  @override
  String toString() {
    return 'AgContentPreviewLoaded{${assets.length} assets}';
  }
}