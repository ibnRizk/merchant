import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';

/// Shown when an order list is empty.
class OrdersEmptyView extends StatelessWidget {
  const OrdersEmptyView({
    super.key,
    required this.message,
    this.isSearching = false,
  });

  final String message;
  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.receipt_long_outlined,
              size: 34,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? Strings.noResults : message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Below the last history card: a spinner while the next page loads, a
/// retry after a failure, or "load more" while pages remain. The button
/// matters on filtered tabs, whose short lists may never scroll.
class OrdersListFooter extends StatelessWidget {
  const OrdersListFooter({
    super.key,
    required this.hasMore,
    required this.isLoadingMore,
    required this.loadMoreFailed,
    required this.onLoadMore,
  });

  final bool hasMore;
  final bool isLoadingMore;
  final bool loadMoreFailed;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    if (isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colors.primary,
            ),
          ),
        ),
      );
    }
    if (!hasMore) return const SizedBox.shrink();
    return Center(
      child: TextButton.icon(
        onPressed: onLoadMore,
        icon: Icon(
          loadMoreFailed ? Icons.refresh_rounded : Icons.expand_more_rounded,
          size: 20,
        ),
        label: Text(
          loadMoreFailed ? Strings.retry : Strings.loadMore,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
          ),
        ),
        style: TextButton.styleFrom(foregroundColor: colors.primary),
      ),
    );
  }
}
