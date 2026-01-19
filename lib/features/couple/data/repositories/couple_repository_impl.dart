import '../../domain/entities/couple.dart';
import '../../domain/repositories/couple_repository.dart';
import '../datasources/couple_remote_datasource.dart';

/// CoupleRepository 구현체
///
/// Clean Architecture의 Repository 패턴 구현체입니다.
/// Domain 레이어의 CoupleRepository 인터페이스를 구현하고,
/// CoupleRemoteDataSource를 사용하여 실제 데이터 작업을 수행합니다.
///
/// Repository는 데이터 소스를 추상화하여 도메인 레이어가
/// 구체적인 데이터 소스 구현에 의존하지 않도록 합니다.
class CoupleRepositoryImpl implements CoupleRepository {
  const CoupleRepositoryImpl(this._remoteDataSource);

  final CoupleRemoteDataSource _remoteDataSource;

  @override
  Future<Couple> createCouple({required String userId}) async {
    final coupleModel = await _remoteDataSource.createCouple(userId: userId);
    return coupleModel.toEntity();
  }

  @override
  Future<Couple> joinCouple({
    required String userId,
    required String inviteCode,
  }) async {
    final coupleModel = await _remoteDataSource.joinCouple(
      userId: userId,
      inviteCode: inviteCode,
    );
    return coupleModel.toEntity();
  }

  @override
  Future<Couple?> getCouple({required String coupleId}) async {
    final coupleModel = await _remoteDataSource.getCouple(coupleId: coupleId);
    return coupleModel?.toEntity();
  }

  @override
  Future<Couple?> getCoupleByInviteCode({required String inviteCode}) async {
    final coupleModel = await _remoteDataSource.getCoupleByInviteCode(
      inviteCode: inviteCode,
    );
    return coupleModel?.toEntity();
  }

  @override
  Future<Couple?> getCoupleByUserId({required String userId}) async {
    final coupleModel = await _remoteDataSource.getCoupleByUserId(
      userId: userId,
    );
    return coupleModel?.toEntity();
  }

  @override
  Stream<Couple?> coupleStateChanges({required String coupleId}) {
    return _remoteDataSource.coupleStateChanges(coupleId: coupleId).map(
          (coupleModel) => coupleModel?.toEntity(),
        );
  }
}
