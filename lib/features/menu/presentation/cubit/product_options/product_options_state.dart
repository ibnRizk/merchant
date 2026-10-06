import '../../../domain/entities/product_options.dart';

sealed class ProductOptionsState {
  const ProductOptionsState();
}

final class ProductOptionsLoading extends ProductOptionsState {
  const ProductOptionsLoading();
}

final class ProductOptionsLoadFailure extends ProductOptionsState {
  final String message;

  const ProductOptionsLoadFailure(this.message);
}

/// The saved options, ready to edit.
final class ProductOptionsReady extends ProductOptionsState {
  final ProductOptions options;
  final bool isSaving;

  /// Describes only the emit it came with (see [ProductOptionsNotice]).
  final ProductOptionsNotice? notice;

  const ProductOptionsReady(this.options, {this.isSaving = false, this.notice});
}

/// A one-off outcome for the UI to announce. Never const, so a listener
/// can tell a fresh notice apart with `identical`.
sealed class ProductOptionsNotice {
  const ProductOptionsNotice();
}

final class ProductOptionsSavedNotice extends ProductOptionsNotice {
  // Not const: each notice must be a distinct instance.
  ProductOptionsSavedNotice();
}

final class ProductOptionsInvalidNotice extends ProductOptionsNotice {
  final ProductOptionsError error;

  ProductOptionsInvalidNotice(this.error);
}

final class ProductOptionsFailedNotice extends ProductOptionsNotice {
  final String message;

  ProductOptionsFailedNotice(this.message);
}
