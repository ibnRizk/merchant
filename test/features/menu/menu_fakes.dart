import 'package:dartz/dartz.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/menu/domain/entities/catalog_metadata.dart';
import 'package:ssm_merchant/features/menu/domain/entities/product.dart';
import 'package:ssm_merchant/features/menu/domain/entities/product_options.dart';
import 'package:ssm_merchant/features/menu/domain/params/product_params.dart';
import 'package:ssm_merchant/features/menu/domain/repos/catalog_repository.dart';

export '../../helpers/fake_dio_consumer.dart';

const CatalogOption burgers = CatalogOption(id: 1, name: 'Burgers');
const CatalogOption drinks = CatalogOption(id: 2, name: 'Drinks');

const CatalogMetadata sampleMetadata = CatalogMetadata(
  categories: <CatalogOption>[burgers, drinks],
  units: <CatalogOption>[],
);

Product product(int id, {bool isActive = true, double price = 28}) => Product(
  id: id,
  name: 'Product $id',
  description: 'Description $id',
  price: price,
  isActive: isActive,
  category: burgers,
);

ProductPage page(List<Product> products, {int current = 1, int last = 1}) =>
    ProductPage(products: products, currentPage: current, lastPage: last);

/// Answers from overridable handlers and records every write.
class FakeCatalogRepository implements CatalogRepository {
  Either<Failure, CatalogMetadata> metadataResult = const Right(sampleMetadata);
  Either<Failure, Product> productResult = Right(product(1));
  Either<Failure, Product> createResult = Right(product(9));
  Either<Failure, Product> updateResult = Right(product(1, price: 30));
  Either<Failure, Unit> deleteResult = const Right(unit);
  Either<Failure, Unit> statusResult = const Right(unit);
  Either<Failure, Unit> optionsResult = const Right(unit);
  final List<({int id, ProductOptions options})> optionUpdates = [];

  /// Default: one page holding products 1–3.
  Future<Either<Failure, ProductPage>> Function(int page, String search)
  onGetProducts = (_, __) async =>
      Right(page(<Product>[product(1), product(2), product(3)]));

  final List<({int page, String search})> productRequests = [];
  final List<ProductDraft> creates = <ProductDraft>[];
  final List<ProductUpdate> updates = <ProductUpdate>[];
  final List<({int id, bool isActive})> statusChanges = [];
  final List<int> deletes = <int>[];

  @override
  Future<Either<Failure, CatalogMetadata>> getMetadata() async =>
      metadataResult;

  @override
  Future<Either<Failure, ProductPage>> getProducts({
    required int page,
    String search = '',
  }) {
    productRequests.add((page: page, search: search));
    return onGetProducts(page, search);
  }

  @override
  Future<Either<Failure, Product>> getProduct(int id) async => productResult;

  @override
  Future<Either<Failure, Product>> createProduct(ProductDraft draft) async {
    creates.add(draft);
    return createResult;
  }

  @override
  Future<Either<Failure, Product>> updateProduct(
    int id,
    ProductUpdate update,
  ) async {
    updates.add(update);
    return updateResult;
  }

  @override
  Future<Either<Failure, Unit>> deleteProduct(int id) async {
    deletes.add(id);
    return deleteResult;
  }

  @override
  Future<Either<Failure, Unit>> updateStatus(
    int id, {
    required bool isActive,
  }) async {
    statusChanges.add((id: id, isActive: isActive));
    return statusResult;
  }

  @override
  Future<Either<Failure, ProductOptions>> updateOptions(
    int id,
    ProductOptions options,
  ) async {
    optionUpdates.add((id: id, options: options));
    return optionsResult.map((_) => options);
  }
}
