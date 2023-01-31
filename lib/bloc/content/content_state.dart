part of 'content_bloc.dart';

abstract class ContentState extends Equatable {
  const ContentState();

  @override
  bool get stringify => true;
}

class ContentInitial extends ContentState {
  @override
  List<Object> get props => [];
}

class ContentLoading extends ContentState {
  @override
  List<Object> get props => [];
}

class ContentLoaded extends ContentState {
  final List<MTouchpoint> touchpoints;
  final MTouchpoint? selectedTouchpoint;

  const ContentLoaded({
    required this.touchpoints,
    this.selectedTouchpoint,
  });

  ContentLoaded copyWith({
    List<MTouchpoint>? touchpoints,
    MTouchpoint? selectedTouchpoint,
  }) {
    return ContentLoaded(
      touchpoints: touchpoints ?? this.touchpoints,
      selectedTouchpoint: selectedTouchpoint ?? this.selectedTouchpoint,
    );
  }

  @override
  List<Object?> get props => [touchpoints, selectedTouchpoint];

  @override
  String toString() => 'ContentLoaded(${touchpoints.length} touchpoints, selectedTouchpoint: ${selectedTouchpoint?.id})';
}
