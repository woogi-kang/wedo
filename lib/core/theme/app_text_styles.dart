import 'package:flutter/material.dart';

import 'app_colors.dart';

/// WeDo 앱 텍스트 스타일 정의
///
/// Material Design 3 타이포그래피 스케일 기반
/// 앱 전체에서 일관된 텍스트 스타일 사용
abstract final class AppTextStyles {
  // === Display Styles ===
  /// 가장 큰 제목 - 스플래시, 온보딩 등
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );

  // === Headline Styles ===
  /// 주요 섹션 제목
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  // === Title Styles ===
  /// 카드, 다이얼로그 제목
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.50,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // === Body Styles ===
  /// 본문 텍스트
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.50,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // === Label Styles ===
  /// 버튼, 칩, 라벨 텍스트
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // === Custom App Styles ===

  /// Todo 제목 스타일
  static const TextStyle todoTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.50,
  );

  /// Todo 완료 상태 스타일 (취소선)
  static TextStyle get todoTitleCompleted => todoTitle.copyWith(
        decoration: TextDecoration.lineThrough,
        color: AppColors.grey500,
      );

  /// Todo 설명 스타일
  static const TextStyle todoDescription = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
    color: AppColors.grey600,
  );

  /// 날짜/시간 표시 스타일
  static const TextStyle dateTime = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.33,
    color: AppColors.grey500,
  );

  /// 파트너 이름 표시 스타일
  static const TextStyle partnerName = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  /// 앱바 제목 스타일
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.40,
  );

  /// 버튼 텍스트 스타일
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  /// 링크 텍스트 스타일
  static TextStyle get link => bodyMedium.copyWith(
        color: AppColors.primary,
        decoration: TextDecoration.underline,
      );

  /// 에러 메시지 스타일
  static TextStyle get error => bodySmall.copyWith(
        color: AppColors.error,
      );

  /// 힌트 텍스트 스타일
  static TextStyle get hint => bodyMedium.copyWith(
        color: AppColors.grey500,
      );

  /// 캡션 스타일
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    color: AppColors.grey600,
  );

  /// 배지/카운터 스타일
  static const TextStyle badge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.20,
  );
}
