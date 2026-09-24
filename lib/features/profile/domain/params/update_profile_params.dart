import 'package:equatable/equatable.dart';

import '../entities/merchant_profile.dart';

/// Body of `PATCH /vendor/profile`. A `null` field is left untouched on the
/// server, so only the fields the merchant actually changed are sent.
class UpdateProfileParams extends Equatable {
  final String? firstName;
  final String? lastName;
  final String? storeName;
  final String? storePhone;
  final String? storeEmail;
  final String? storeAddress;

  const UpdateProfileParams({
    this.firstName,
    this.lastName,
    this.storeName,
    this.storePhone,
    this.storeEmail,
    this.storeAddress,
  });

  /// Diffs the edited values against [current]. Values are trimmed, and a
  /// value equal to the current one becomes `null`.
  factory UpdateProfileParams.changesFrom(
    MerchantProfile current, {
    required String firstName,
    required String lastName,
    required String storeName,
    required String storePhone,
    required String storeEmail,
    required String storeAddress,
  }) {
    String? changed(String edited, String original) {
      final String value = edited.trim();
      return value == original.trim() ? null : value;
    }

    final StoreProfile? store = current.store;
    return UpdateProfileParams(
      firstName: changed(firstName, current.firstName),
      lastName: changed(lastName, current.lastName),
      storeName: changed(storeName, store?.name ?? ''),
      storePhone: changed(storePhone, store?.phone ?? ''),
      storeEmail: changed(storeEmail, store?.email ?? ''),
      storeAddress: changed(storeAddress, store?.address ?? ''),
    );
  }

  /// The API rejects an empty body with 422, so callers skip the request.
  bool get isEmpty => props.every((Object? value) => value == null);

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    storeName,
    storePhone,
    storeEmail,
    storeAddress,
  ];
}
