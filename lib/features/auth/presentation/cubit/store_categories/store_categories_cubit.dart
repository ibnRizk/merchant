import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure_message.dart';
import '../../../domain/repos/merchant_auth_repository.dart';
import 'store_categories_state.dart';

export 'store_categories_state.dart';

/// Feeds the category picker on the registration screen. Kept apart from
/// [RegisterCubit] so loading the list and submitting the form don't share
/// one state machine.
class StoreCategoriesCubit extends Cubit<StoreCategoriesState> {
  final MerchantAuthRepository _repository;

  StoreCategoriesCubit({required MerchantAuthRepository repository})
    : _repository = repository,
      super(const StoreCategoriesLoading());

  Future<void> load() async {
    emit(const StoreCategoriesLoading());

    final result = await _repository.getStoreCategories();
    if (isClosed) return;

    emit(
      result.fold(
        (failure) => StoreCategoriesFailure(failure.displayMessage),
        StoreCategoriesLoaded.new,
      ),
    );
  }

  /// Whether the merchant still has to pick a category before submitting.
  /// With no categories defined there is nothing to pick, and the API
  /// accepts a registration without one.
  bool isSelectionMissing(int? selectedId) => switch (state) {
    StoreCategoriesLoaded(:final categories) =>
      categories.isNotEmpty && selectedId == null,
    StoreCategoriesLoading() || StoreCategoriesFailure() => true,
  };
}
