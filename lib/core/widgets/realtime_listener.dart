import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../injection_container.dart';
import '../realtime/realtime_event.dart';
import '../realtime/realtime_hub.dart';

/// Calls [onEvent] when a realtime event that passes [when] arrives, for as
/// long as [child] is mounted. The realtime counterpart of `RefreshPoller`.
///
/// Events often come in bursts (a status change, then the driver assigned),
/// so calls are coalesced: [onEvent] runs once, [debounce] after the last
/// matching event.
class RealtimeListener extends StatefulWidget {
  static const Duration defaultDebounce = Duration(milliseconds: 400);

  final bool Function(RealtimeEvent event) when;
  final VoidCallback onEvent;
  final Duration debounce;
  final Widget child;

  /// Defaults to the app's [RealtimeHub]; tests pass their own.
  final Stream<RealtimeEvent>? events;

  const RealtimeListener({
    super.key,
    required this.when,
    required this.onEvent,
    this.debounce = defaultDebounce,
    this.events,
    required this.child,
  });

  @override
  State<RealtimeListener> createState() => _RealtimeListenerState();
}

class _RealtimeListenerState extends State<RealtimeListener> {
  StreamSubscription<RealtimeEvent>? _subscription;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(RealtimeListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.events != widget.events) {
      _subscription?.cancel();
      _subscribe();
    }
  }

  void _subscribe() {
    final Stream<RealtimeEvent> events =
        widget.events ?? ServiceLocator.instance<RealtimeHub>().events;
    _subscription = events.listen((RealtimeEvent event) {
      if (!widget.when(event)) return;
      _debounce?.cancel();
      _debounce = Timer(widget.debounce, () {
        if (mounted) widget.onEvent();
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
