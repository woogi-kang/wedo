import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/couple_exception.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/couple_remote_datasource.dart';
import '../../data/repositories/couple_repository_impl.dart';
import '../../domain/entities/couple.dart';
import '../../domain/repositories/couple_repository.dart';
import 'couple_state.dart';

part 'couple_provider.g.dart';

/// CoupleRemoteDataSource Provider
///
/// Firestore 데이터 소스 인스턴스를 제공합니다.
@Riverpod(keepAlive: true)
CoupleRemoteDataSource coupleRemoteDataSource(Ref ref) {
  return CoupleRemoteDataSourceImpl();
}

/// CoupleRepository Provider
///
/// 커플 관련 비즈니스 로직을 수행하는 Repository 인스턴스를 제공합니다.
@Riverpod(keepAlive: true)
CoupleRepository coupleRepository(Ref ref) {
  final dataSource = ref.watch(coupleRemoteDataSourceProvider);
  return CoupleRepositoryImpl(dataSource);
}

/// 현재 사용자의 커플 상태 스트림 Provider
///
/// 사용자의 커플 상태를 실시간으로 감지합니다.
/// 로그인 상태에 따라 자동으로 구독이 관리됩니다.
@Riverpod(keepAlive: true)
Stream<Couple?> coupleStream(Ref ref) async* {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    yield null;
    return;
  }

  final repository = ref.watch(coupleRepositoryProvider);

  // 먼저 현재 커플 상태 조회
  final couple = await repository.getCoupleByUserId(userId: user.uid);
  if (couple == null) {
    yield null;
    return;
  }

  // 커플이 있으면 실시간 스트림 구독
  yield* repository.coupleStateChanges(coupleId: couple.id);
}

/// 현재 커플 상태 Provider
///
/// coupleStream의 동기화된 상태를 제공합니다.
@Riverpod(keepAlive: true)
CoupleState currentCoupleState(Ref ref) {
  final asyncCouple = ref.watch(coupleStreamProvider);

  return asyncCouple.when(
    data: (couple) {
      if (couple == null) {
        return const CoupleState.noCouple();
      }
      if (couple.isConnected) {
        return CoupleState.connected(couple);
      }
      return CoupleState.waitingForPartner(couple);
    },
    loading: () => const CoupleState.loading(),
    error: (error, _) => CoupleState.error(error.toString()),
  );
}

/// Couple Controller Provider
///
/// 커플 관련 액션 (생성, 합류)을 수행하는 컨트롤러입니다.
/// UI에서 커플 작업을 수행할 때 이 Provider를 사용합니다.
@riverpod
class CoupleController extends _$CoupleController {
  @override
  CoupleState build() {
    return ref.watch(currentCoupleStateProvider);
  }

  CoupleRepository get _repository => ref.read(coupleRepositoryProvider);

  String? get _currentUserId => ref.read(currentUserProvider)?.uid;

  /// 초대 코드 생성 (새 커플 생성)
  ///
  /// 6자리 고유 초대 코드가 생성되어 파트너 대기 상태가 됩니다.
  ///
  /// 성공 시 CoupleState.waitingForPartner로 상태 변경
  /// 실패 시 CoupleState.error로 상태 변경
  Future<void> createInviteCode() async {
    final userId = _currentUserId;
    if (userId == null) {
      state = const CoupleState.error('로그인이 필요합니다.');
      return;
    }

    state = const CoupleState.loading();

    try {
      final couple = await _repository.createCouple(userId: userId);
      state = CoupleState.waitingForPartner(couple);
      // 스트림을 새로고침하여 실시간 업데이트 받기
      ref.invalidate(coupleStreamProvider);
    } on CreateCoupleException catch (e) {
      state = CoupleState.error(_mapCreateCoupleError(e));
    } catch (e) {
      state = const CoupleState.error('커플 생성 중 오류가 발생했습니다.');
    }
  }

  /// 초대 코드로 커플 합류
  ///
  /// [inviteCode] 파트너가 공유한 6자리 초대 코드
  ///
  /// 성공 시 CoupleState.connected로 상태 변경
  /// 실패 시 CoupleState.error로 상태 변경
  Future<void> joinCouple({required String inviteCode}) async {
    final userId = _currentUserId;
    if (userId == null) {
      state = const CoupleState.error('로그인이 필요합니다.');
      return;
    }

    state = const CoupleState.loading();

    try {
      final couple = await _repository.joinCouple(
        userId: userId,
        inviteCode: inviteCode,
      );
      state = CoupleState.connected(couple);
      // 스트림을 새로고침
      ref.invalidate(coupleStreamProvider);
    } on JoinCoupleException catch (e) {
      state = CoupleState.error(_mapJoinCoupleError(e));
    } catch (e) {
      state = const CoupleState.error('커플 합류 중 오류가 발생했습니다.');
    }
  }

  /// 에러 상태 초기화
  ///
  /// 에러 상태에서 다시 시도하기 전에 호출
  void clearError() {
    state = ref.read(currentCoupleStateProvider);
  }

  /// 커플 생성 예외를 사용자 친화적인 메시지로 변환
  String _mapCreateCoupleError(CreateCoupleException e) {
    return switch (e.code) {
      'already-in-couple' => '이미 커플에 속해 있습니다.',
      'invalid-user' => '유효하지 않은 사용자입니다.',
      _ => e.message,
    };
  }

  /// 커플 합류 예외를 사용자 친화적인 메시지로 변환
  String _mapJoinCoupleError(JoinCoupleException e) {
    return switch (e.code) {
      'invalid-invite-code' => '유효하지 않은 초대 코드입니다.',
      'couple-full' => '이미 커플이 완성되어 참여할 수 없습니다.',
      'already-in-couple' => '이미 다른 커플에 속해 있습니다.',
      'cannot-join-own-couple' => '자신이 생성한 커플에는 참여할 수 없습니다.',
      'expired-invite-code' => '만료된 초대 코드입니다.',
      _ => e.message,
    };
  }
}
