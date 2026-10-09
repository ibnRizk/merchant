/// Which live channels are up for this session. Nothing renders from it
/// today; it makes the session's state observable and testable.
final class LiveUpdatesState {
  final bool started;
  final bool pushRegistered;
  final bool realtimeConnected;

  const LiveUpdatesState({
    this.started = false,
    this.pushRegistered = false,
    this.realtimeConnected = false,
  });

  LiveUpdatesState copyWith({
    bool? started,
    bool? pushRegistered,
    bool? realtimeConnected,
  }) => LiveUpdatesState(
    started: started ?? this.started,
    pushRegistered: pushRegistered ?? this.pushRegistered,
    realtimeConnected: realtimeConnected ?? this.realtimeConnected,
  );
}
