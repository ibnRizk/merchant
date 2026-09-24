import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure_message.dart';
import '../../../../../core/error/failures.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/repos/catalog_repository.dart';
import 'menu_state.dart';

export 'menu_state.dart';

/// The menu list: search, pagination, availability toggles and deletes.
class MenuCubit extends Cubit<MenuState> {
  final CatalogRepository _repository;

  /// Bumped on every first-page load, so a slow response for an older
  /// search can't overwrite a newer one.
  int _generation = 0;

  MenuCubit({required CatalogRepository repository})
    : _repository = repository,
      super(const MenuLoading(''));

  /// Loads the first page, replacing the list with a loading state.
  Future<void> load({String? query}) async {
    final String search = (query ?? state.query).trim();
    final int generation = ++_generation;
    emit(MenuLoading(search));

    final result = await _repository.getProducts(page: 1, search: search);
    if (isClosed || generation != _generation) return;

    emit(
      result.fold(
        (failure) => MenuLoadFailure(search, failure.displayMessage),
        (page) => MenuLoaded(
          query: search,
          products: page.products,
          page: page.currentPage,
          hasMore: page.hasMore,
        ),
      ),
    );
  }

  /// No-op when [query] matches the list already shown.
  Future<void> search(String query) async {
    if (query.trim() == state.query && state is! MenuLoadFailure) return;
    await load(query: query);
  }

  /// Pull-to-refresh: refetches the first page but keeps the current list
  /// on screen until it arrives.
  Future<void> refresh() async {
    final MenuState current = state;
    if (current is! MenuLoaded) return load();

    final int generation = ++_generation;
    final result = await _repository.getProducts(
      page: 1,
      search: current.query,
    );
    if (isClosed || generation != _generation) return;

    emit(
      result.fold(
        (failure) => current.copyWith(
          notice: MenuActionFailedNotice(failure.displayMessage),
        ),
        (page) => MenuLoaded(
          query: current.query,
          products: page.products,
          page: page.currentPage,
          hasMore: page.hasMore,
        ),
      ),
    );
  }

  /// Appends the next page. Does nothing after a failure unless [retry].
  Future<void> loadMore({bool retry = false}) async {
    final MenuState current = state;
    if (current is! MenuLoaded ||
        !current.hasMore ||
        current.isLoadingMore ||
        (current.loadMoreFailed && !retry)) {
      return;
    }

    final int generation = _generation;
    emit(current.copyWith(isLoadingMore: true, loadMoreFailed: false));
    final result = await _repository.getProducts(
      page: current.page + 1,
      search: current.query,
    );
    final MenuState latest = state;
    if (isClosed || generation != _generation || latest is! MenuLoaded) return;

    emit(
      result.fold(
        (_) => latest.copyWith(isLoadingMore: false, loadMoreFailed: true),
        (page) {
          // A product created meanwhile shifts the pages; skip duplicates.
          final Set<int> shown = <int>{
            for (final Product p in latest.products) p.id,
          };
          return latest.copyWith(
            products: <Product>[
              ...latest.products,
              ...page.products.where((Product p) => !shown.contains(p.id)),
            ],
            page: page.currentPage,
            hasMore: page.hasMore,
            isLoadingMore: false,
          );
        },
      ),
    );
  }

  /// Flips availability right away and reverts it if the server refuses.
  Future<void> toggleStatus(Product product, {required bool isActive}) async {
    final MenuState current = state;
    if (current is! MenuLoaded || current.busyIds.contains(product.id)) {
      return;
    }

    emit(
      current.copyWith(
        products: _replace(
          current.products,
          product.copyWith(isActive: isActive),
        ),
        busyIds: <int>{...current.busyIds, product.id},
      ),
    );
    final result = await _repository.updateStatus(
      product.id,
      isActive: isActive,
    );
    final MenuState latest = state;
    if (isClosed || latest is! MenuLoaded) return;

    final Set<int> busyIds = <int>{...latest.busyIds}..remove(product.id);
    emit(
      result.fold(
        (failure) => latest.copyWith(
          products: _replace(latest.products, product),
          busyIds: busyIds,
          notice: MenuActionFailedNotice(failure.displayMessage),
        ),
        (_) => latest.copyWith(busyIds: busyIds),
      ),
    );
  }

  Future<void> deleteProduct(Product product) async {
    final MenuState current = state;
    if (current is! MenuLoaded || current.busyIds.contains(product.id)) {
      return;
    }

    emit(current.copyWith(busyIds: <int>{...current.busyIds, product.id}));
    final result = await _repository.deleteProduct(product.id);
    final MenuState latest = state;
    if (isClosed || latest is! MenuLoaded) return;

    final Set<int> busyIds = <int>{...latest.busyIds}..remove(product.id);
    emit(
      result.fold(
        (failure) => latest.copyWith(
          busyIds: busyIds,
          notice: failure is ConflictFailure
              ? ProductDeleteBlockedNotice()
              : MenuActionFailedNotice(failure.displayMessage),
        ),
        (_) => latest.copyWith(
          products: latest.products
              .where((Product p) => p.id != product.id)
              .toList(),
          busyIds: busyIds,
          notice: ProductDeletedNotice(),
        ),
      ),
    );
  }

  /// Reflects a product saved on the form: replaced in place when listed,
  /// otherwise added at the top.
  void productSaved(Product product) {
    final MenuState current = state;
    if (current is! MenuLoaded) {
      load();
      return;
    }
    final bool isListed = current.products.any(
      (Product p) => p.id == product.id,
    );
    emit(
      current.copyWith(
        products: isListed
            ? _replace(current.products, product)
            : <Product>[product, ...current.products],
      ),
    );
  }

  static List<Product> _replace(List<Product> products, Product updated) => [
    for (final Product p in products) p.id == updated.id ? updated : p,
  ];
}
