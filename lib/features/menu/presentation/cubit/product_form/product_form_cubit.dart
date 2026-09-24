import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure_message.dart';
import '../../../../../core/error/failures.dart';
import '../../../domain/entities/catalog_metadata.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/params/product_params.dart';
import '../../../domain/repos/catalog_repository.dart';
import 'product_form_state.dart';

export 'product_form_state.dart';

/// Add/edit product. Loads the catalog metadata first (the API needs a
/// valid `category_id`), plus the full product when editing.
class ProductFormCubit extends Cubit<ProductFormState> {
  final CatalogRepository _repository;
  int? _productId;

  ProductFormCubit({required CatalogRepository repository})
    : _repository = repository,
      super(const ProductFormLoading());

  /// [productId] is `null` when adding a product.
  Future<void> load({int? productId}) async {
    _productId = productId;
    emit(const ProductFormLoading());

    // Both requests run in parallel.
    final Future<Either<Failure, CatalogMetadata>> metadataRequest =
        _repository.getMetadata();
    final Future<Either<Failure, Product>>? productRequest = productId == null
        ? null
        : _repository.getProduct(productId);
    final Either<Failure, CatalogMetadata> metadata = await metadataRequest;
    final Either<Failure, Product>? product = await productRequest;
    if (isClosed) return;

    emit(
      metadata.fold(
        (failure) => ProductFormLoadFailure(failure.displayMessage),
        (metadata) => product == null
            ? ProductFormEditing(metadata, null)
            : product.fold(
                (failure) => ProductFormLoadFailure(failure.displayMessage),
                (product) => ProductFormEditing(metadata, product),
              ),
      ),
    );
  }

  Future<void> retry() => load(productId: _productId);

  /// Creates or updates the product, then applies [isAvailable] through the
  /// status endpoint, which is the only way the API changes availability.
  Future<void> save(ProductDraft draft, {required bool isAvailable}) async {
    final ProductFormState current = state;
    if (current is! ProductFormReady || current is ProductFormSaving) return;

    final Product? existing = current.product;
    if (existing == null) {
      await _create(current.metadata, draft, isAvailable: isAvailable);
    } else {
      await _update(current.metadata, existing, draft, isAvailable);
    }
  }

  Future<void> _create(
    CatalogMetadata metadata,
    ProductDraft draft, {
    required bool isAvailable,
  }) async {
    emit(ProductFormSaving(metadata, null));
    final result = await _repository.createProduct(draft);
    if (isClosed) return;

    final Product? created = result.fold((_) => null, (p) => p);
    if (created == null) {
      emit(
        ProductFormSaveFailure(metadata, null, _messageOf(result)),
      );
      return;
    }
    // New products go live immediately; hide it if the merchant said so.
    if (isAvailable == created.isActive) {
      emit(ProductFormSaved(metadata, created));
      return;
    }
    await _applyStatus(metadata, created, isAvailable);
  }

  Future<void> _update(
    CatalogMetadata metadata,
    Product existing,
    ProductDraft draft,
    bool isAvailable,
  ) async {
    final ProductUpdate update = ProductUpdate.changesFrom(existing, draft);
    final bool statusChanged = isAvailable != existing.isActive;
    if (update.isEmpty && !statusChanged) {
      emit(ProductFormUnchanged(metadata, existing));
      return;
    }

    emit(ProductFormSaving(metadata, existing));
    Product saved = existing;
    if (!update.isEmpty) {
      final result = await _repository.updateProduct(existing.id, update);
      if (isClosed) return;
      final Product? updated = result.fold((_) => null, (p) => p);
      if (updated == null) {
        emit(ProductFormSaveFailure(metadata, existing, _messageOf(result)));
        return;
      }
      saved = updated;
    }

    if (!statusChanged) {
      emit(ProductFormSaved(metadata, saved));
      return;
    }
    if (update.isEmpty) {
      // Availability was the only change, so its failure is the save's.
      final result = await _repository.updateStatus(
        existing.id,
        isActive: isAvailable,
      );
      if (isClosed) return;
      emit(
        result.fold(
          (failure) => ProductFormSaveFailure(
            metadata,
            existing,
            failure.displayMessage,
          ),
          (_) => ProductFormSaved(
            metadata,
            existing.copyWith(isActive: isAvailable),
          ),
        ),
      );
      return;
    }
    await _applyStatus(metadata, saved, isAvailable);
  }

  /// Runs after the product itself is saved; a failure here is reported as
  /// a partial save rather than losing the saved details.
  Future<void> _applyStatus(
    CatalogMetadata metadata,
    Product saved,
    bool isAvailable,
  ) async {
    final result = await _repository.updateStatus(
      saved.id,
      isActive: isAvailable,
    );
    if (isClosed) return;
    emit(
      result.fold(
        (_) => ProductFormSaved(metadata, saved, statusUpdateFailed: true),
        (_) => ProductFormSaved(metadata, saved.copyWith(isActive: isAvailable)),
      ),
    );
  }

  static String _messageOf<T>(Either<Failure, T> result) =>
      result.fold((failure) => failure.displayMessage, (_) => '');
}
