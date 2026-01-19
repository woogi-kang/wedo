// Todo 관련 커스텀 예외 클래스
//
// Todo 기능 관련 작업 중 발생하는 에러를 앱 레벨에서
// 일관성 있게 처리하기 위한 예외 클래스 정의

/// Todo 관련 기본 예외 클래스
sealed class TodoException implements Exception {
  const TodoException(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  String toString() => 'TodoException: $message (code: $code)';
}

/// Todo 생성 실패 예외
class CreateTodoException extends TodoException {
  const CreateTodoException(super.message, [super.code]);

  factory CreateTodoException.invalidTitle() => const CreateTodoException(
        '제목을 입력해주세요.',
        'invalid-title',
      );

  factory CreateTodoException.invalidCoupleId() => const CreateTodoException(
        '유효하지 않은 커플 정보입니다.',
        'invalid-couple-id',
      );

  factory CreateTodoException.permissionDenied() => const CreateTodoException(
        'Todo를 생성할 권한이 없습니다.',
        'permission-denied',
      );

  factory CreateTodoException.unknown([String? message]) => CreateTodoException(
        message ?? 'Todo 생성 중 알 수 없는 오류가 발생했습니다.',
        'unknown',
      );
}

/// Todo 업데이트 실패 예외
class UpdateTodoException extends TodoException {
  const UpdateTodoException(super.message, [super.code]);

  factory UpdateTodoException.notFound() => const UpdateTodoException(
        'Todo를 찾을 수 없습니다.',
        'todo-not-found',
      );

  factory UpdateTodoException.permissionDenied() => const UpdateTodoException(
        'Todo를 수정할 권한이 없습니다.',
        'permission-denied',
      );

  factory UpdateTodoException.invalidData() => const UpdateTodoException(
        '유효하지 않은 데이터입니다.',
        'invalid-data',
      );

  factory UpdateTodoException.unknown([String? message]) => UpdateTodoException(
        message ?? 'Todo 업데이트 중 알 수 없는 오류가 발생했습니다.',
        'unknown',
      );
}

/// Todo 삭제 실패 예외
class DeleteTodoException extends TodoException {
  const DeleteTodoException(super.message, [super.code]);

  factory DeleteTodoException.notFound() => const DeleteTodoException(
        'Todo를 찾을 수 없습니다.',
        'todo-not-found',
      );

  factory DeleteTodoException.permissionDenied() => const DeleteTodoException(
        'Todo를 삭제할 권한이 없습니다.',
        'permission-denied',
      );

  factory DeleteTodoException.unknown([String? message]) => DeleteTodoException(
        message ?? 'Todo 삭제 중 알 수 없는 오류가 발생했습니다.',
        'unknown',
      );
}

/// Todo 조회 실패 예외
class GetTodoException extends TodoException {
  const GetTodoException(super.message, [super.code]);

  factory GetTodoException.notFound() => const GetTodoException(
        'Todo를 찾을 수 없습니다.',
        'todo-not-found',
      );

  factory GetTodoException.permissionDenied() => const GetTodoException(
        'Todo를 조회할 권한이 없습니다.',
        'permission-denied',
      );

  factory GetTodoException.invalidCoupleId() => const GetTodoException(
        '유효하지 않은 커플 정보입니다.',
        'invalid-couple-id',
      );

  factory GetTodoException.unknown([String? message]) => GetTodoException(
        message ?? 'Todo 조회 중 알 수 없는 오류가 발생했습니다.',
        'unknown',
      );
}
