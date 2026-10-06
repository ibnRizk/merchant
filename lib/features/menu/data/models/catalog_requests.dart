import 'package:dio/dio.dart';

import '../../domain/entities/product_options.dart';
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

extension ProductOptionsRequest on ProductOptions {
  /// Every key is sent, so removing the last variation or add-on clears it
  /// (an empty body would be refused with 422 `options_required`).
  /// Variations are one single-choice group: `choice_options` names it and
  /// lists the values each `variations[].type` refers to.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'variations': <Map<String, dynamic>>[
      for (final ProductVariation v in variations)
        <String, dynamic>{
          'type': v.name.trim(),
          'price': v.price,
          if (v.stock != null) 'stock': v.stock,
        },
    ],
    'choice_options': <Map<String, dynamic>>[
      if (variations.isNotEmpty)
        <String, dynamic>{
          'name': 'choice_1',
          'title': variationTitle.trim(),
          'options': <String>[
            for (final ProductVariation v in variations) v.name.trim(),
          ],
        },
    ],
    'add_ons': <Map<String, dynamic>>[
      for (final ProductAddOn a in addOns)
        <String, dynamic>{'name': a.name.trim(), 'price': a.price},
    ],
  };
}
