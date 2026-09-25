/// Central asset registry — no bare path strings anywhere else in the app.
///
/// Example:
/// ```dart
/// static const String logo = '$_images/logo.png';
/// static const String backIcon = '$_icons/back.svg';
/// ```
abstract class AppAssets {
  static const String images = 'assets/images';
  static const String icons = 'assets/icons';

  /// SSM brand logo (also the source of the launcher icon).
  static const String logo = '$images/icon.png';
}
