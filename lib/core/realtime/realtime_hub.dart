import 'dart:async';

import 'realtime_event.dart';

/// App-wide fan-out of realtime events. The realtime repository publishes
/// here; any screen listens (see `RealtimeListener`) and refreshes its own
/// cubit, so cubits scoped to a route never need to know about the socket.
class RealtimeHub {
  final StreamController<RealtimeEvent> _controller =
      StreamController<RealtimeEvent>.broadcast();

  Stream<RealtimeEvent> get events => _controller.stream;

  void publish(RealtimeEvent event) {
    if (!_controller.isClosed) _controller.add(event);
  }
}
