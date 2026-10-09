import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../utils/log_utils.dart';
import '../../utils/values/app_colors.dart';
import 'push_target.dart';

/// The device side of push notifications, as the data layer needs it.
abstract class PushTokenProvider {
  /// Shows the OS prompt (iOS, Android 13+) the first time; a no-op after.
  Future<void> requestPermission();

  /// `null` when push is unavailable (no Firebase config, or iOS without an
  /// APNs token yet — [onTokenRefresh] delivers it later).
  Future<String?> getToken();

  Stream<String> get onTokenRefresh;

  /// Invalidates this device's token, so nothing reaches it after logout
  /// even if the server never heard about it.
  Future<void> deleteToken();
}

/// FCM plus local notifications, covering the three app states:
///
/// - **Foreground**: FCM doesn't display anything, so the message is shown
///   here as a local notification (on iOS too, so both look the same and
///   never show twice).
/// - **Background / terminated**: the OS shows messages that carry a
///   `notification` block; [firebaseMessagingBackgroundHandler] shows
///   data-only ones.
/// - **Taps**: every path ends in [taps] (app alive) or [takeLaunchTarget]
///   (app launched by the tap).
///
/// Without Firebase config (no `google-services.json` /
/// `GoogleService-Info.plist` yet) FCM is skipped and the app runs without
/// push.
class PushNotificationService implements PushTokenProvider {
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    // Also the default FCM channel: see AndroidManifest.xml.
    'ssm_merchant_updates',
    'Orders & updates',
    description: 'New orders, order changes and store messages.',
    importance: Importance.high,
  );

  static const String _androidIcon = '@drawable/ic_stat_notification';

  final bool _firebaseReady;
  final FlutterLocalNotificationsPlugin _local;
  final StreamController<PushTarget> _taps =
      StreamController<PushTarget>.broadcast();
  PushTarget? _launchTarget;
  bool _initialized = false;

  PushNotificationService({
    required bool firebaseReady,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _firebaseReady = firebaseReady,
       _local = localNotifications ?? FlutterLocalNotificationsPlugin();

  /// Call once in `main()` before anything touches FCM. Returns false (and
  /// push stays off) when the Firebase config files are missing.
  static Future<bool> initializeFirebase() async {
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      return true;
    } catch (error) {
      Log.w('Push disabled: Firebase is not configured ($error)');
      return false;
    }
  }

  /// Taps on notifications while the app is running (foreground or
  /// background).
  Stream<PushTarget> get taps => _taps.stream;

  /// The notification that launched the app from terminated, handed out
  /// once.
  PushTarget? takeLaunchTarget() {
    final PushTarget? target = _launchTarget;
    _launchTarget = null;
    return target;
  }

  /// Sets up local notifications and the FCM listeners. Safe to call again.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await _initializeLocal(
        onTap: (NotificationResponse response) {
          final PushTarget? target = _targetOf(response.payload);
          if (target != null) _taps.add(target);
        },
      );
      final NotificationAppLaunchDetails? launch = await _local
          .getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        _launchTarget = _targetOf(launch!.notificationResponse?.payload);
      }
    } catch (error) {
      Log.w('Local notifications unavailable: $error');
    }

    if (!_firebaseReady) return;
    try {
      final FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: true,
        sound: false,
      );
      FirebaseMessaging.onMessage.listen(_show);
      FirebaseMessaging.onMessageOpenedApp.listen(
        (RemoteMessage message) => _taps.add(PushTarget.fromData(message.data)),
      );
      final RemoteMessage? initial = await messaging.getInitialMessage();
      if (initial != null) _launchTarget = PushTarget.fromData(initial.data);
    } catch (error) {
      Log.w('FCM listeners unavailable: $error');
    }
  }

  @override
  Future<void> requestPermission() async {
    if (!_firebaseReady) return;
    await FirebaseMessaging.instance.requestPermission();
  }

  @override
  Future<String?> getToken() async {
    if (!_firebaseReady) return null;
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // FCM can't mint a token until APNs has issued one, which takes a
      // moment on first launch. A late token arrives via onTokenRefresh.
      String? apns = await messaging.getAPNSToken();
      if (apns == null) {
        await Future<void>.delayed(const Duration(seconds: 3));
        apns = await messaging.getAPNSToken();
      }
      if (apns == null) return null;
    }
    return messaging.getToken();
  }

  @override
  Stream<String> get onTokenRefresh => _firebaseReady
      ? FirebaseMessaging.instance.onTokenRefresh
      : const Stream<String>.empty();

  @override
  Future<void> deleteToken() async {
    if (!_firebaseReady) return;
    await FirebaseMessaging.instance.deleteToken();
  }

  Future<void> _initializeLocal({
    DidReceiveNotificationResponseCallback? onTap,
  }) async {
    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_androidIcon),
        // FCM's requestPermission asks; don't prompt a second time here.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: onTap,
    );
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  Future<void> _show(RemoteMessage message) async {
    final String title = _textOf(
      message.notification?.title,
      message.data['title'],
    );
    final String body = _textOf(
      message.notification?.body,
      message.data['body'],
    );
    if (title.isEmpty && body.isEmpty) return;

    await _local.show(
      // Stable per message, so a redelivery replaces rather than stacks.
      id: (message.messageId ?? '${message.sentTime}').hashCode & 0x7fffffff,
      title: title,
      body: body,
      payload: jsonEncode(message.data),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: _androidIcon,
          color: AppColors.light.primary,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  static String _textOf(String? primary, dynamic fallback) {
    final String text = (primary ?? '').trim();
    return text.isNotEmpty ? text : (fallback?.toString().trim() ?? '');
  }

  /// The payload is the FCM `data` block as JSON (see [_show]).
  static PushTarget? _targetOf(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final dynamic data = jsonDecode(payload);
      return data is Map<String, dynamic> ? PushTarget.fromData(data) : null;
    } on FormatException {
      return null;
    }
  }
}

/// Runs in a background isolate when a message arrives while the app is in
/// the background or terminated. Must stay top-level.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // The OS already displays messages that carry a `notification` block.
  if (message.notification != null) return;

  await Firebase.initializeApp();
  final PushNotificationService service = PushNotificationService(
    firebaseReady: true,
  );
  await service._initializeLocal();
  await service._show(message);
}
