import '../../../domain/entities/dashboard_stats.dart';

sealed class DashboardState {
  const DashboardState();
}

final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// The first load failed; there are no figures to show.
final class DashboardLoadFailure extends DashboardState {
  final String message;

  const DashboardLoadFailure(this.message);
}

final class DashboardLoaded extends DashboardState {
  final DashboardStats stats;

  /// Set when a refresh failed; the previous figures stay on screen. A new
  /// instance per failure, so a listener can tell it apart.
  final DashboardRefreshFailure? refreshFailure;

  const DashboardLoaded(this.stats, {this.refreshFailure});
}

final class DashboardRefreshFailure {
  final String message;

  // Not const: each failure must be a distinct instance.
  DashboardRefreshFailure(this.message);
}
