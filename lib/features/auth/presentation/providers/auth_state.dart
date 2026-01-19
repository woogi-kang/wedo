import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user.dart';

part 'auth_state.freezed.dart';

/// 인증 상태
///
/// Riverpod Notifier에서 사용하는 인증 상태 클래스입니다.
/// Freezed를 사용하여 불변 상태와 패턴 매칭을 지원합니다.
@freezed
class AuthState with _$AuthState {
  /// 초기 상태 (앱 시작 시)
  const factory AuthState.initial() = AuthInitial;

  /// 로딩 상태 (인증 작업 진행 중)
  const factory AuthState.loading() = AuthLoading;

  /// 인증 완료 상태 (로그인됨)
  const factory AuthState.authenticated(User user) = AuthAuthenticated;

  /// 미인증 상태 (로그아웃됨)
  const factory AuthState.unauthenticated() = AuthUnauthenticated;

  /// 에러 상태
  const factory AuthState.error(String message) = AuthError;
}
