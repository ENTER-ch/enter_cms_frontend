part of 'content_bloc.dart';

enum ContentIntent {
  placeTouchpoint,
}

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
  final ContentIntent? intent;

  const ContentLoaded({
    required this.touchpoints,
    this.selectedTouchpoint,
    this.intent,
  });

  ContentLoaded copyWith({
    List<MTouchpoint>? touchpoints,
    MTouchpoint? selectedTouchpoint,
    ContentIntent? intent,
    bool clearIntent = false,
  }) {
    return ContentLoaded(
      touchpoints: touchpoints ?? this.touchpoints,
      selectedTouchpoint: selectedTouchpoint ?? this.selectedTouchpoint,
      intent: clearIntent ? null : intent ?? this.intent,
    );
  }

  @override
  List<Object?> get props => [touchpoints, selectedTouchpoint, intent];

  @override
  String toString() => 'ContentLoaded(${touchpoints.length} touchpoints, selectedTouchpoint: ${selectedTouchpoint?.id}), intent: $intent';
}
