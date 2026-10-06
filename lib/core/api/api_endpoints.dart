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
  static const String updateActiveStatus = '/vendor/update-active-status';
  static const String workingHours = '/vendor/working-hours';
  static const String dashboardStats = '/vendor/dashboard-stats';
  static const String vendorConfig = '/vendor/config';

  /// `DELETE` requests account deletion; an admin completes it.
  static const String vendorAccount = '/vendor/account';

  // --- Onboarding (token, works while pending) ---
  static const String onboardingStatus = '/vendor/onboarding-status';

  // --- Catalog (approved) ---
  static const String catalogMetadata = '/vendor/catalog/metadata';
  static const String catalogItems = '/vendor/catalog/items';
  static String catalogItem(int id) => '$catalogItems/$id';
  static String catalogItemStatus(int id) => '$catalogItems/$id/status';

  // --- Orders (approved) ---
  static const String currentOrders = '/vendor/current-orders';
  static const String completedOrders = '/vendor/completed-orders';
  static const String orderSummary = '/vendor/order';
  static const String orderLines = '/vendor/order-details';

  /// [command] is `accept`, `reject`, `start-preparing` or
  /// `ready-for-pickup`.
  static String orderCommand(int id, String command) =>
      '/vendor/orders/$id/$command';

  /// Only valid while the order is `assignment_failed`.
  static String retryDispatch(int id) => '/vendor/orders/$id/retry-dispatch';
}
