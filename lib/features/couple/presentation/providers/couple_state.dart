import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/couple.dart';

part 'couple_state.freezed.dart';

/// 커플 상태
///
/// Riverpod Notifier에서 사용하는 커플 상태 클래스입니다.
/// Freezed를 사용하여 불변 상태와 패턴 매칭을 지원합니다.
@freezed
class CoupleState with _$CoupleState {
  /// 초기 상태 (앱 시작 시, 커플 상태 확인 전)
  const factory CoupleState.initial() = CoupleInitial;

  /// 로딩 상태 (커플 작업 진행 중)
  const factory CoupleState.loading() = CoupleLoading;

  /// 커플 없음 상태 (아직 커플을 생성하거나 합류하지 않음)
  const factory CoupleState.noCouple() = CoupleNoCouple;

  /// 파트너 대기 중 상태 (초대 코드 생성됨, 파트너 합류 대기)
  const factory CoupleState.waitingForPartner(Couple couple) =
      CoupleWaitingForPartner;

  /// 연결 완료 상태 (커플 연결됨)
  const factory CoupleState.connected(Couple couple) = CoupleConnected;

  /// 에러 상태
  const factory CoupleState.error(String message) = CoupleError;
}
