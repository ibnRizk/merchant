import '../../../domain/entities/product.dart';

sealed class MenuState {
  /// The active search text; empty for the full list.
  final String query;

  const MenuState(this.query);
}

final class MenuLoading extends MenuState {
  const MenuLoading(super.query);
}

/// The first page failed; there is no list to show.
final class MenuLoadFailure extends MenuState {
  final String message;

  const MenuLoadFailure(super.query, this.message);
}

final class MenuLoaded extends MenuState {
  final List<Product> products;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  /// The next page failed. Scrolling stops fetching until a retry.
  final bool loadMoreFailed;

  /// Products with a status change or delete in flight.
  final Set<int> busyIds;

  /// A one-off outcome for the UI to announce. Every emit carries a new
  /// instance (or `null`), so a listener can tell a fresh notice apart.
  final MenuNotice? notice;

  const MenuLoaded({
    required String query,
    required this.products,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
    this.busyIds = const <int>{},
    this.notice,
  }) : super(query);

  /// [notice] is not carried over: it describes only the emit it came with.
  MenuLoaded copyWith({
    List<Product>? products,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    bool? loadMoreFailed,
    Set<int>? busyIds,
    MenuNotice? notice,
  }) => MenuLoaded(
    query: query,
    products: products ?? this.products,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    busyIds: busyIds ?? this.busyIds,
    notice: notice,
  );
}

sealed class MenuNotice {
  const MenuNotice();
}

final class ProductDeletedNotice extends MenuNotice {
  // Not const: each notice must be a distinct instance (see MenuLoaded).
  ProductDeletedNotice();
}

/// The product is used in orders (HTTP 409); it can only be deactivated.
final class ProductDeleteBlockedNotice extends MenuNotice {
  ProductDeleteBlockedNotice();
}

final class MenuActionFailedNotice extends MenuNotice {
  final String message;

  MenuActionFailedNotice(this.message);
}
