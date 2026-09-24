/// Central endpoint registry — paths only.
///
/// The host comes from `AppEnv.baseUrl` (see `.env`) and is applied once as
/// `Dio.options.baseUrl`, so never put a full URL here.
abstract class ApiEndpoints {
  // --- Auth (public, no token) ---
  static const String authPrefix = '/auth/vendor';
  static const String login = '$authPrefix/login';
  static const String register = '$authPrefix/register';
  static const String forgotPassword = '$authPrefix/forgot-password';
  static const String verifyToken = '$authPrefix/verify-token';
  static const String resetPassword = '$authPrefix/reset-password';
  static const String storeCategories = '$authPrefix/store-categories';

  // --- Session and profile (token) ---
  static const String vendorProfile = '/vendor/profile';
  static const String vendorLogout = '/vendor/logout';

  // --- Catalog (approved) ---
  static const String catalogMetadata = '/vendor/catalog/metadata';
  static const String catalogItems = '/vendor/catalog/items';
  static String catalogItem(int id) => '$catalogItems/$id';
  static String catalogItemStatus(int id) => '$catalogItems/$id/status';
}
