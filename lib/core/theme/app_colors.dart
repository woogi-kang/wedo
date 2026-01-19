import 'package:flutter/material.dart';

/// WeDo 앱 색상 팔레트
///
/// 커플 테마에 맞는 핑크/코랄 기반 색상 시스템
/// Material Design 3 색상 체계 준수
abstract final class AppColors {
  // === Primary Colors (Pink/Coral) ===
  /// 메인 핑크/코랄 색상 - 커플 테마
  static const Color primary = Color(0xFFFF6B6B);
  static const Color primaryLight = Color(0xFFFF9E9E);
  static const Color primaryDark = Color(0xFFE84545);

  // === Secondary Colors (Teal) ===
  /// 보조 색상 - 청록색 계열
  static const Color secondary = Color(0xFF4ECDC4);
  static const Color secondaryLight = Color(0xFF7EDDD6);
  static const Color secondaryDark = Color(0xFF36B5AC);

  // === Tertiary Colors (Yellow) ===
  /// 강조 색상 - 노란색 계열
  static const Color tertiary = Color(0xFFFFE66D);
  static const Color tertiaryLight = Color(0xFFFFF09D);
  static const Color tertiaryDark = Color(0xFFE6CE4E);

  // === Surface Colors - Light Mode ===
  static const Color surfaceLight = Color(0xFFFFFBFE);
  static const Color surfaceContainerLight = Color(0xFFF5F0F3);
  static const Color surfaceContainerHighLight = Color(0xFFEDE8EB);
  static const Color surfaceContainerHighestLight = Color(0xFFE8E0E5);

  // === Surface Colors - Dark Mode ===
  static const Color surfaceDark = Color(0xFF1C1B1F);
  static const Color surfaceContainerDark = Color(0xFF211F24);
  static const Color surfaceContainerHighDark = Color(0xFF2B292E);
  static const Color surfaceContainerHighestDark = Color(0xFF363439);

  // === Background Colors ===
  static const Color backgroundLight = Color(0xFFFFFBFE);
  static const Color backgroundDark = Color(0xFF1C1B1F);

  // === On Colors - Light Mode ===
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color onSurfaceLight = Color(0xFF1C1B1F);
  static const Color onBackgroundLight = Color(0xFF1C1B1F);

  // === On Colors - Dark Mode ===
  static const Color onPrimaryDark = Color(0xFF1C1B1F);
  static const Color onSecondaryDark = Color(0xFF1C1B1F);
  static const Color onSurfaceDark = Color(0xFFE6E1E5);
  static const Color onBackgroundDark = Color(0xFFE6E1E5);

  // === Status Colors ===
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  static const Color warning = Color(0xFFFFB74D);
  static const Color warningLight = Color(0xFFFFD180);
  static const Color warningDark = Color(0xFFF57C00);

  static const Color error = Color(0xFFEF5350);
  static const Color errorLight = Color(0xFFEF9A9A);
  static const Color errorDark = Color(0xFFD32F2F);

  static const Color info = Color(0xFF42A5F5);
  static const Color infoLight = Color(0xFF90CAF9);
  static const Color infoDark = Color(0xFF1976D2);

  // === Couple-specific Colors ===
  /// Partner 1 표시 색상 (나)
  static const Color partner1 = Color(0xFFFF8A80);
  /// Partner 2 표시 색상 (상대방)
  static const Color partner2 = Color(0xFF80D8FF);
  /// 공유/함께 표시 색상
  static const Color together = Color(0xFFB388FF);

  // === Todo Priority Colors ===
  static const Color priorityHigh = Color(0xFFFF5252);
  static const Color priorityMedium = Color(0xFFFFB74D);
  static const Color priorityLow = Color(0xFF81C784);

  // === Neutral Colors ===
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // === Outline Colors ===
  static const Color outlineLight = Color(0xFF79747E);
  static const Color outlineVariantLight = Color(0xFFCAC4D0);
  static const Color outlineDark = Color(0xFF938F99);
  static const Color outlineVariantDark = Color(0xFF49454F);

  // === Scrim & Shadow ===
  static const Color scrim = Color(0xFF000000);
  static const Color shadow = Color(0xFF000000);

  // === Transparent ===
  static const Color transparent = Colors.transparent;
}
