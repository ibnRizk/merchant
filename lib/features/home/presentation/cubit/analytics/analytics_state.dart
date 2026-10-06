import '../../../domain/entities/store_analytics.dart';

/// Every state knows the selected [period], so the picker stays put while
/// loading or after a failure.
sealed class AnalyticsState {
  final AnalyticsPeriod period;

  const AnalyticsState(this.period);
}

final class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading(super.period);
}

final class AnalyticsLoadFailure extends AnalyticsState {
  final String message;

  const AnalyticsLoadFailure(super.period, this.message);
}

final class AnalyticsLoaded extends AnalyticsState {
  final StoreAnalytics analytics;

  const AnalyticsLoaded(super.period, this.analytics);
}
