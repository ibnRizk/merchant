import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard_failure.dart';
import '../../domain/entities/catalog_metadata.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_options.dart';
import '../../domain/params/product_params.dart';
import '../../domain/repos/catalog_repository.dart';
import '../datasources/catalog_remote_data_source.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  /// Page size for the menu list (the API allows 1–100).
  static const int pageSize = 20;

  final CatalogRemoteDataSource _remote;

  const CatalogRepositoryImpl({required CatalogRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, CatalogMetadata>> getMetadata() =>
      guardFailure(_remote.getMetadata);

  @override
  Future<Either<Failure, ProductPage>> getProducts({
    required int page,
    String search = '',
  }) => guardFailure(
    () => _remote.getProducts(page: page, perPage: pageSize, search: search),
  );

  @override
  Future<Either<Failure, Product>> getProduct(int id) =>
      guardFailure(() => _remote.getProduct(id));

  @override
  Future<Either<Failure, Product>> createProduct(ProductDraft draft) =>
      guardFailure(() => _remote.createProduct(draft));

  @override
  Future<Either<Failure, Product>> updateProduct(
    int id,
    ProductUpdate update,
  ) => guardFailure(() => _remote.updateProduct(id, update));

  @override
  Future<Either<Failure, Unit>> deleteProduct(int id) => guardFailure(() async {
    await _remote.deleteProduct(id);
    return unit;
  });

  @override
  Future<Either<Failure, Unit>> updateStatus(
    int id, {
    required bool isActive,
  }) => guardFailure(() async {
    await _remote.updateStatus(id, isActive: isActive);
    return unit;
  });

  @override
  Future<Either<Failure, ProductOptions>> updateOptions(
    int id,
    ProductOptions options,
  ) => guardFailure(() async {
    await _remote.updateOptions(id, options);
    return options;
  });
}
