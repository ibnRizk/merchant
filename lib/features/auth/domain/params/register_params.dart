import 'package:equatable/equatable.dart';

/// Unit for [RegisterParams.minimumDeliveryTime] and
/// [RegisterParams.maximumDeliveryTime].
enum DeliveryTimeType { min, hours, days }

/// Store name and address in one locale.
///
/// The data layer serialises these into the API's `translations` JSON string
/// (per locale: the `name` entry first, then `address`).
class StoreTranslation extends Equatable {
  /// Language code, e.g. `en` or `ar`.
  final String locale;
  final String name;
  final String address;

  const StoreTranslation({
    required this.locale,
    required this.name,
    required this.address,
  });

  @override
  List<Object?> get props => [locale, name, address];
}

/// Body of `POST /auth/vendor/register` (multipart).
///
/// Creates a pending merchant and store; an admin must approve the account
/// before operational routes work.
class RegisterParams extends Equatable {
  final String fName;
  final String lName;
  final String email;
  final String phone;

  /// At least 8 characters with upper and lower case letters, a digit and a
  /// symbol.
  final String password;

  /// Store location. Must be inside [zoneId], otherwise the API returns 403.
  final double latitude;
  final double longitude;

  final int zoneId;
  final int moduleId;
  final double tax;

  final int minimumDeliveryTime;
  final int maximumDeliveryTime;
  final DeliveryTimeType deliveryTimeType;

  /// Must not be empty.
  final List<StoreTranslation> translations;

  /// Local path of the logo image. Required by the API.
  final String logoPath;

  /// Local path of the cover image.
  final String? coverPhotoPath;

  const RegisterParams({
    required this.fName,
    required this.lName,
    required this.email,
    required this.phone,
    required this.password,
    required this.latitude,
    required this.longitude,
    required this.zoneId,
    required this.moduleId,
    required this.tax,
    required this.minimumDeliveryTime,
    required this.maximumDeliveryTime,
    required this.deliveryTimeType,
    required this.translations,
    required this.logoPath,
    this.coverPhotoPath,
  });

  @override
  List<Object?> get props => [
    fName,
    lName,
    email,
    phone,
    password,
    latitude,
    longitude,
    zoneId,
    moduleId,
    tax,
    minimumDeliveryTime,
    maximumDeliveryTime,
    deliveryTimeType,
    translations,
    logoPath,
    coverPhotoPath,
  ];

  @override
  String toString() => 'RegisterParams(email: $email, zoneId: $zoneId)';
}
