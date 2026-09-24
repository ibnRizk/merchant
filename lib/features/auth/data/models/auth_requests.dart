import 'dart:convert';

import 'package:dio/dio.dart';

import '../../domain/params/login_params.dart';
import '../../domain/params/register_params.dart';
import '../../domain/params/reset_password_params.dart';
import '../../domain/params/verify_token_params.dart';

/// Maps domain params to the exact bodies the API expects. Kept in the data
/// layer so the domain never knows about JSON keys or multipart.

extension LoginRequest on LoginParams {
  Map<String, dynamic> toJson() => <String, dynamic>{
    'email': email.trim(),
    'password': password,
    'vendor_type': switch (vendorType) {
      VendorType.owner => 'owner',
    },
  };
}

extension VerifyTokenRequest on VerifyTokenParams {
  Map<String, dynamic> toJson() => <String, dynamic>{
    'email': email.trim(),
    'reset_token': resetToken,
  };
}

extension ResetPasswordRequest on ResetPasswordParams {
  Map<String, dynamic> toJson() => <String, dynamic>{
    'email': email.trim(),
    'reset_token': resetToken,
    'password': password,
    'confirm_password': confirmPassword,
  };
}

extension RegisterRequest on RegisterParams {
  /// Stores register tax-free for now, but the API still requires the field.
  static const String defaultTax = '0';

  /// Multipart body. [zoneId] and [moduleId] come from app config, not the
  /// merchant. Throws a `FileSystemException` if an image path no longer
  /// exists; the repository maps that to a failure.
  Future<FormData> toFormData({
    required int zoneId,
    required int moduleId,
  }) async {
    return FormData.fromMap(<String, dynamic>{
      'f_name': fName.trim(),
      'l_name': lName.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'password': password,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'zone_id': zoneId.toString(),
      'module_id': moduleId.toString(),
      'tax': defaultTax,
      if (storeCategoryId != null)
        'store_category_id': storeCategoryId.toString(),
      'minimum_delivery_time': minimumDeliveryTime.toString(),
      'maximum_delivery_time': maximumDeliveryTime.toString(),
      'delivery_time_type': switch (deliveryTimeType) {
        DeliveryTimeType.min => 'min',
        DeliveryTimeType.hours => 'hours',
        DeliveryTimeType.days => 'days',
      },
      'translations': encodeTranslations(translations),
      'logo': await MultipartFile.fromFile(logoPath),
      if (coverPhotoPath != null)
        'cover_photo': await MultipartFile.fromFile(coverPhotoPath!),
    });
  }
}

/// The API reads item 0 as the store name and item 1 as the address, so each
/// locale contributes its `name` entry before its `address` entry.
String encodeTranslations(List<StoreTranslation> translations) {
  return jsonEncode(<Map<String, String>>[
    for (final StoreTranslation t in translations) ...<Map<String, String>>[
      <String, String>{
        'locale': t.locale,
        'key': 'name',
        'value': t.name.trim(),
      },
      <String, String>{
        'locale': t.locale,
        'key': 'address',
        'value': t.address.trim(),
      },
    ],
  ]);
}
