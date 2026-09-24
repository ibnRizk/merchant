import '../../../../../core/entities/store_category.dart';

sealed class StoreCategoriesState {
  const StoreCategoriesState();
}

final class StoreCategoriesLoading extends StoreCategoriesState {
  const StoreCategoriesLoading();
}

/// [categories] may be empty when the admin hasn't defined any yet.
final class StoreCategoriesLoaded extends StoreCategoriesState {
  final List<StoreCategory> categories;

  const StoreCategoriesLoaded(this.categories);
}

final class StoreCategoriesFailure extends StoreCategoriesState {
  final String message;

  const StoreCategoriesFailure(this.message);
}
