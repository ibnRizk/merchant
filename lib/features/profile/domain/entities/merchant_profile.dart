import 'package:equatable/equatable.dart';

/// The signed-in merchant (owner) and their store, as `GET /vendor/profile`
/// returns them.
class MerchantProfile extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  /// `null` when the account has no store attached yet.
  final StoreProfile? store;

  const MerchantProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.store,
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [id, firstName, lastName, email, phone, store];
}

class StoreProfile extends Equatable {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String? logoUrl;

  const StoreProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    this.logoUrl,
  });

  @override
  List<Object?> get props => [id, name, phone, email, address, logoUrl];
}
