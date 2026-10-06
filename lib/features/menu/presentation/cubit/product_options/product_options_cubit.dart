import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure_message.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/product_options.dart';
import '../../../domain/repos/catalog_repository.dart';
import 'product_options_state.dart';

export 'product_options_state.dart';

/// Edits one product's variations and add-ons. Loads the product first so
/// the editor starts from what the server has, not a stale list copy.
class ProductOptionsCubit extends Cubit<ProductOptionsState> {
  final CatalogRepository _repository;
  int? _productId;

  ProductOptionsCubit({required CatalogRepository repository})
    : _repository = repository,
      super(const ProductOptionsLoading());

  Future<void> load(int productId) async {
    _productId = productId;
    emit(const ProductOptionsLoading());
    final result = await _repository.getProduct(productId);
    if (isClosed) return;

    emit(
      result.fold(
        (failure) => ProductOptionsLoadFailure(failure.displayMessage),
        (Product product) => ProductOptionsReady(product.options),
      ),
    );
  }

  /// Validates [options], then saves them. Invalid options are announced
  /// and not sent.
  Future<void> save(ProductOptions options) async {
    final ProductOptionsState current = state;
    final int? productId = _productId;
    if (current is! ProductOptionsReady ||
        current.isSaving ||
        productId == null) {
      return;
    }
    final ProductOptionsError? error = options.validationError;
    if (error != null) {
      emit(
        ProductOptionsReady(
          current.options,
          notice: ProductOptionsInvalidNotice(error),
        ),
      );
      return;
    }

    emit(ProductOptionsReady(current.options, isSaving: true));
    final result = await _repository.updateOptions(productId, options);
    if (isClosed) return;

    emit(
      result.fold(
        (failure) => ProductOptionsReady(
          current.options,
          notice: ProductOptionsFailedNotice(failure.displayMessage),
        ),
        (ProductOptions saved) =>
            ProductOptionsReady(saved, notice: ProductOptionsSavedNotice()),
      ),
    );
  }
}
