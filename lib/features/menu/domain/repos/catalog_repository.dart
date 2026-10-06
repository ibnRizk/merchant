import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/catalog_metadata.dart';
import '../entities/product.dart';
import '../entities/product_options.dart';
import '../params/product_params.dart';

/// The merchant's catalog. Every route needs an approved account.
abstract class CatalogRepository {
  /// Must succeed before a product can be created or edited: it supplies
  /// the valid `category_id` values.
  Future<Either<Failure, CatalogMetadata>> getMetadata();

  /// [search] filters by name; empty means all products.
  Future<Either<Failure, ProductPage>> getProducts({
    required int page,
    String search = '',
  });

  Future<Either<Failure, Product>> getProduct(int id);

  /// The new product is live immediately (active and approved).
  Future<Either<Failure, Product>> createProduct(ProductDraft draft);

  Future<Either<Failure, Product>> updateProduct(int id, ProductUpdate update);

  /// Fails with a `ConflictFailure` when the product is used in any order;
  /// such products can only be deactivated.
  Future<Either<Failure, Unit>> deleteProduct(int id);

  Future<Either<Failure, Unit>> updateStatus(int id, {required bool isActive});

  /// Replaces the product's variations and add-ons; returns what was saved.
  Future<Either<Failure, ProductOptions>> updateOptions(
    int id,
    ProductOptions options,
  );
}
