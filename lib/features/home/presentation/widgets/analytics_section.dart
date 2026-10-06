import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/price_format.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/status_views.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../app_config/presentation/cubit/app_config_cubit.dart';
import '../../domain/entities/store_analytics.dart';
import '../cubit/analytics/analytics_cubit.dart';
import 'analytics_period_picker.dart';
import 'order_outcome_bar.dart';
import 'stat_card.dart';
import 'top_items_chart.dart';

/// The dashboard's "Performance" section: a range picker, headline
/// figures, order outcomes and best sellers. Reads [AnalyticsCubit].
class AnalyticsSection extends StatelessWidget {
  const AnalyticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AnalyticsCubit cubit = context.read<AnalyticsCubit>();
    return BlocBuilder<AnalyticsCubit, AnalyticsState>(
      builder: (BuildContext context, AnalyticsState state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SectionTitle(Strings.performance),
          const SizedBox(height: 12),
          AnalyticsPeriodPicker(
            selected: state.period,
            onSelected: cubit.selectPeriod,
          ),
          const SizedBox(height: 12),
          switch (state) {
            AnalyticsLoading() => const SectionLoadingView(height: 160),
            AnalyticsLoadFailure(:final message) => RetryErrorView(
              message: message,
              onRetry: cubit.load,
            ),
            AnalyticsLoaded(:final analytics) => _AnalyticsBody(analytics),
          },
        ],
      ),
    );
  }
}

class _AnalyticsBody extends StatelessWidget {
  const _AnalyticsBody(this.analytics);

  final StoreAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final String currency = context.currency;
    final String? suffix = currency.isEmpty ? null : currency;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: StatCard(
                label: Strings.totalSales,
                value: formatPrice(analytics.totalSales),
                suffix: suffix,
                background: colors.surface,
                valueColor: colors.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: Strings.averageOrderValue,
                value: formatPrice(analytics.averageOrderValue),
                suffix: suffix,
                background: colors.surface,
                valueColor: colors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(child: SectionTitle(Strings.ordersInPeriod)),
                  Text(
                    '${analytics.totalOrders}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OrderOutcomeBar(analytics: analytics),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SectionTitle(Strings.topItems),
              const SizedBox(height: 8),
              TopItemsChart(items: analytics.topItems),
            ],
          ),
        ),
      ],
    );
  }
}
