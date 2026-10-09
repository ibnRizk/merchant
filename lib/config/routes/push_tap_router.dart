import 'dart:async';

import '../../core/services/push/push_notification_service.dart';
import '../../core/services/push/push_target.dart';
import 'app_routes.dart';

/// Opens the screen a tapped push notification points to.
///
/// A tap can come before there is anywhere to go: the app launched from
/// terminated is still on the splash, or the merchant is signed out. Such
/// a tap waits until home is on screen ([onHomeShown]), so the opened
/// screen also has home to go back to.
class PushTapRouter {
  final PushNotificationService _push;
  StreamSubscription<PushTarget>? _taps;
  PushTarget? _pending;
  bool _homeShown = false;

  PushTapRouter({required PushNotificationService push}) : _push = push;

  /// Call once at app start.
  void attach() {
    _taps ??= _push.taps.listen(_onTap);
    _pending ??= _push.takeLaunchTarget();
  }

  void onHomeShown() {
    _homeShown = true;
    final PushTarget? target = _pending;
    _pending = null;
    if (target != null) _open(target);
  }

  /// Home left the stack: the session ended. A tap from the old session
  /// must not open after the next login.
  void onHomeHidden() {
    _homeShown = false;
    _pending = null;
  }

  void _onTap(PushTarget target) {
    if (_homeShown) {
      _open(target);
    } else {
      _pending = target;
    }
  }

  void _open(PushTarget target) => switch (target) {
    OrderPushTarget(:final int orderId) => AppRoutes.router.pushNamed(
      AppRoutes.orderDetailsName,
      pathParameters: <String, String>{'id': '$orderId'},
    ),
    InboxPushTarget() => AppRoutes.router.pushNamed(
      AppRoutes.notificationsName,
    ),
  };

  Future<void> dispose() async {
    await _taps?.cancel();
    _taps = null;
  }
}
