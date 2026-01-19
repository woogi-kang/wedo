import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/auth_exception.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

part 'auth_provider.g.dart';

/// AuthRemoteDataSource Provider
///
/// Firebase Auth 및 Firestore 데이터 소스 인스턴스를 제공합니다.
@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSourceImpl();
}

/// AuthRepository Provider
///
/// 인증 관련 비즈니스 로직을 수행하는 Repository 인스턴스를 제공합니다.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
}

/// Auth State Stream Provider
///
/// Firebase Auth의 인증 상태 변경을 실시간으로 감지합니다.
/// 로그인/로그아웃 시 자동으로 상태가 업데이트됩니다.
@Riverpod(keepAlive: true)
Stream<User?> authStateChanges(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
}

/// Current User Provider
///
/// 현재 인증된 사용자 정보를 제공합니다.
/// authStateChanges 스트림의 최신 값을 반환합니다.
@Riverpod(keepAlive: true)
User? currentUser(Ref ref) {
  final asyncUser = ref.watch(authStateChangesProvider);
  return asyncUser.valueOrNull;
}

/// Auth Controller Provider
///
/// 인증 관련 액션 (로그인, 회원가입, 로그아웃)을 수행하는 컨트롤러입니다.
/// UI에서 사용자 인증 작업을 수행할 때 이 Provider를 사용합니다.
@riverpod
class AuthController extends _$AuthController {
  @override
  AuthState build() {
    // authStateChanges를 구독하여 초기 상태 결정
    final asyncUser = ref.watch(authStateChangesProvider);

    return asyncUser.when(
      data: (user) {
        if (user != null) {
          return AuthState.authenticated(user);
        }
        return const AuthState.unauthenticated();
      },
      loading: () => const AuthState.loading(),
      error: (error, _) => AuthState.error(error.toString()),
    );
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  /// 이메일/비밀번호로 로그인
  ///
  /// [email] 사용자 이메일
  /// [password] 비밀번호
  ///
  /// 성공 시 AuthState.authenticated로 상태 변경
  /// 실패 시 AuthState.error로 상태 변경
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();

    try {
      final user = await _repository.signIn(
        email: email,
        password: password,
      );
      state = AuthState.authenticated(user);
    } on SignInException catch (e) {
      state = AuthState.error(_mapSignInError(e));
    } catch (e) {
      state = AuthState.error('로그인 중 오류가 발생했습니다.');
    }
  }

  /// 이메일/비밀번호로 회원가입
  ///
  /// [email] 사용자 이메일
  /// [password] 비밀번호
  /// [displayName] 표시 이름
  ///
  /// 성공 시 AuthState.authenticated로 상태 변경
  /// 실패 시 AuthState.error로 상태 변경
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AuthState.loading();

    try {
      final user = await _repository.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = AuthState.authenticated(user);
    } on SignUpException catch (e) {
      state = AuthState.error(_mapSignUpError(e));
    } catch (e) {
      state = AuthState.error('회원가입 중 오류가 발생했습니다.');
    }
  }

  /// 로그아웃
  ///
  /// 성공 시 AuthState.unauthenticated로 상태 변경
  /// 실패 시 AuthState.error로 상태 변경
  Future<void> signOut() async {
    state = const AuthState.loading();

    try {
      await _repository.signOut();
      state = const AuthState.unauthenticated();
    } on SignOutException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error('로그아웃 중 오류가 발생했습니다.');
    }
  }

  /// 에러 상태 초기화
  ///
  /// 에러 상태에서 다시 시도하기 전에 호출
  void clearError() {
    final asyncUser = ref.read(authStateChangesProvider);
    state = asyncUser.when(
      data: (user) {
        if (user != null) {
          return AuthState.authenticated(user);
        }
        return const AuthState.unauthenticated();
      },
      loading: () => const AuthState.loading(),
      error: (_, __) => const AuthState.unauthenticated(),
    );
  }

  /// 로그인 예외를 사용자 친화적인 메시지로 변환
  String _mapSignInError(SignInException e) {
    return switch (e.code) {
      'user-not-found' => '등록되지 않은 이메일입니다.',
      'wrong-password' => '비밀번호가 올바르지 않습니다.',
      'invalid-email' => '유효하지 않은 이메일 형식입니다.',
      'user-disabled' => '비활성화된 계정입니다.',
      'too-many-requests' => '너무 많은 시도입니다. 잠시 후 다시 시도해주세요.',
      'invalid-credential' => '이메일 또는 비밀번호가 올바르지 않습니다.',
      _ => e.message,
    };
  }

  /// 회원가입 예외를 사용자 친화적인 메시지로 변환
  String _mapSignUpError(SignUpException e) {
    return switch (e.code) {
      'email-already-in-use' => '이미 사용 중인 이메일입니다.',
      'invalid-email' => '유효하지 않은 이메일 형식입니다.',
      'weak-password' => '비밀번호가 너무 약합니다.',
      'operation-not-allowed' => '회원가입이 허용되지 않습니다.',
      _ => e.message,
    };
  }
}
