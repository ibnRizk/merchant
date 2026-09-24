import 'package:equatable/equatable.dart';

/// Merchant category (e.g. Restaurant, Pharmacy) managed by the admin.
/// Chosen at registration and shown read-only on the profile.
class StoreCategory extends Equatable {
  final int id;

  /// Name in the language the request was made in.
  final String name;
  final String nameAr;
  final String nameEn;

  const StoreCategory({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.nameEn,
  });

  /// Name for [languageCode] (`ar`/`en`), so a language switch doesn't need
  /// a refetch. Falls back to [name] when that translation is missing.
  String localizedName(String languageCode) {
    final String localized = languageCode == 'ar' ? nameAr : nameEn;
    return localized.isEmpty ? name : localized;
  }

  @override
  List<Object?> get props => [id, name, nameAr, nameEn];
}
