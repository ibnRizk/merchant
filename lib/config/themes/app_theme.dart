import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/utils/values/app_colors.dart';
import '../../core/utils/values/fonts.dart';

/// Both themes are built from one function so light and dark can never drift.
///
/// These are getters, not constants: they use ScreenUtil (`.w/.h/.sp/.r`), so
/// they must be evaluated *inside* the `ScreenUtilInit` builder — which is
/// where `app.dart` reads them.
ThemeData get lightTheme => _buildTheme(AppColors.light, Brightness.light);

ThemeData get darkTheme => _buildTheme(AppColors.dark, Brightness.dark);

ThemeData _buildTheme(AppColors c, Brightness brightness) {
  final bool isDark = brightness == Brightness.dark;

  final ColorScheme colorScheme = ColorScheme(
    brightness: brightness,
    primary: c.primary,
    onPrimary: Colors.white,
    primaryContainer: c.primaryLight,
    onPrimaryContainer: isDark ? Colors.white : c.primaryDark,
    secondary: c.secondary,
    onSecondary: Colors.white,
    surface: isDark ? const Color(0xFF1E1E1E) : c.surface,
    onSurface: c.textPrimary,
    surfaceContainerHighest: isDark ? const Color(0xFF121212) : c.background,
    onSurfaceVariant: c.textSecondary,
    outline: c.border,
    error: c.error,
    onError: Colors.white,
  );

  final TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(color: colorScheme.onSurface, fontFamily: Fonts.primary, fontWeight: FontWeight.w700),
    displayMedium: TextStyle(color: colorScheme.onSurface, fontFamily: Fonts.primary, fontWeight: FontWeight.w700),
    displaySmall: TextStyle(color: colorScheme.onSurface, fontFamily: Fonts.primary, fontWeight: FontWeight.w700),
    headlineLarge: TextStyle(color: colorScheme.onSurface, fontFamily: Fonts.primary, fontWeight: FontWeight.w600),
    headlineMedium: TextStyle(color: colorScheme.onSurface, fontFamily: Fonts.primary, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(color: colorScheme.onSurface, fontFamily: Fonts.primary, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(color: colorScheme.onSurface, fontFamily: Fonts.primary, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(color: colorScheme.onSurface, fontFamily: Fonts.primary, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(color: colorScheme.onSurface, fontFamily: Fonts.primary, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(color: colorScheme.onSurface, fontFamily: Fonts.primary, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(color: colorScheme.onSurface, fontFamily: Fonts.primary, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(color: colorScheme.onSurfaceVariant, fontFamily: Fonts.primary, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(color: colorScheme.onSurface, fontFamily: Fonts.primary, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(color: colorScheme.onSurface, fontFamily: Fonts.primary, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(color: colorScheme.onSurfaceVariant, fontFamily: Fonts.primary, fontWeight: FontWeight.w500),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: Fonts.primary,
    extensions: <ThemeExtension<dynamic>>[c],
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: colorScheme.surfaceContainerHighest,
    dividerTheme: DividerThemeData(thickness: 1, space: 1, color: colorScheme.outline),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: colorScheme.primary),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 64.h,
      iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24.r),
      actionsIconTheme: IconThemeData(color: colorScheme.onSurface, size: 24.r),
      titleTextStyle: TextStyle(
        fontFamily: Fonts.primary,
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: colorScheme.outline),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14.sp),
      border: _border(colorScheme.outline, 12.r),
      enabledBorder: _border(colorScheme.outline, 12.r),
      focusedBorder: _border(colorScheme.primary, 12.r, width: 1.5),
      errorBorder: _border(colorScheme.error, 12.r),
      focusedErrorBorder: _border(colorScheme.error, 12.r, width: 1.5),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        disabledBackgroundColor: colorScheme.outline,
        elevation: 0,
        minimumSize: Size(double.infinity, 52.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        minimumSize: Size(double.infinity, 52.h),
        side: BorderSide(color: colorScheme.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        padding: EdgeInsets.zero,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(padding: EdgeInsets.zero),
    ),
    checkboxTheme: CheckboxThemeData(
      checkColor: WidgetStateProperty.all<Color>(colorScheme.onPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      selectedLabelStyle: TextStyle(fontSize: 12.sp),
      unselectedLabelStyle: TextStyle(fontSize: 12.sp),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

OutlineInputBorder _border(Color color, double radius, {double width = 1}) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );
