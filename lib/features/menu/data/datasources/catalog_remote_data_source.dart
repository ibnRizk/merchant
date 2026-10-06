import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/params/product_params.dart';
import '../models/catalog_models.dart';
import '../models/catalog_requests.dart';

/// Talks to `/vendor/catalog/*`. Throws [AppException]s; the repository
/// turns them into failures. A 409 surfaces as [ConflictException].
abstract class CatalogRemoteDataSource {
  Future<CatalogMetadataModel> getMetadata();

  Future<ProductPageModel> getProducts({
    required int page,
    required int perPage,
    required String search,
  });

  Future<ProductModel> getProduct(int id);

  Future<ProductModel> createProduct(ProductDraft draft);

  Future<ProductModel> updateProduct(int id, ProductUpdate update);

  Future<void> deleteProduct(int id);

  Future<void> updateStatus(int id, {required bool isActive});
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  final DioConsumer _client;

  const CatalogRemoteDataSourceImpl({required DioConsumer client})
    : _client = client;

  @override
  Future<CatalogMetadataModel> getMetadata() async => CatalogMetadataModel
      .fromJson(_asMap(await _client.get(ApiEndpoints.catalogMetadata)));

  @override
  Future<ProductPageModel> getProducts({
    required int page,
    required int perPage,
    required String search,
  }) async {
    final dynamic response = await _client.get(
      ApiEndpoints.catalogItems,
      queryParameters: <String, dynamic>{
        'page': page,
        'per_page': perPage,
        if (search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    return ProductPageModel.fromJson(_asMap(response));
  }

  @override
  Future<ProductModel> getProduct(int id) async =>
      _productOf(await _client.get(ApiEndpoints.catalogItem(id)));

  @override
  Future<ProductModel> createProduct(ProductDraft draft) async => _productOf(
    await _client.post(
      ApiEndpoints.catalogItems,
      formData: await draft.toFormData(),
    ),
  );

  /// POST, not PUT/PATCH: the API only reads multipart (image) updates on
  /// POST.
  @override
  Future<ProductModel> updateProduct(int id, ProductUpdate update) async =>
      _productOf(
        await _client.post(
          ApiEndpoints.catalogItem(id),
          formData: await update.toFormData(),
        ),
      );

  @override
  Future<void> deleteProduct(int id) =>
      _client.delete(ApiEndpoints.catalogItem(id));

  @override
  Future<void> updateStatus(int id, {required bool isActive}) => _client.patch(
    ApiEndpoints.catalogItemStatus(id),
    body: <String, dynamic>{'status': isActive},
  );

  /// Writes answer `{message, item}`; reads may return the item itself.
  ProductModel _productOf(dynamic response) {
    final Map<String, dynamic> json = _asMap(response);
    final dynamic item = json['item'] ?? json['data'];
    return ProductModel.fromJson(
      item is Map<String, dynamic> ? item : json,
    );
  }

  Map<String, dynamic> _asMap(dynamic response) {
    if (response is Map<String, dynamic>) return response;
    throw ServerException.unexpectedResponse();
  }
}
