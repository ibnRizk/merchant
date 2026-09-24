import '../../../domain/entities/catalog_metadata.dart';
import '../../../domain/entities/product.dart';

sealed class ProductFormState {
  const ProductFormState();
}

final class ProductFormLoading extends ProductFormState {
  const ProductFormLoading();
}

/// Metadata (or the product being edited) couldn't be loaded, so the form
/// can't be shown.
final class ProductFormLoadFailure extends ProductFormState {
  final String message;

  const ProductFormLoadFailure(this.message);
}

/// The form is on screen. The subtypes describe the latest save attempt.
sealed class ProductFormReady extends ProductFormState {
  final CatalogMetadata metadata;

  /// The product being edited; `null` when adding a new one.
  final Product? product;

  const ProductFormReady(this.metadata, this.product);
}

final class ProductFormEditing extends ProductFormReady {
  const ProductFormEditing(super.metadata, super.product);
}

final class ProductFormSaving extends ProductFormReady {
  const ProductFormSaving(super.metadata, super.product);
}

/// Save was requested but nothing differs from [product].
final class ProductFormUnchanged extends ProductFormReady {
  const ProductFormUnchanged(super.metadata, super.product);
}

final class ProductFormSaveFailure extends ProductFormReady {
  final String message;

  const ProductFormSaveFailure(super.metadata, super.product, this.message);
}

/// [saved] is the product as the server now has it. [statusUpdateFailed]
/// means the details were saved but the availability change was not.
final class ProductFormSaved extends ProductFormReady {
  final Product saved;
  final bool statusUpdateFailed;

  const ProductFormSaved(
    CatalogMetadata metadata,
    this.saved, {
    this.statusUpdateFailed = false,
  }) : super(metadata, saved);
}
