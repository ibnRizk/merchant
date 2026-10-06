import 'dart:async';

import 'package:flutter/widgets.dart';

/// Calls [onRefresh] every [interval] while [child] is on screen, and once
/// whenever the app comes back to the foreground.
///
/// "On screen" means the app is resumed, the enclosing tab is the selected
/// one ([Visibility.of], set by [IndexedStack]) and no route covers it
/// ([TickerMode], turned off by the [Navigator] for hidden routes).
class RefreshPoller extends StatefulWidget {
  static const Duration defaultInterval = Duration(seconds: 15);

  final VoidCallback onRefresh;
  final Duration interval;
  final Widget child;

  const RefreshPoller({
    super.key,
    required this.onRefresh,
    this.interval = defaultInterval,
    required this.child,
  });

  @override
  State<RefreshPoller> createState() => _RefreshPollerState();
}

class _RefreshPollerState extends State<RefreshPoller>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _visible = false;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    final AppLifecycleState? lifecycle = WidgetsBinding.instance.lifecycleState;
    _foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _visible = TickerMode.valuesOf(context).enabled && Visibility.of(context);
    _sync();
  }

  @override
  void didUpdateWidget(RefreshPoller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.interval != widget.interval) {
      _stop();
      _sync();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bool resumed = state == AppLifecycleState.resumed;
    if (resumed == _foreground) return;
    _foreground = resumed;
    // Whatever changed while away should show up right away.
    if (resumed && _visible) widget.onRefresh();
    _sync();
  }

  void _sync() {
    final bool active = _visible && _foreground;
    if (!active) return _stop();
    _timer ??= Timer.periodic(widget.interval, (_) => widget.onRefresh());
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
