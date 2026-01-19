# SPEC-TODO-001 구현 계획

---
spec_id: SPEC-TODO-001
version: 1.0.0
created: 2026-01-19
updated: 2026-01-19
author: woogi
---

## 1. 개요

WeDo 커플 투두 시스템의 구현 계획서입니다. Flutter와 Firebase를 기반으로 Android APK를 개발합니다.

---

## 2. 기술 스택 상세

### 2.1 Core Framework

| 기술 | 버전 | 용도 |
|------|------|------|
| Flutter | 3.27.x | 크로스 플랫폼 UI 프레임워크 |
| Dart | 3.6.x | 프로그래밍 언어 |

### 2.2 Firebase Services

| 서비스 | 용도 | 구성 |
|--------|------|------|
| Firebase Auth | 사용자 인증 | Email/Password |
| Cloud Firestore | 실시간 데이터베이스 | 오프라인 persistence 활성화 |
| Firebase Cloud Messaging | 푸시 알림 | Android 전용 |
| Firebase Analytics | 사용 분석 | 선택적 |

### 2.3 상태 관리 및 의존성

| 패키지 | 버전 | 용도 |
|--------|------|------|
| flutter_riverpod | ^2.5.x | 상태 관리 |
| go_router | ^14.x | 라우팅 |
| freezed | ^2.5.x | 불변 데이터 클래스 |
| hive_flutter | ^1.1.x | 로컬 저장소 |
| intl | ^0.19.x | 날짜/시간 포맷 |

### 2.4 Firebase 패키지

| 패키지 | 용도 |
|--------|------|
| firebase_core | Firebase 초기화 |
| firebase_auth | 인증 |
| cloud_firestore | 데이터베이스 |
| firebase_messaging | 푸시 알림 |

---

## 3. 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── app.dart                  # MaterialApp 설정
├── firebase_options.dart     # Firebase 설정 (자동 생성)
│
├── core/                     # 공통 모듈
│   ├── constants/            # 상수 정의
│   ├── exceptions/           # 커스텀 예외
│   ├── extensions/           # Dart 확장 메서드
│   ├── router/               # GoRouter 설정
│   ├── theme/                # 앱 테마
│   └── utils/                # 유틸리티 함수
│
├── features/                 # 기능별 모듈
│   ├── auth/                 # 인증 기능
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── couple/               # 커플 매칭 기능
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── todo/                 # 투두 기능
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── settings/             # 설정 기능
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── shared/                   # 공유 컴포넌트
│   ├── models/               # 공통 모델
│   ├── providers/            # 공통 Provider
│   ├── services/             # 공통 서비스
│   └── widgets/              # 공통 위젯
│
└── l10n/                     # 다국어 (한국어 기본)
    └── app_ko.arb
```

---

## 4. 아키텍처 설계

### 4.1 Clean Architecture 적용

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  (Widgets, Pages, Providers, ViewModels)                │
├─────────────────────────────────────────────────────────┤
│                      Domain Layer                        │
│  (Entities, Use Cases, Repository Interfaces)           │
├─────────────────────────────────────────────────────────┤
│                       Data Layer                         │
│  (Repository Impl, Data Sources, DTOs)                  │
└─────────────────────────────────────────────────────────┘
```

### 4.2 데이터 흐름

```
User Action
    │
    ▼
Widget (UI)
    │
    ▼
Provider (State Management)
    │
    ▼
Use Case (Business Logic)
    │
    ▼
Repository (Data Access)
    │
    ├──► Firestore (Remote)
    │
    └──► Hive (Local Cache)
```

### 4.3 오프라인 우선 전략

1. **Firestore Offline Persistence**: 자동 로컬 캐싱
2. **Optimistic Update**: UI 즉시 반영, 백그라운드 동기화
3. **Conflict Resolution**: 최신 timestamp 우선

---

## 5. 구현 마일스톤

### Milestone 1: 핵심 인프라 (Primary Goal)

**목표**: 프로젝트 기반 및 인증 시스템 구축

| 태스크 ID | 태스크 | 설명 |
|-----------|--------|------|
| M1-T01 | 프로젝트 초기화 | Flutter 프로젝트 생성, 의존성 설정 |
| M1-T02 | Firebase 연동 | Firebase 프로젝트 생성, SDK 연동 |
| M1-T03 | 프로젝트 구조 설정 | 디렉토리 구조, 기본 설정 파일 |
| M1-T04 | 테마 및 스타일 | 앱 테마, 색상, 타이포그래피 정의 |
| M1-T05 | 라우팅 설정 | GoRouter 설정, 인증 가드 |
| M1-T06 | 인증 기능 구현 | 회원가입, 로그인, 로그아웃 |
| M1-T07 | 사용자 모델 구현 | User 엔티티, Firestore CRUD |

**완료 기준**:
- 회원가입/로그인/로그아웃 동작
- Firebase 콘솔에서 사용자 확인 가능

---

### Milestone 2: 커플 시스템 (Secondary Goal)

**목표**: 커플 매칭 및 데이터 공유 기반 구축

| 태스크 ID | 태스크 | 설명 |
|-----------|--------|------|
| M2-T01 | 커플 모델 구현 | Couple 엔티티, Firestore 구조 |
| M2-T02 | 초대 코드 생성 | 6자리 랜덤 코드 생성 로직 |
| M2-T03 | 초대 코드 입력 | 코드 검증 및 커플 매칭 |
| M2-T04 | 커플 상태 관리 | Provider를 통한 커플 상태 |
| M2-T05 | 커플 설정 화면 | 초대 코드 표시/입력 UI |

**완료 기준**:
- 초대 코드로 두 사용자 매칭 가능
- 커플 관계 Firestore에 저장

---

### Milestone 3: 투두 핵심 기능 (Tertiary Goal)

**목표**: 투두 CRUD 및 실시간 동기화

| 태스크 ID | 태스크 | 설명 |
|-----------|--------|------|
| M3-T01 | 투두 모델 구현 | Todo 엔티티, Firestore 구조 |
| M3-T02 | 투두 생성 | 제목, 설명, 카테고리, 날짜/시간 |
| M3-T03 | 투두 목록 조회 | 실시간 스트림, 필터링 |
| M3-T04 | 투두 수정 | 상세 수정 기능 |
| M3-T05 | 투두 삭제 | 삭제 확인, Soft delete 고려 |
| M3-T06 | 투두 완료 처리 | 완료 토글, 완료자 기록 |
| M3-T07 | 홈 화면 구현 | 투두 목록 UI |
| M3-T08 | 투두 상세 화면 | 상세 보기/수정 UI |
| M3-T09 | 투두 생성 화면 | 생성 폼 UI |

**완료 기준**:
- 투두 CRUD 동작
- 파트너 투두 실시간 표시

---

### Milestone 4: 보기 모드 및 필터 (Quaternary Goal)

**목표**: 다양한 보기 옵션 제공

| 태스크 ID | 태스크 | 설명 |
|-----------|--------|------|
| M4-T01 | 일간 보기 | 특정 날짜 투두 필터링 |
| M4-T02 | 주간 보기 | 주간 투두 목록 표시 |
| M4-T03 | 월간 보기 | 캘린더 형태 월간 보기 |
| M4-T04 | 카테고리 필터 | 카테고리별 필터링 |
| M4-T05 | 완료/미완료 필터 | 상태별 필터링 |
| M4-T06 | 날짜 선택 UI | DatePicker 통합 |

**완료 기준**:
- 일간/주간/월간 보기 전환 가능
- 필터 조합 동작

---

### Milestone 5: 푸시 알림 (Quinary Goal)

**목표**: FCM 기반 파트너 알림

| 태스크 ID | 태스크 | 설명 |
|-----------|--------|------|
| M5-T01 | FCM 설정 | Firebase Messaging 연동 |
| M5-T02 | FCM 토큰 관리 | 토큰 저장/갱신 로직 |
| M5-T03 | 알림 권한 요청 | Android 알림 권한 |
| M5-T04 | 알림 전송 로직 | Cloud Functions 또는 클라이언트 전송 |
| M5-T05 | 알림 수신 처리 | Foreground/Background 알림 |
| M5-T06 | 알림 설정 화면 | 알림 ON/OFF 설정 |

**완료 기준**:
- 파트너 CRUD 시 알림 수신
- 알림 설정 동작

---

### Milestone 6: 오프라인 지원 및 최적화 (Final Goal)

**목표**: 오프라인 안정성 및 성능 최적화

| 태스크 ID | 태스크 | 설명 |
|-----------|--------|------|
| M6-T01 | Firestore 오프라인 설정 | Persistence 활성화 |
| M6-T02 | 오프라인 상태 표시 | 연결 상태 UI 표시 |
| M6-T03 | 동기화 충돌 처리 | Conflict resolution 로직 |
| M6-T04 | 성능 최적화 | 불필요한 리빌드 제거 |
| M6-T05 | APK 빌드 및 테스트 | Release APK 생성 |
| M6-T06 | 버그 수정 및 QA | 전체 기능 테스트 |

**완료 기준**:
- 오프라인에서 앱 사용 가능
- 안정적인 APK 배포

---

### Milestone 7: 선택적 기능 (Optional Goal)

**목표**: 부가 기능 (시간 여유 시)

| 태스크 ID | 태스크 | 설명 |
|-----------|--------|------|
| M7-T01 | 다크 모드 | 테마 전환 기능 |
| M7-T02 | 투두 반복 설정 | 매일/매주/매월 반복 |
| M7-T03 | 투두 우선순위 | High/Medium/Low 우선순위 |
| M7-T04 | 홈 위젯 | Android 위젯 |
| M7-T05 | 기념일 알림 | 특별 날짜 알림 |

**완료 기준**:
- 각 기능 독립적 동작

---

## 6. 기술적 접근

### 6.1 인증 흐름

```
App Start
    │
    ▼
FirebaseAuth.authStateChanges()
    │
    ├── User != null ──► Check Couple Status
    │                         │
    │                         ├── Has Couple ──► Home
    │                         │
    │                         └── No Couple ──► CoupleSetup
    │
    └── User == null ──► Login
```

### 6.2 실시간 동기화 전략

```dart
// Firestore 스트림 구독
final todosStream = FirebaseFirestore.instance
    .collection('couples')
    .doc(coupleId)
    .collection('todos')
    .orderBy('createdAt', descending: true)
    .snapshots();

// Riverpod StreamProvider
final todosProvider = StreamProvider<List<Todo>>((ref) {
  final coupleId = ref.watch(currentCoupleIdProvider);
  return TodoRepository().watchTodos(coupleId);
});
```

### 6.3 푸시 알림 전송 방식

**Option A: Cloud Functions (권장)**
- 서버리스 함수로 안전한 알림 전송
- 파트너 FCM 토큰 노출 방지

**Option B: 클라이언트 직접 전송**
- HTTP v1 API 사용
- 구현 단순, 보안 주의 필요

---

## 7. 위험 분석 및 대응

| 위험 | 가능성 | 영향 | 대응 방안 |
|------|--------|------|-----------|
| Firebase 비용 초과 | Low | High | 사용량 모니터링, 알림 설정 |
| 실시간 동기화 지연 | Medium | Medium | 낙관적 업데이트, 로딩 상태 표시 |
| FCM 알림 미도달 | Medium | Medium | 알림 실패 시 재시도 로직 |
| 오프라인 데이터 충돌 | Medium | Medium | Timestamp 기반 충돌 해결 |
| 앱 크기 증가 | Low | Low | 이미지 최적화, 불필요한 패키지 제거 |

---

## 8. 개발 환경 설정

### 8.1 Flutter 설정

```bash
# Flutter 버전 확인
flutter --version

# 의존성 설치
flutter pub get

# Firebase CLI 설치
npm install -g firebase-tools

# FlutterFire CLI 설치
dart pub global activate flutterfire_cli

# Firebase 초기화
flutterfire configure
```

### 8.2 필수 환경 변수

```bash
# Firebase 프로젝트 ID
FIREBASE_PROJECT_ID=wedo-app

# Android 패키지 이름
ANDROID_PACKAGE_NAME=com.wedo.app
```

---

## 9. 품질 기준

### 9.1 코드 품질

- Dart Analysis: 0 warnings, 0 errors
- 코드 커버리지: 70% 이상 (핵심 로직)
- 일관된 코드 스타일: `flutter_lints` 적용

### 9.2 성능 기준

- 앱 콜드 스타트: < 3초
- 화면 전환: < 300ms
- 투두 목록 로딩: < 1초

### 9.3 테스트 전략

| 테스트 유형 | 범위 | 도구 |
|-------------|------|------|
| Unit Test | 비즈니스 로직, 유틸리티 | flutter_test |
| Widget Test | UI 컴포넌트 | flutter_test |
| Integration Test | 전체 흐름 | integration_test |

---

## 10. 추적성

### 관련 문서

| 문서 | 경로 |
|------|------|
| SPEC 문서 | `.moai/specs/SPEC-TODO-001/spec.md` |
| 인수 기준 | `.moai/specs/SPEC-TODO-001/acceptance.md` |

---

**문서 끝**
