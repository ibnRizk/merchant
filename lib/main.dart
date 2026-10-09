import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'config/env/app_env.dart';
import 'core/services/bloc_observer/bloc_observer.dart';
import 'core/services/push/push_notification_service.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Environment first — DioConsumer reads AppEnv.baseUrl in its constructor.
  await AppEnv.load();

  // 2. Firebase, before anything resolves the push service. Without the
  //    platform config files the app runs, just without push.
  await PushNotificationService.initializeFirebase();

  // 3. Dependency injection.
  await ServiceLocator.init();

  // Before the first frame: picks up the notification that launched the
  // app, and must listen before any foreground message can arrive.
  await ServiceLocator.instance<PushNotificationService>().initialize();

  // 4. System chrome.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light, // iOS
      statusBarIconBrightness: Brightness.dark, // Android
    ),
  );
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 5. Bloc logging.
  Bloc.observer = AppBlocObserver();

  runApp(const App());
}
