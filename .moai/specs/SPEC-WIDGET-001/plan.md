# SPEC-WIDGET-001: 구현 계획서

---
spec_id: SPEC-WIDGET-001
version: 1.0.0
created: 2026-01-21
updated: 2026-01-21
author: woogi
---

## 1. 구현 개요

### 1.1 목표

WeDo 커플 투두 앱에 Android 홈 위젯 기능을 추가하여 사용자가 앱을 열지 않고도 빠르게 Todo 일정을 확인할 수 있도록 함.

### 1.2 범위

- Weekly Todo Widget: 이번 주 Todo 목록 표시 (4x2 또는 4x3)
- Calendar Widget: 월간 캘린더와 일별 Todo 개수 표시 (4x4)
- Flutter-Android 데이터 브릿지 구현
- 백그라운드 자동 업데이트 시스템

### 1.3 범위 외 (Out of Scope)

- iOS 위젯 (향후 별도 SPEC으로 진행)
- 위젯 내 Todo 생성/수정/삭제 기능
- 위젯 내 푸시 알림 표시

---

## 2. 마일스톤 계획

### Phase 1: 기반 인프라 구축 (Primary Goal)

**목표**: Flutter-Android 데이터 브릿지 및 기본 위젯 프레임워크 구축

| 태스크 | 설명 | 산출물 | 의존성 |
|--------|------|--------|--------|
| T-1.1 | home_widget 패키지 통합 | pubspec.yaml, 기본 설정 | - |
| T-1.2 | WidgetDataSync 서비스 구현 | lib/features/widget/ | T-1.1 |
| T-1.3 | SharedPreferences 데이터 스키마 정의 | JSON schema 문서 | - |
| T-1.4 | Android 위젯 기본 구조 생성 | Kotlin 파일, XML 레이아웃 | - |
| T-1.5 | AndroidManifest.xml 위젯 등록 | manifest 수정 | T-1.4 |
| T-1.6 | 기본 데이터 동기화 POC | 동작 검증 | T-1.2, T-1.4 |

**완료 기준**:
- home_widget 패키지 설치 및 기본 설정 완료
- Flutter → SharedPreferences → Android Widget 데이터 흐름 검증
- 빈 위젯이 홈 화면에 추가 가능

### Phase 2: Weekly Todo Widget 구현 (Secondary Goal)

**목표**: 주간 Todo 목록 위젯 완전 구현

| 태스크 | 설명 | 산출물 | 의존성 |
|--------|------|--------|--------|
| T-2.1 | 주간 위젯 레이아웃 구현 | widget_weekly_todo.xml | Phase 1 |
| T-2.2 | 위젯 아이템 레이아웃 구현 | widget_weekly_todo_item.xml | T-2.1 |
| T-2.3 | WeeklyTodoWidgetProvider 구현 | Kotlin 클래스 | T-2.1 |
| T-2.4 | 주간 Todo 데이터 쿼리 로직 | TodoRepository 확장 | - |
| T-2.5 | 위젯 데이터 직렬화/역직렬화 | WidgetDataManager.kt | T-2.3 |
| T-2.6 | 탭 → 앱 실행 Deep Link 구현 | PendingIntent, GoRouter | T-2.3 |
| T-2.7 | 새로고침 버튼 기능 구현 | BroadcastReceiver | T-2.3 |
| T-2.8 | 완료/미완료 상태 스타일링 | 취소선, 색상 | T-2.2 |

**완료 기준**:
- 주간 Todo 목록이 위젯에 정상 표시
- 항목 탭 시 앱의 해당 날짜로 이동
- 완료/미완료 상태가 시각적으로 구분됨
- 새로고침 버튼 동작

### Phase 3: Calendar Widget 구현 (Tertiary Goal)

**목표**: 월간 캘린더 위젯 완전 구현

| 태스크 | 설명 | 산출물 | 의존성 |
|--------|------|--------|--------|
| T-3.1 | 캘린더 위젯 메인 레이아웃 구현 | widget_calendar.xml | Phase 1 |
| T-3.2 | 캘린더 날짜 셀 레이아웃 구현 | widget_calendar_day.xml | T-3.1 |
| T-3.3 | CalendarWidgetProvider 구현 | Kotlin 클래스 | T-3.1 |
| T-3.4 | 월별 Todo 개수 집계 로직 | 데이터 처리 | - |
| T-3.5 | 날짜 탭 → 앱 실행 구현 | PendingIntent | T-3.3 |
| T-3.6 | 이전/다음 월 네비게이션 구현 | 버튼 액션 | T-3.3 |
| T-3.7 | 스와이프 월 이동 구현 | ViewFlipper | T-3.3 |
| T-3.8 | 오늘 날짜 강조 표시 | UI 스타일링 | T-3.2 |

**완료 기준**:
- 월간 캘린더가 위젯에 정상 표시
- 각 날짜에 Todo 개수 뱃지 표시
- 날짜 탭 시 앱의 해당 날짜 일간 보기로 이동
- 월 이동 네비게이션 동작

### Phase 4: 백그라운드 동기화 시스템 (Final Goal)

**목표**: WorkManager 기반 자동 업데이트 시스템 구현

| 태스크 | 설명 | 산출물 | 의존성 |
|--------|------|--------|--------|
| T-4.1 | WorkManager 의존성 추가 | build.gradle.kts | - |
| T-4.2 | WidgetUpdateWorker 구현 | Kotlin Worker 클래스 | T-4.1 |
| T-4.3 | 4시간 주기 업데이트 스케줄링 구현 | PeriodicWorkRequest (4h) | T-4.2 |
| T-4.4 | 앱 포그라운드 트리거 구현 | LifecycleObserver | Phase 2, 3 |
| T-4.5 | Todo 변경 시 위젯 업데이트 연동 | TodoProvider 수정 | Phase 2, 3 |
| T-4.6 | 동기화 상태 표시 구현 | "마지막 동기화" 텍스트 | T-4.5 |
| T-4.7 | 배터리 최적화 대응 | Doze 모드 처리 | T-4.3 |

**완료 기준**:
- 4시간마다 위젯 데이터 자동 갱신
- 앱에서 Todo 변경 시 위젯 즉시 업데이트
- 마지막 동기화 시간 표시
- 배터리 소모 < 1% / 24시간

### Phase 5: 선택적 기능 및 최적화 (Optional Goal)

**목표**: UX 향상 및 최적화

| 태스크 | 설명 | 산출물 | 의존성 |
|--------|------|--------|--------|
| T-5.1 | 다크 모드 테마 지원 | 다크 모드 리소스 | Phase 2, 3 |
| T-5.2 | 위젯 크기 선택 옵션 (4x2, 4x3) | 설정 UI | T-2.1 |
| T-5.3 | 성능 최적화 | 프로파일링 및 개선 | Phase 4 |
| T-5.4 | 에러 상태 처리 UI | 에러 레이아웃 | Phase 2, 3 |
| T-5.5 | 통합 테스트 작성 | 테스트 코드 | 전체 |
| T-5.6 | 문서화 | README, 사용 가이드 | 전체 |

**완료 기준**:
- 시스템 다크 모드 연동
- 위젯 업데이트 시간 < 500ms
- 주요 시나리오 테스트 커버리지 > 80%

---

## 3. 기술 전략

### 3.1 데이터 흐름 아키텍처

```
┌──────────────────────────────────────────────────────────────┐
│                       Flutter Layer                           │
│                                                               │
│  ┌─────────────┐    ┌──────────────┐    ┌─────────────────┐  │
│  │ TodoProvider│───▶│WidgetDataSync│───▶│   home_widget   │  │
│  │  (Riverpod) │    │   Service    │    │    package      │  │
│  └─────────────┘    └──────────────┘    └────────┬────────┘  │
│         │                                         │          │
│         │ Stream                                  │ Platform │
│         ▼                                         │ Channel  │
│  ┌─────────────┐                                  │          │
│  │  Firestore  │                                  │          │
│  │  (Remote)   │                                  │          │
│  └─────────────┘                                  │          │
└───────────────────────────────────────────────────┼──────────┘
                                                    │
┌───────────────────────────────────────────────────▼──────────┐
│                      Android Layer                            │
│                                                               │
│  ┌─────────────────┐    ┌──────────────────┐                 │
│  │SharedPreferences│◀───│WidgetDataManager │                 │
│  │  (Local Cache)  │    │    (Kotlin)      │                 │
│  └────────┬────────┘    └──────────────────┘                 │
│           │                       ▲                          │
│           ▼                       │                          │
│  ┌─────────────────┐    ┌────────┴─────────┐                │
│  │ WidgetProvider  │───▶│  RemoteViews     │                │
│  │   (Kotlin)      │    │  (Widget UI)     │                │
│  └────────┬────────┘    └──────────────────┘                │
│           │                                                  │
│           ▼                                                  │
│  ┌─────────────────┐                                        │
│  │  WorkManager    │                                        │
│  │ (Background)    │                                        │
│  └─────────────────┘                                        │
└──────────────────────────────────────────────────────────────┘
```

### 3.2 핵심 컴포넌트 설계

#### 3.2.1 WidgetDataSync (Flutter)

```dart
/// 위젯 데이터 동기화 서비스
///
/// Todo 데이터를 위젯 포맷으로 변환하고
/// home_widget 패키지를 통해 Android로 전달
class WidgetDataSync {
  static const String weeklyKey = 'widget_todos_weekly';
  static const String calendarKey = 'widget_calendar_data';

  /// 주간 위젯 데이터 동기화
  Future<void> syncWeeklyWidget(List<Todo> todos) async {
    // 1. 이번 주 Todo 필터링
    // 2. WidgetTodo 형식으로 변환
    // 3. JSON 직렬화
    // 4. SharedPreferences 저장
    // 5. 위젯 업데이트 트리거
  }

  /// 캘린더 위젯 데이터 동기화
  Future<void> syncCalendarWidget(List<Todo> todos) async {
    // 1. 월별 Todo 집계
    // 2. 날짜별 개수 맵 생성
    // 3. JSON 직렬화
    // 4. SharedPreferences 저장
    // 5. 위젯 업데이트 트리거
  }
}
```

#### 3.2.2 WeeklyTodoWidgetProvider (Kotlin)

```kotlin
/// 주간 Todo 위젯 프로바이더
///
/// AppWidgetProvider를 상속하여 위젯 생명주기 관리
class WeeklyTodoWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // 1. SharedPreferences에서 데이터 로드
        // 2. RemoteViews 구성
        // 3. Todo 목록 렌더링
        // 4. 클릭 리스너 설정
        // 5. 위젯 업데이트
    }

    override fun onReceive(context: Context, intent: Intent) {
        // 브로드캐스트 수신 처리
        // - 새로고침 액션
        // - 아이템 클릭 액션
    }
}
```

#### 3.2.3 WidgetUpdateWorker (Kotlin)

```kotlin
/// 위젯 백그라운드 업데이트 워커
///
/// WorkManager를 통해 주기적으로 실행되어 위젯 갱신
class WidgetUpdateWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        // 1. 현재 시간 확인 (자정 여부)
        // 2. 캐시 데이터 유효성 검증
        // 3. 필요시 데이터 재계산
        // 4. 모든 위젯 인스턴스 업데이트
        // 5. 다음 실행 스케줄링
    }
}
```

### 3.3 Deep Link 전략

| 위젯 액션 | URI 패턴 | 앱 내 동작 |
|-----------|----------|-----------|
| Todo 항목 탭 | `wedo://todo/daily?date=YYYY-MM-DD` | HomePage로 이동, 해당 날짜 선택 |
| 캘린더 날짜 탭 | `wedo://todo/daily?date=YYYY-MM-DD` | HomePage로 이동, 해당 날짜 선택 |
| 위젯 빈 영역 탭 | `wedo://home` | HomePage 메인으로 이동 |

### 3.4 에러 처리 전략

| 에러 상황 | 위젯 표시 | 복구 전략 |
|-----------|----------|-----------|
| 데이터 없음 | "앱을 실행하여 데이터를 동기화하세요" | 앱 실행 유도 |
| 캐시 만료 (24h+) | "오래된 데이터입니다. 탭하여 새로고침" | 새로고침 버튼 활성화 |
| 파싱 에러 | "데이터 로드 오류" | 캐시 초기화 후 재동기화 |
| 위젯 업데이트 실패 | 이전 상태 유지 | 다음 주기에 재시도 |

---

## 4. 의존성 목록

### 4.1 Flutter 패키지

| 패키지 | 버전 | 용도 |
|--------|------|------|
| home_widget | ^0.7.0 | Flutter-Android 위젯 브릿지 |

### 4.2 Android 의존성

| 라이브러리 | 버전 | 용도 |
|-----------|------|------|
| androidx.work:work-runtime-ktx | 2.9.x | 백그라운드 작업 |
| androidx.glance:glance-appwidget | 1.1.x | (선택) Compose 기반 위젯 |
| com.google.code.gson:gson | 2.10.x | JSON 파싱 |

### 4.3 build.gradle.kts 추가 내용

```kotlin
dependencies {
    // WorkManager
    implementation("androidx.work:work-runtime-ktx:2.9.0")

    // JSON 파싱
    implementation("com.google.code.gson:gson:2.10.1")

    // 선택: Glance (Compose 기반 위젯)
    // implementation("androidx.glance:glance-appwidget:1.1.0")
}
```

---

## 5. 테스트 전략

### 5.1 단위 테스트

| 대상 | 테스트 항목 | 도구 |
|------|-------------|------|
| WidgetDataSync | 데이터 변환 정확성 | flutter_test |
| WeeklyWidgetData | JSON 직렬화/역직렬화 | flutter_test |
| CalendarWidgetData | 날짜 계산 정확성 | flutter_test |
| WidgetDataManager | SharedPreferences 읽기/쓰기 | JUnit, Robolectric |

### 5.2 통합 테스트

| 시나리오 | 검증 항목 |
|----------|----------|
| 위젯 추가 | 홈 화면에 정상 표시 |
| 데이터 동기화 | Flutter → Widget 데이터 전달 |
| 탭 액션 | 앱 실행 및 네비게이션 |
| 백그라운드 업데이트 | WorkManager 정상 동작 |

### 5.3 수동 테스트 체크리스트

- [ ] Android 7.0 (API 24) 기기 테스트
- [ ] Android 14 (API 34) 기기 테스트
- [ ] 배터리 최적화 모드에서 동작 확인
- [ ] 앱 강제 종료 후 위젯 동작 확인
- [ ] 기기 재부팅 후 위젯 복원 확인
- [ ] 다크 모드 전환 시 테마 적용 확인

---

## 6. 위험 대응 계획

### R-001: WorkManager 지연 이슈

**증상**: 배터리 최적화로 인해 자정 업데이트가 지연됨

**대응**:
1. ExpeditedWork 사용하여 우선순위 높임
2. 사용자에게 배터리 최적화 예외 설정 안내
3. Foreground Service 대안 검토 (최후 수단)

### R-002: RemoteViews 제약

**증상**: 복잡한 UI 구현 불가

**대응**:
1. 단순화된 UI 디자인 채택
2. Glance (Compose 기반 위젯) 마이그레이션 검토
3. 필수 정보만 표시하는 미니멀 디자인

### R-003: 데이터 동기화 실패

**증상**: 위젯에 오래된 데이터 표시

**대응**:
1. 타임스탬프 기반 "오래된 데이터" 경고 표시
2. 새로고침 버튼으로 수동 동기화 유도
3. 앱 실행 시 자동 재동기화

---

## 7. 아키텍처 결정 기록 (ADR)

### ADR-001: home_widget vs MethodChannel 직접 구현

**결정**: home_widget 패키지 사용

**이유**:
- 검증된 커뮤니티 패키지로 안정성 확보
- SharedPreferences 기반 데이터 전달 자동 처리
- 위젯 업데이트 트리거 API 제공
- 유지보수 부담 감소

**대안**: MethodChannel 직접 구현 (복잡도 증가)

### ADR-002: RemoteViews vs Glance

**결정**: 전통적 RemoteViews 사용

**이유**:
- minSdk 24 지원 필수 (Glance는 API 26+)
- 검증된 안정성
- 학습 곡선 낮음

**대안**: Glance 마이그레이션 (Phase 5에서 검토)

### ADR-003: 데이터 캐싱 전략

**결정**: SharedPreferences JSON 저장

**이유**:
- home_widget 패키지와 자연스러운 통합
- 단순한 Key-Value 구조
- 충분한 용량 (2MB 제한 내)

**대안**: Room Database (과도한 복잡도)

---

## 8. 참조

### 관련 SPEC

- [SPEC-TODO-001](../SPEC-TODO-001/spec.md): 부모 SPEC - 메인 Todo 시스템
- [SPEC-TODO-001/plan.md](../SPEC-TODO-001/plan.md): 부모 구현 계획

### 외부 문서

- [Android App Widgets Documentation](https://developer.android.com/develop/ui/views/appwidgets)
- [WorkManager Guide](https://developer.android.com/topic/libraries/architecture/workmanager)
- [home_widget Package](https://pub.dev/packages/home_widget)

---

**문서 끝**
