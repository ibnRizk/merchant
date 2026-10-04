/// Where the app goes once the splash screen finishes.
enum LaunchDestination {
  /// First launch without a session: introduce the app.
  onboarding,

  /// Onboarding already seen, but there is no usable session.
  login,

  /// A saved session that can operate (or whose status couldn't be checked,
  /// e.g. offline; a later 403 still reroutes to the pending screen).
  home,

  /// A saved session whose account is pending, rejected or suspended.
  pendingApproval,
}
