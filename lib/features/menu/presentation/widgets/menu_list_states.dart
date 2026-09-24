import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';

/// Shown when the list is empty: a first-product prompt, or "no results"
/// while searching.
class MenuEmptyView extends StatelessWidget {
  const MenuEmptyView({
    super.key,
    required this.isSearching,
    required this.onAddTap,
  });

  final bool isSearching;
  final VoidCallback onAddTap;

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
                  : Icons.restaurant_menu_rounded,
              size: 34,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? Strings.noResults : Strings.noProductsYet,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          if (!isSearching) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              Strings.noProductsHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onAddTap,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(
                Strings.addProductTitle,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Below the last card: a spinner while the next page loads, or a retry
/// button when it failed.
class MenuListFooter extends StatelessWidget {
  const MenuListFooter({
    super.key,
    required this.isLoadingMore,
    required this.loadMoreFailed,
    required this.onRetry,
  });

  final bool isLoadingMore;
  final bool loadMoreFailed;
  final VoidCallback onRetry;

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
    if (loadMoreFailed) {
      return Center(
        child: TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 20),
          label: Text(
            Strings.retry,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
            ),
          ),
          style: TextButton.styleFrom(foregroundColor: colors.primary),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
