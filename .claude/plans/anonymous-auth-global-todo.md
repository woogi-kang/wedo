# WeDo 앱 - Anonymous 인증 + 전역 Todo 공유 구현 계획

## 개요
기존 이메일/비밀번호 + 커플 기반 시스템을 **Firebase Anonymous 인증 + 전역 Todo 공유**로 전환합니다.
기존 코드는 보존하고, 새로운 흐름을 추가합니다.

## 새로운 앱 흐름
```
앱 실행 → SplashPage (자동 Anonymous 로그인)
       → displayName 없음 → NameInputPage (이름 입력)
       → displayName 있음 → HomePage (전역 Todo 공유)
```

## Firestore 구조 변경
```
기존: /couples/{coupleId}/todos/{todoId}
신규: /todos/{todoId}  (전역 컬렉션)
```

---

## Phase 1: Anonymous 인증 추가

### 1.1 AuthRemoteDataSource 확장
**파일**: `lib/features/auth/data/datasources/auth_remote_datasource.dart`

추가할 메서드:
- `signInAnonymously()` - Firebase Anonymous 로그인
- `updateDisplayName(String)` - 이름 설정 및 Firestore 저장
- `hasUserDocument(String uid)` - 프로필 완성 여부 확인

### 1.2 AuthRepository 확장
**파일**: `lib/features/auth/domain/repositories/auth_repository.dart`
**파일**: `lib/features/auth/data/repositories/auth_repository_impl.dart`

인터페이스에 새 메서드 추가 및 구현

### 1.3 AuthProvider 수정
**파일**: `lib/features/auth/presentation/providers/auth_provider.dart`

- `hasCompleteProfileProvider` 추가 - displayName 존재 여부 확인
- `AuthController`에 `signInAnonymously()`, `setDisplayName()` 메서드 추가

---

## Phase 2: 이름 입력 화면 생성

### 2.1 NameInputPage 생성
**파일**: `lib/features/auth/presentation/pages/name_input_page.dart` (신규)

- 간단한 이름 입력 폼 (2-20자)
- 저장 후 Router가 자동으로 HomePage로 이동

### 2.2 Routes 추가
**파일**: `lib/core/router/routes.dart`

- `nameInput = '/name-input'` 추가

---

## Phase 3: Router 수정

### 3.1 AppRouter 수정
**파일**: `lib/core/router/app_router.dart`

핵심 변경:
- `coupleConnectionStateProvider` → `hasCompleteProfileStateProvider`로 교체
- redirect 로직: 커플 확인 대신 프로필(displayName) 확인
- `/name-input` 라우트 추가

### 3.2 SplashPage 수정
**파일**: `lib/features/auth/presentation/pages/splash_page.dart`

- `initState`에서 자동 Anonymous 로그인 호출

---

## Phase 4: Todo 시스템 전역화

### 4.1 Todo Entity 수정
**파일**: `lib/features/todo/domain/entities/todo.dart`

- `coupleId` 필드 제거 (또는 nullable로 변경)
- `creatorName`, `completedByName` 필드 추가

### 4.2 TodoModel 수정
**파일**: `lib/features/todo/data/models/todo_model.dart`

- `coupleId` nullable로 변경
- 새 필드 추가 및 JSON 직렬화 수정

### 4.3 TodoRemoteDataSource 수정
**파일**: `lib/features/todo/data/datasources/todo_remote_datasource.dart`

- `/todos` 전역 컬렉션 사용
- 모든 메서드에서 `coupleId` 파라미터 제거

### 4.4 TodoRepository 수정
**파일**: `lib/features/todo/domain/repositories/todo_repository.dart`
**파일**: `lib/features/todo/data/repositories/todo_repository_impl.dart`

- `coupleId` 파라미터 제거

### 4.5 TodoProvider 수정
**파일**: `lib/features/todo/presentation/providers/todo_provider.dart`

- `todosStreamProvider`에서 커플 의존성 제거
- `TodoController`에서 커플 관련 로직 제거
- 알림 로직 제거 (전역 공유이므로 파트너 알림 불필요)

---

## Phase 5: UI 수정

### 5.1 HomePage 수정
**파일**: `lib/features/todo/presentation/pages/home_page.dart`

- 커플 상태 관련 코드 제거/비활성화
- `partnerName` 참조 제거

### 5.2 SettingsPage 수정
**파일**: `lib/features/settings/presentation/pages/settings_page.dart`

- 커플 정보 섹션 숨기기
- 로그아웃 경고 메시지 수정 (Anonymous 계정 데이터 유실 안내)

---

## Phase 6: Firestore 규칙 업데이트

**파일**: `firestore.rules`

```javascript
match /todos/{todoId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null
    && request.resource.data.creatorId == request.auth.uid;
  allow update: if request.auth != null;
  allow delete: if request.auth != null
    && resource.data.creatorId == request.auth.uid;
}
```

---

## 수정할 파일 목록

| 파일 | 작업 |
|------|------|
| `lib/features/auth/data/datasources/auth_remote_datasource.dart` | Anonymous 로그인 추가 |
| `lib/features/auth/domain/repositories/auth_repository.dart` | 인터페이스 확장 |
| `lib/features/auth/data/repositories/auth_repository_impl.dart` | 구현 추가 |
| `lib/features/auth/presentation/providers/auth_provider.dart` | Provider/Controller 수정 |
| `lib/features/auth/presentation/pages/name_input_page.dart` | **신규 생성** |
| `lib/features/auth/presentation/pages/splash_page.dart` | 자동 로그인 추가 |
| `lib/core/router/routes.dart` | nameInput 라우트 추가 |
| `lib/core/router/app_router.dart` | 라우팅 로직 변경 |
| `lib/features/todo/domain/entities/todo.dart` | coupleId 제거, 이름 필드 추가 |
| `lib/features/todo/data/models/todo_model.dart` | 모델 수정 |
| `lib/features/todo/data/datasources/todo_remote_datasource.dart` | 전역 컬렉션 사용 |
| `lib/features/todo/domain/repositories/todo_repository.dart` | 인터페이스 수정 |
| `lib/features/todo/data/repositories/todo_repository_impl.dart` | 구현 수정 |
| `lib/features/todo/presentation/providers/todo_provider.dart` | 커플 의존성 제거 |
| `lib/features/todo/presentation/pages/home_page.dart` | 커플 관련 코드 제거 |
| `lib/features/settings/presentation/pages/settings_page.dart` | 커플 섹션 숨기기 |
| `firestore.rules` | 전역 Todo 규칙 추가 |

---

## 구현 순서

1. Phase 1: Auth 시스템 확장 (Anonymous 로그인)
2. Phase 2: NameInputPage 생성
3. Phase 3: Router 수정
4. **중간 테스트**: Anonymous 로그인 → 이름 입력 → Home 진입 확인
5. Phase 4: Todo 시스템 전역화
6. Phase 5: UI 수정
7. Phase 6: Firestore 규칙 업데이트
8. **최종 테스트**: 전체 흐름 검증

---

## 검증 방법

### 기능 테스트
1. 앱 첫 실행 → 자동 Anonymous 로그인 확인
2. 이름 입력 화면 표시 확인
3. 이름 입력 후 HomePage 이동 확인
4. Todo 생성/수정/삭제 기능 확인
5. 다른 기기에서 같은 Todo 목록 표시 확인 (전역 공유)

### 코드 검증
```bash
flutter analyze
flutter build apk --debug
```

---

## 보존되는 기존 코드
- `lib/features/auth/presentation/pages/login_page.dart`
- `lib/features/auth/presentation/pages/signup_page.dart`
- `lib/features/couple/` 전체 디렉토리
- Firestore의 `/couples` 컬렉션 관련 규칙
