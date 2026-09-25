/// Where the app goes once the splash screen finishes.
enum LaunchDestination {
  /// First launch without a session: introduce the app.
  onboarding,

  /// Onboarding already seen, but there is no saved session.
  login,

  /// A session token is saved. If the server has revoked it, the first 401
  /// sends the merchant back to login.
  home,
}
