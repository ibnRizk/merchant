import 'package:flutter/material.dart';

import '../utils/values/app_colors.dart';
import '../utils/values/strings.dart';

/// Below the last item of a paged list: a spinner while the next page loads, a
/// retry after a failure, or "load more" while pages remain. The button
/// matters on short (e.g. filtered) lists that never scroll.
class LoadMoreFooter extends StatelessWidget {
  const LoadMoreFooter({
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
