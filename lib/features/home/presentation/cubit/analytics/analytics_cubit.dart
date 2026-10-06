import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure_message.dart';
import '../../../domain/entities/store_analytics.dart';
import '../../../domain/repos/analytics_repository.dart';
import 'analytics_state.dart';

export 'analytics_state.dart';

/// The dashboard's performance section (`GET /vendor/analytics`).
class AnalyticsCubit extends Cubit<AnalyticsState> {
  final AnalyticsRepository _repository;

  /// Injectable clock, so tests can pin "today".
  final DateTime Function() _now;

  /// Bumped on every fetch, so an older response can't overwrite a newer one.
  int _generation = 0;

  AnalyticsCubit({
    required AnalyticsRepository repository,
    DateTime Function() now = DateTime.now,
  }) : _repository = repository,
       _now = now,
       super(const AnalyticsLoading(AnalyticsPeriod.last7Days));

  Future<void> load() => _fetch(state.period, keepCurrent: false);

  /// Keeps the current figures on screen until the new ones arrive.
  Future<void> refresh() => _fetch(state.period, keepCurrent: true);

  Future<void> selectPeriod(AnalyticsPeriod period) async {
    if (period == state.period && state is! AnalyticsLoadFailure) return;
    return _fetch(period, keepCurrent: false);
  }

  Future<void> _fetch(
    AnalyticsPeriod period, {
    required bool keepCurrent,
  }) async {
    final int generation = ++_generation;
    final AnalyticsState current = state;
    if (!keepCurrent || current is! AnalyticsLoaded) {
      emit(AnalyticsLoading(period));
    }
    final ({DateTime from, DateTime to}) range = period.rangeEndingOn(_now());
    final result = await _repository.getAnalytics(
      from: range.from,
      to: range.to,
    );
    if (isClosed || generation != _generation) return;

    emit(
      result.fold(
        (failure) => keepCurrent && current is AnalyticsLoaded
            // A failed pull-to-refresh keeps the figures; the dashboard
            // announces its own refresh failure.
            ? current
            : AnalyticsLoadFailure(period, failure.displayMessage),
        (StoreAnalytics analytics) => AnalyticsLoaded(period, analytics),
      ),
    );
  }
}
