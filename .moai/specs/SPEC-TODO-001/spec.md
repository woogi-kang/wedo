# SPEC-TODO-001: WeDo 커플 투두 시스템

---
id: SPEC-TODO-001
version: 1.0.0
status: Planned
created: 2026-01-19
updated: 2026-01-19
author: woogi
priority: HIGH
lifecycle: spec-anchored
tags: [flutter, firebase, todo, couple, real-time-sync]
---

## HISTORY

| 버전 | 날짜 | 작성자 | 변경 내용 |
|------|------|--------|-----------|
| 1.0.0 | 2026-01-19 | woogi | 초기 SPEC 문서 작성 |

---

## 1. Environment (환경)

### 1.1 기술 스택

| 구분 | 기술 | 버전 |
|------|------|------|
| Framework | Flutter | 3.27.x |
| Language | Dart | 3.6.x |
| Backend | Firebase | Latest |
| Database | Cloud Firestore | Latest |
| Push Notification | Firebase Cloud Messaging (FCM) | Latest |
| Authentication | Firebase Auth | Latest |
| State Management | Riverpod | 2.x |
| Local Storage | Hive / SharedPreferences | Latest |

### 1.2 대상 플랫폼

- **Android**: APK 배포 (minSdkVersion: 24, targetSdkVersion: 34)
- iOS 미지원 (향후 확장 고려)

### 1.3 개발 환경

- IDE: Android Studio / VS Code
- Version Control: Git
- CI/CD: GitHub Actions (선택적)

---

## 2. Assumptions (가정)

### 2.1 기술적 가정

| ID | 가정 | 신뢰도 | 근거 | 실패 시 위험 | 검증 방법 |
|----|------|--------|------|--------------|-----------|
| A-001 | Firebase Free Tier로 초기 사용자 수용 가능 | High | Spark Plan 제공 리소스 충분 | 비용 발생 | Firebase Console 모니터링 |
| A-002 | Firestore 실시간 동기화 지연 < 500ms | High | Firebase 문서 기준 | UX 저하 | 성능 테스트 |
| A-003 | FCM 푸시 알림 도달률 > 95% | Medium | FCM 공식 SLA | 알림 누락 | 알림 로그 분석 |
| A-004 | 오프라인 모드에서 로컬 데이터 무결성 유지 | High | Firestore offline persistence | 데이터 손실 | 오프라인 테스트 |

### 2.2 비즈니스 가정

| ID | 가정 | 신뢰도 | 근거 |
|----|------|--------|------|
| B-001 | 커플 사용자 1:1 매칭 | High | 제품 요구사항 |
| B-002 | 사용자는 하나의 커플 관계만 가짐 | High | 제품 요구사항 |
| B-003 | 초기 사용자 규모 < 1,000명 | Medium | MVP 단계 |

---

## 3. Requirements (요구사항)

### 3.1 Ubiquitous Requirements (항상 적용)

> 시스템은 **항상** [동작]해야 한다

| ID | 요구사항 | 우선순위 |
|----|----------|----------|
| U-001 | 시스템은 **항상** 사용자 인증 상태를 확인해야 한다 | HIGH |
| U-002 | 시스템은 **항상** 데이터 변경 시 Firestore에 동기화해야 한다 | HIGH |
| U-003 | 시스템은 **항상** 오프라인 상태에서도 로컬 데이터에 접근 가능해야 한다 | HIGH |
| U-004 | 시스템은 **항상** 한국어 UI를 제공해야 한다 | MEDIUM |
| U-005 | 시스템은 **항상** 로딩 상태를 시각적으로 표시해야 한다 | MEDIUM |

### 3.2 Event-Driven Requirements (이벤트 기반)

> **WHEN** [이벤트] **THEN** [동작]

| ID | 이벤트 | 동작 | 우선순위 |
|----|--------|------|----------|
| E-001 | **WHEN** 사용자가 투두를 생성 **THEN** 파트너에게 푸시 알림 전송 | HIGH |
| E-002 | **WHEN** 사용자가 투두를 완료 처리 **THEN** 파트너에게 푸시 알림 전송 | HIGH |
| E-003 | **WHEN** 사용자가 투두를 수정 **THEN** 파트너에게 푸시 알림 전송 | MEDIUM |
| E-004 | **WHEN** 사용자가 투두를 삭제 **THEN** 파트너에게 푸시 알림 전송 | MEDIUM |
| E-005 | **WHEN** 커플 초대 코드 입력 **THEN** 커플 매칭 수행 | HIGH |
| E-006 | **WHEN** 앱이 포그라운드 전환 **THEN** 데이터 동기화 수행 | MEDIUM |
| E-007 | **WHEN** 네트워크 연결 복구 **THEN** 오프라인 변경사항 동기화 | HIGH |

### 3.3 State-Driven Requirements (상태 기반)

> **IF** [조건] **THEN** [동작]

| ID | 조건 | 동작 | 우선순위 |
|----|------|------|----------|
| S-001 | **IF** 커플 매칭 완료 상태 **THEN** 파트너 투두 목록 표시 | HIGH |
| S-002 | **IF** 오프라인 상태 **THEN** 로컬 캐시에서 데이터 로드 | HIGH |
| S-003 | **IF** 일간 보기 모드 **THEN** 선택된 날짜의 투두만 표시 | HIGH |
| S-004 | **IF** 주간 보기 모드 **THEN** 해당 주의 투두 목록 표시 | HIGH |
| S-005 | **IF** 월간 보기 모드 **THEN** 해당 월의 투두 캘린더 표시 | HIGH |
| S-006 | **IF** 알림 권한 미허용 **THEN** 알림 권한 요청 다이얼로그 표시 | MEDIUM |

### 3.4 Unwanted Requirements (금지 사항)

> 시스템은 [동작]**하지 않아야 한다**

| ID | 금지 동작 | 이유 | 우선순위 |
|----|-----------|------|----------|
| N-001 | 시스템은 비인증 사용자에게 데이터를 노출**하지 않아야 한다** | 보안 | HIGH |
| N-002 | 시스템은 다른 커플의 데이터에 접근**하지 않아야 한다** | 프라이버시 | HIGH |
| N-003 | 시스템은 사용자 동의 없이 위치 정보를 수집**하지 않아야 한다** | 개인정보보호 | HIGH |
| N-004 | 시스템은 오프라인 시 데이터 손실이 발생**하지 않아야 한다** | 데이터 무결성 | HIGH |
| N-005 | 시스템은 파트너 매칭 전에 공유 기능을 제공**하지 않아야 한다** | 비즈니스 로직 | MEDIUM |

### 3.5 Optional Requirements (선택적)

> **가능하면** [동작] 제공

| ID | 기능 | 설명 | 우선순위 |
|----|------|------|----------|
| O-001 | **가능하면** 다크 모드 지원 제공 | 사용자 편의성 | LOW |
| O-002 | **가능하면** 투두 반복 설정 기능 제공 | 일정 관리 편의 | LOW |
| O-003 | **가능하면** 투두 우선순위 설정 기능 제공 | 일정 관리 편의 | LOW |
| O-004 | **가능하면** 위젯 지원 제공 | 빠른 접근성 | LOW |
| O-005 | **가능하면** 커플 기념일 알림 기능 제공 | 부가 기능 | LOW |

---

## 4. Specifications (세부 명세)

### 4.1 데이터 모델

#### User

```dart
class User {
  final String uid;
  final String email;
  final String displayName;
  final String? coupleId;      // 커플 관계 ID
  final String? partnerId;     // 파트너 사용자 ID
  final String? fcmToken;      // FCM 토큰
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

#### Couple

```dart
class Couple {
  final String id;
  final String inviteCode;     // 6자리 초대 코드
  final List<String> members;  // 2명의 사용자 ID
  final DateTime createdAt;
  final DateTime? connectedAt; // 매칭 완료 시간
}
```

#### Todo

```dart
class Todo {
  final String id;
  final String coupleId;       // 소속 커플 ID
  final String creatorId;      // 생성자 ID
  final String title;
  final String? description;
  final String? category;      // 카테고리
  final DateTime? dueDate;     // 마감 날짜
  final TimeOfDay? dueTime;    // 마감 시간
  final bool isCompleted;
  final String? completedBy;   // 완료 처리자 ID
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 4.2 Firestore 구조

```
/users/{userId}
  - uid: string
  - email: string
  - displayName: string
  - coupleId: string?
  - partnerId: string?
  - fcmToken: string?
  - createdAt: timestamp
  - updatedAt: timestamp

/couples/{coupleId}
  - id: string
  - inviteCode: string
  - members: array<string>
  - createdAt: timestamp
  - connectedAt: timestamp?

/couples/{coupleId}/todos/{todoId}
  - id: string
  - coupleId: string
  - creatorId: string
  - title: string
  - description: string?
  - category: string?
  - dueDate: timestamp?
  - dueTime: string?
  - isCompleted: boolean
  - completedBy: string?
  - createdAt: timestamp
  - updatedAt: timestamp
```

### 4.3 화면 구성

| 화면 | 설명 | 주요 기능 |
|------|------|-----------|
| Splash | 앱 시작 화면 | 인증 상태 확인, 라우팅 |
| Login | 로그인 화면 | 이메일/비밀번호 로그인, 회원가입 링크 |
| SignUp | 회원가입 화면 | 이메일/비밀번호 회원가입 |
| CoupleSetup | 커플 설정 화면 | 초대 코드 생성/입력 |
| Home | 메인 화면 | 투두 목록, 보기 모드 전환 |
| TodoDetail | 투두 상세 화면 | 투두 상세 보기/수정 |
| TodoCreate | 투두 생성 화면 | 새 투두 생성 |
| Settings | 설정 화면 | 알림 설정, 계정 관리, 로그아웃 |

### 4.4 카테고리 목록

기본 제공 카테고리:
- 집안일
- 쇼핑
- 약속
- 기념일
- 운동
- 기타

### 4.5 알림 유형

| 유형 | 제목 | 내용 |
|------|------|------|
| TODO_CREATED | 새로운 할 일 | {파트너명}님이 "{투두제목}"을 추가했어요 |
| TODO_COMPLETED | 할 일 완료 | {파트너명}님이 "{투두제목}"을 완료했어요 |
| TODO_UPDATED | 할 일 수정 | {파트너명}님이 "{투두제목}"을 수정했어요 |
| TODO_DELETED | 할 일 삭제 | {파트너명}님이 "{투두제목}"을 삭제했어요 |

---

## 5. Traceability (추적성)

### 관련 문서

| 문서 | 경로 | 설명 |
|------|------|------|
| 구현 계획 | `.moai/specs/SPEC-TODO-001/plan.md` | 구현 마일스톤 및 기술 전략 |
| 인수 기준 | `.moai/specs/SPEC-TODO-001/acceptance.md` | Given-When-Then 테스트 시나리오 |

### 요구사항 매핑

| 요구사항 ID | 테스트 시나리오 ID | 구현 우선순위 |
|-------------|-------------------|---------------|
| U-001 ~ U-005 | AC-001, AC-002 | Milestone 1 |
| E-001 ~ E-007 | AC-003 ~ AC-007 | Milestone 2 |
| S-001 ~ S-006 | AC-008 ~ AC-013 | Milestone 2 |
| N-001 ~ N-005 | AC-014 ~ AC-018 | Milestone 1 |
| O-001 ~ O-005 | AC-019 ~ AC-023 | Milestone 3 |

---

## 6. Constraints (제약사항)

### 기술적 제약

- Flutter 3.27.x 버전 사용 필수
- Firebase Free Tier (Spark Plan) 범위 내 운영
- Android API Level 24 (Android 7.0) 이상 지원
- 오프라인 우선 아키텍처 적용

### 비기능적 제약

- 앱 시작 시간: < 3초
- 투두 목록 로딩: < 1초
- 실시간 동기화 지연: < 500ms
- 앱 크기: < 50MB

---

**문서 끝**
