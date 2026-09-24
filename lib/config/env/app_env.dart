import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Typed access to the values in `.env`.
///
/// Call [load] once in `main()`, *before* [ServiceLocator.init] — the Dio
/// client reads [baseUrl] in its constructor.
///
/// For flavors, ship `.env.staging` / `.env.production` alongside `.env`,
/// declare them under `flutter: assets:` in pubspec.yaml, and select one with
/// `flutter run --dart-define=ENV_FILE=.env.production`.
abstract class AppEnv {
  static Future<void> load() async {
    const String fileName = String.fromEnvironment(
      'ENV_FILE',
      defaultValue: '.env',
    );
    await dotenv.load(fileName: fileName);
  }

  static String get appName => dotenv.get('APP_NAME', fallback: 'Flutter Base');

  static String get baseUrl => dotenv.get('BASE_URL', fallback: '');

  static bool get enableNetworkLogs =>
      dotenv.get('ENABLE_NETWORK_LOGS', fallback: 'false').toLowerCase() ==
      'true';

  /// Prefilled on the registration form. There is no API to list zones or
  /// modules, so these come from config.
  static int? get defaultZoneId =>
      int.tryParse(dotenv.get('DEFAULT_ZONE_ID', fallback: ''));

  static int? get defaultModuleId =>
      int.tryParse(dotenv.get('DEFAULT_MODULE_ID', fallback: ''));

  static Duration get connectTimeout => _duration('CONNECT_TIMEOUT_MS', 30000);

  static Duration get receiveTimeout => _duration('RECEIVE_TIMEOUT_MS', 30000);

  static Duration _duration(String key, int fallbackMs) => Duration(
    milliseconds: int.tryParse(dotenv.get(key, fallback: '')) ?? fallbackMs,
  );
}
