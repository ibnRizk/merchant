import 'package:equatable/equatable.dart';

/// The `vendor_type` a login is made as. This app only signs in store owners.
enum VendorType { owner }

/// Body of `POST /auth/vendor/login`.
class LoginParams extends Equatable {
  final String email;
  final String password;
  final VendorType vendorType;

  const LoginParams({
    required this.email,
    required this.password,
    this.vendorType = VendorType.owner,
  });

  @override
  List<Object?> get props => [email, password, vendorType];

  @override
  String toString() => 'LoginParams(email: $email, vendorType: $vendorType)';
}
