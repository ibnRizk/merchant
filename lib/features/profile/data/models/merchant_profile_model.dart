import '../../../../core/models/store_category_model.dart';
import '../../../../core/utils/json_values.dart';
import '../../domain/entities/merchant_profile.dart';

/// Parses `GET/PATCH /vendor/profile`: merchant fields at the top level and
/// the store as the first item of `stores[]`.
class MerchantProfileModel extends MerchantProfile {
  const MerchantProfileModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    super.store,
  });

  factory MerchantProfileModel.fromJson(Map<String, dynamic> json) {
    final dynamic stores = json['stores'];
    final dynamic firstStore = stores is List && stores.isNotEmpty
        ? stores.first
        : null;
    return MerchantProfileModel(
      id: _int(json['id']),
      firstName: _string(json['f_name']),
      lastName: _string(json['l_name']),
      email: _string(json['email']),
      phone: _string(json['phone']),
      store: firstStore is Map<String, dynamic>
          ? StoreProfileModel.fromJson(firstStore)
          : null,
    );
  }
}

class StoreProfileModel extends StoreProfile {
  const StoreProfileModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.email,
    required super.address,
    super.logoUrl,
    super.category,
    super.isOpen,
  });

  factory StoreProfileModel.fromJson(Map<String, dynamic> json) {
    return StoreProfileModel(
      id: _int(json['id']),
      name: _string(json['name']),
      phone: _string(json['phone']),
      email: _string(json['email']),
      address: _string(json['address']),
      // `logo_full_url` is the absolute URL; `logo` may be a bare file name.
      logoUrl: _url(json['logo_full_url']) ?? _url(json['logo']),
      category: StoreCategoryModel.tryParse(json['category']),
      isOpen: isTruthy(json['active']),
    );
  }
}

String _string(dynamic value) => value == null ? '' : value.toString().trim();

int _int(dynamic value) => int.tryParse('$value') ?? 0;

String? _url(dynamic value) {
  final String text = _string(value);
  return text.startsWith('http') ? text : null;
}
