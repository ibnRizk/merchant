import 'package:flutter/material.dart';

/// Raw SSM Merchant brand palette. Brand Orange drives primary actions
/// (buttons, toggles, progress); Primary Navy drives headings/emphasized
/// text in light mode and the navy-branded accents (selected chips, focused
/// borders) that stay constant across both modes.
abstract class Palette {
  // Brand
  static const Color primary = Color(0xFFF6921E); // Brand Orange
  static const Color primaryDark = Color(0xFFD97B12); // pressed/emphasis
  static const Color primaryLight = Color(0xFFFCE9D8); // peach tint
  static const Color secondary = Color(0xFF173C66); // Primary Navy

  // Neutrals — light
  static const Color background = Color(0xFFF5F6F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF173C66); // Navy doubles as
  // the heading/emphasized text color in light mode.
  static const Color textSecondary = Color(0xFF9AA1AC);
  static const Color border = Color(0xFFE2E5EA);

  // Neutrals — dark
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFF3F4F6);
  static const Color textSecondaryDark = Color(0xFFAAB2BD);
  static const Color borderDark = Color(0xFF2A2F3A);

  // Semantic
  static const Color error = Color(0xFFD9455F);
  static const Color success = Color(0xFF2E9E5B);
  static const Color warning = Color(0xFFAD6B1D);
  static const Color info = Color(0xFF2563EB);

  // Semantic containers (tinted backgrounds paired with the colors above)
  static const Color successContainer = Color(0xFFE6F5EC);
  static const Color successContainerDark = Color(0xFF1E3B2A);
  static const Color errorContainer = Color(0xFFFBE7EA);
  static const Color errorContainerDark = Color(0xFF3B1E24);
}

/// Theme-aware colour set, exposed as a [ThemeExtension] so light/dark resolve
/// automatically.
///
/// Prefer `context.colors.primary` inside widgets. The context-free `colors`
/// getter in `injection_container.dart` is kept in sync from
/// `MaterialApp.builder` for code that has no [BuildContext].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color error;
  final Color success;
  final Color warning;
  final Color info;
  final Color successContainer;
  final Color errorContainer;

  const AppColors({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
    required this.successContainer,
    required this.errorContainer,
  });

  static const AppColors light = AppColors(
    primary: Palette.primary,
    primaryDark: Palette.primaryDark,
    primaryLight: Palette.primaryLight,
    secondary: Palette.secondary,
    background: Palette.background,
    surface: Palette.surface,
    textPrimary: Palette.textPrimary,
    textSecondary: Palette.textSecondary,
    border: Palette.border,
    error: Palette.error,
    success: Palette.success,
    warning: Palette.warning,
    info: Palette.info,
    successContainer: Palette.successContainer,
    errorContainer: Palette.errorContainer,
  );

  static const AppColors dark = AppColors(
    primary: Palette.primary,
    primaryDark: Palette.primaryDark,
    primaryLight: Color(0xFF332313), // Deep brown/orange tinted surface for containers
    secondary: Palette.secondary,
    background: Palette.backgroundDark, // #121212
    surface: Palette.surfaceDark, // #1E1E1E
    textPrimary: Palette.textPrimaryDark,
    textSecondary: Palette.textSecondaryDark,
    border: Palette.borderDark,
    error: Palette.error,
    success: Palette.success,
    warning: Palette.warning,
    info: Palette.info,
    successContainer: Palette.successContainerDark,
    errorContainer: Palette.errorContainerDark,
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryDark,
    Color? primaryLight,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? error,
    Color? success,
    Color? warning,
    Color? info,
    Color? successContainer,
    Color? errorContainer,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryLight: primaryLight ?? this.primaryLight,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      error: error ?? this.error,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      successContainer: successContainer ?? this.successContainer,
      errorContainer: errorContainer ?? this.errorContainer,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
    );
  }

  /// Value equality matters here: Flutter compares theme extensions to decide
  /// whether a theme change should trigger a rebuild. Without it, every
  /// `ThemeData` rebuild looks like a change.
  List<Object> get _props => <Object>[
    primary,
    primaryDark,
    primaryLight,
    secondary,
    background,
    surface,
    textPrimary,
    textSecondary,
    border,
    error,
    success,
    warning,
    info,
    successContainer,
    errorContainer,
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppColors &&
          runtimeType == other.runtimeType &&
          _listEquals(_props, other._props);

  @override
  int get hashCode => Object.hashAll(_props);

  static bool _listEquals(List<Object> a, List<Object> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Preferred access inside widgets: `context.colors.primary`.
extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
