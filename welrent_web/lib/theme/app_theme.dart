import 'package:flutter/material.dart';

/// Design tokens extracted from `next-web/src/app/globals.css`.
class AppColors {
  const AppColors._();

  static const textPrimary = Color(0xFF1C263A);
  static const textMuted = Color(0xFFA0A4AB);
  static const textLightGrey = Color(0xFFD5DBE1);
  static const accentBlue = Color(0xFF5CAAF6);
  static const accentBlueHover = Color(0xFF4A98E0);
  static const bgPage = Color(0xFFF8F9FB);
  static const bgWhite = Color(0xFFFFFFFF);
  static const bgOffWhite = Color(0xFFFAFBFC);
  static const borderLight = Color(0xFFEBEBEB);
  static const gridLine = Color(0xFFF0F2F5);
  static const searchBg = Color(0xFFF3F4F6);
  static const fieldText = Color(0xFF8C929A);
  static const bodyGrey = Color(0xFF6B7280);
  static const searchButton = Color(0xFFAAB4BF);
  static const searchButtonHover = Color(0xFF929CA8);
  static const trustGreen = Color(0xFF00B67A);
  static const error = Color(0xFFDC2626);
  static const errorBg = Color(0xFFFEF2F2);
  static const errorBorder = Color(0xFFFECACA);
  static const bookRed = Color(0xFFFF4D4D);
  static const kbdBg = Color(0xFFE5E7EB);
  static const placeholder = Color(0xFFC4C9D2);
  static const infoBg = Color(0xFFF4F5F7);
  static const navyMid = Color(0xFF2D4A8C);
  static const purple = Color(0xFF371947);
  static const wordmark = Color(0xFFC6C6C6);
  static const dividerGrey = Color(0xFFD8D8D8);
  static const upcoming = Color(0xFFD97706);
  static const upcomingBg = Color(0xFFFEF9C3);
  static const completed = Color(0xFF059669);
  static const completedBg = Color(0xFFECFDF5);
  static const activeBg = Color(0xFFEFF6FF);
  static const alertAmber = Color(0xFFFAAD14);
  static const alertAmberBg = Color(0xFFFFF7E6);
  static const greenBg = Color(0xFFE6F7F0);
  static const iconGrey = Color(0xFF9CA3AF);
  static const cancelBorder = Color(0xFFFEE2E2);
}

class AppBreakpoints {
  const AppBreakpoints._();

  static const double mobile = 768;
  static const double compact = 1000;
  static const double tablet = 1024;
  static const double content = 1100;

  static bool isMobile(double width) => width < mobile;
  static bool isCompact(double width) => width < compact;
}

class AppText {
  const AppText._();

  static TextStyle outfit({
    double size = 16,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'Outfit',
      fontSize: size,
      fontWeight: weight,
      fontVariations: [FontVariation('wght', weight.value.toDouble())],
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle playfair({
    double size = 48,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double height = 1,
    FontStyle style = FontStyle.normal,
  }) {
    return TextStyle(
      fontFamily: 'Playfair Display',
      fontStyle: style,
      fontSize: size,
      fontWeight: weight,
      fontVariations: [FontVariation('wght', weight.value.toDouble())],
      color: color,
      height: height,
    );
  }

  static TextStyle tinos({
    double size = 28,
    Color color = AppColors.wordmark,
    double height = 1,
  }) {
    return TextStyle(
      fontFamily: 'Tinos',
      fontSize: size,
      fontWeight: FontWeight.w400,
      color: color,
      height: height,
    );
  }
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: AppColors.accentBlue,
      onPrimary: Colors.white,
      secondary: AppColors.textPrimary,
      onSecondary: Colors.white,
      surface: AppColors.bgWhite,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: Colors.white,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bgOffWhite,
      fontFamily: 'Outfit',
      splashFactory: NoSplash.splashFactory,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      dividerColor: AppColors.borderLight,
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: 'Outfit',
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.accentBlue,
        selectionColor: Color(0x335CAAF6),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.bgWhite,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
