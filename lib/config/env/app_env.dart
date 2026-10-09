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

  static String get appName => dotenv.get('APP_NAME', fallback: 'SSM Merchant');

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

  // --- Realtime (Pusher protocol) ---
  // The app key is public by design (it ships in every Pusher client); the
  // secret stays on the server. Leave PUSHER_APP_KEY empty to run without
  // realtime: screens then rely on polling alone.

  static String get pusherAppKey => dotenv.get('PUSHER_APP_KEY', fallback: '');

  /// Pusher Channels cluster, e.g. `eu`. Ignored when [pusherHost] is set.
  static String get pusherCluster =>
      dotenv.get('PUSHER_APP_CLUSTER', fallback: '');

  /// Self-hosted server (Reverb, Soketi), e.g. `ws.example.com`.
  static String get pusherHost => dotenv.get('PUSHER_HOST', fallback: '');

  static int get pusherPort =>
      int.tryParse(dotenv.get('PUSHER_PORT', fallback: '')) ?? 443;

  /// `wss` (default) or `ws`.
  static String get pusherScheme =>
      dotenv.get('PUSHER_SCHEME', fallback: 'wss');

  static Duration get connectTimeout => _duration('CONNECT_TIMEOUT_MS', 30000);

  static Duration get receiveTimeout => _duration('RECEIVE_TIMEOUT_MS', 30000);

  static Duration _duration(String key, int fallbackMs) => Duration(
    milliseconds: int.tryParse(dotenv.get(key, fallback: '')) ?? fallbackMs,
  );
}
