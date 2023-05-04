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
  final List<MBeacon> beacons;
  final MTouchpoint? selectedTouchpoint;
  final ContentIntent? intent;

  const ContentLoaded({
    required this.touchpoints,
    this.beacons = const [],
    this.selectedTouchpoint,
    this.intent,
  });

  ContentLoaded copyWith({
    List<MTouchpoint>? touchpoints,
    List<MBeacon>? beacons,
    MTouchpoint? selectedTouchpoint,
    ContentIntent? intent,
    bool clearIntent = false,
  }) {
    return ContentLoaded(
      touchpoints: touchpoints ?? this.touchpoints,
      beacons: beacons ?? this.beacons,
      selectedTouchpoint: selectedTouchpoint ?? this.selectedTouchpoint,
      intent: clearIntent ? null : intent ?? this.intent,
    );
  }

  @override
  List<Object?> get props => [touchpoints, beacons, selectedTouchpoint, intent];

  @override
  String toString() => 'ContentLoaded(${touchpoints.length} touchpoints, ${beacons.length} beacons, selectedTouchpoint: ${selectedTouchpoint?.id}), intent: $intent';
}
