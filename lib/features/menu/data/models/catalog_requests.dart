import 'package:dio/dio.dart';

import '../../domain/params/product_params.dart';

/// Maps domain params to the multipart bodies the catalog API expects. Kept
/// in the data layer so the domain never knows about keys or multipart.

extension ProductDraftRequest on ProductDraft {
  /// Throws a `FileSystemException` if [imagePath] no longer exists; the
  /// repository maps that to a failure.
  Future<FormData> toFormData() async => FormData.fromMap(<String, dynamic>{
    'name': name.trim(),
    'description': description.trim(),
    'price': price.toString(),
    'category_id': categoryId.toString(),
    if (imagePath != null) 'image': await MultipartFile.fromFile(imagePath!),
  });
}

extension ProductUpdateRequest on ProductUpdate {
  Future<FormData> toFormData() async => FormData.fromMap(<String, dynamic>{
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    if (price != null) 'price': price.toString(),
    if (categoryId != null) 'category_id': categoryId.toString(),
    if (imagePath != null) 'image': await MultipartFile.fromFile(imagePath!),
  });
}
