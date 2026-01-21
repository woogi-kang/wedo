# SPEC-WIDGET-001: WeDo Android 홈 위젯 시스템

---
id: SPEC-WIDGET-001
version: 1.1.0
status: Completed
created: 2026-01-21
updated: 2026-01-21
completed: 2026-01-21
author: woogi
priority: MEDIUM
lifecycle: spec-anchored
tags: [android, widget, kotlin, home-widget, flutter-native, workmanager]
parent: SPEC-TODO-001
implementation:
  weekly_widget: android/app/src/main/kotlin/com/wedo/app/widget/WeeklyTodoWidgetProvider.kt
  calendar_widget: android/app/src/main/kotlin/com/wedo/app/widget/CalendarWidgetProvider.kt
  data_manager: android/app/src/main/kotlin/com/wedo/app/widget/WidgetDataManager.kt
  flutter_sync: lib/features/widget/widget_data_sync.dart
---

## HISTORY

| 버전 | 날짜 | 작성자 | 변경 내용 |
|------|------|--------|-----------|
| 1.0.0 | 2026-01-21 | woogi | 초기 SPEC 문서 작성 |
| 1.1.0 | 2026-01-21 | woogi | 구현 완료, 상태를 Completed로 변경 |

---

## 1. Environment (환경)

### 1.1 기술 스택

| 구분 | 기술 | 버전 |
|------|------|------|
| Platform | Android | minSdk 24, targetSdk 34 |
| Native Language | Kotlin | 1.9.x |
| Widget Framework | Android AppWidget | API 24+ |
| Background Task | WorkManager | 2.9.x |
| Data Bridge | SharedPreferences | Latest |
| Flutter Bridge | home_widget | 0.7.x |
| Remote Views | RemoteViews | API 24+ |
| Parent Framework | Flutter | 3.27.x |

### 1.2 위젯 사양

| 위젯 | 크기 | 최소 Android 버전 |
|------|------|-------------------|
| Weekly Todo Widget | 4x2 또는 4x3 (선택 가능) | Android 7.0 (API 24) |
| Calendar Widget | 4x4 | Android 7.0 (API 24) |

### 1.3 데이터 아키텍처

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter App (Dart)                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           Firestore (Cloud Database)                  │   │
│  │  - /todos/{todoId}                                    │   │
│  │  - Real-time sync via StreamSubscription              │   │
│  └───────────────────────┬──────────────────────────────┘   │
│                          │                                   │
│  ┌───────────────────────▼──────────────────────────────┐   │
│  │        home_widget Package (Flutter → Android)        │   │
│  │  - saveWidgetData() - JSON serialization              │   │
│  │  - updateWidget() - Trigger native refresh            │   │
│  └───────────────────────┬──────────────────────────────┘   │
└──────────────────────────┼──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                 Android Native (Kotlin)                      │
│  ┌──────────────────────────────────────────────────────┐   │
│  │          SharedPreferences (Local Cache)              │   │
│  │  - widget_todos_weekly: JSON array                    │   │
│  │  - widget_todos_calendar: JSON object                 │   │
│  │  - last_sync_timestamp: Long                          │   │
│  └───────────────────────┬──────────────────────────────┘   │
│                          │                                   │
│  ┌───────────────────────▼──────────────────────────────┐   │
│  │           AppWidgetProvider (Kotlin)                  │   │
│  │  - WeeklyTodoWidgetProvider                           │   │
│  │  - CalendarWidgetProvider                             │   │
│  │  - RemoteViews for UI rendering                       │   │
│  └───────────────────────┬──────────────────────────────┘   │
│                          │                                   │
│  ┌───────────────────────▼──────────────────────────────┐   │
│  │             WorkManager (Background Sync)             │   │
│  │  - PeriodicWorkRequest: 4시간 주기 업데이트             │   │
│  │  - OneTimeWorkRequest: 앱 포그라운드 트리거            │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 1.4 개발 환경

- IDE: Android Studio Hedgehog / VS Code
- Build Tool: Gradle 8.x with Kotlin DSL
- Version Control: Git
- Testing: Android Instrumented Tests

---

## 2. Assumptions (가정)

### 2.1 기술적 가정

| ID | 가정 | 신뢰도 | 근거 | 실패 시 위험 | 검증 방법 |
|----|------|--------|------|--------------|-----------|
| A-001 | home_widget 패키지로 Flutter-Android 데이터 브릿지 구현 가능 | High | 공식 문서 및 커뮤니티 사례 | 대안: MethodChannel 직접 구현 | POC 구현 |
| A-002 | SharedPreferences JSON 크기 제한 (2MB) 내 Todo 데이터 저장 가능 | High | 주간 Todo 최대 100개 가정 시 약 50KB | 데이터 truncation 필요 | 성능 테스트 |
| A-003 | WorkManager 백그라운드 작업이 배터리 최적화에 영향받지 않음 | Medium | Android Doze 모드 예외 처리 필요 | 업데이트 지연 발생 | 실기기 테스트 |
| A-004 | RemoteViews 제약 내에서 필요한 UI 구현 가능 | High | 기본 위젯 레이아웃 사용 | 복잡한 UI 단순화 | 프로토타입 |
| A-005 | 위젯 업데이트 시간 < 1초 | Medium | 로컬 캐시 사용 시 | UX 저하 | 성능 측정 |

### 2.2 비즈니스 가정

| ID | 가정 | 신뢰도 | 근거 |
|----|------|--------|------|
| B-001 | 사용자는 주로 빠른 Todo 확인을 위해 위젯 사용 | High | 일반적인 위젯 사용 패턴 |
| B-002 | 위젯에서 Todo 생성/수정 기능은 MVP 범위 외 | High | 요구사항 정의 |
| B-003 | 월간 캘린더에서 일별 Todo 개수만 표시 (상세 내용 X) | High | 4x4 공간 제약 |

### 2.3 근본 원인 분석 (5 Whys)

**표면 문제**: 사용자가 앱을 열지 않고 Todo를 확인하고 싶어함

1. **Why?** 앱을 매번 열어 확인하는 것이 번거로움
2. **Why?** Todo 확인이 빈번하지만 간단한 정보만 필요함
3. **Why?** 하루 일정 파악에 시간을 최소화하고 싶음
4. **Why?** 커플 공유 Todo라 파트너 추가 항목도 즉시 확인 필요
5. **근본 원인**: 빠른 정보 접근성과 실시간 동기화된 Todo 상태 파악 니즈

---

## 3. Requirements (요구사항)

### 3.1 Ubiquitous Requirements (항상 적용)

> 시스템은 **항상** [동작]해야 한다

| ID | 요구사항 | 우선순위 | 테스트 시나리오 |
|----|----------|----------|-----------------|
| U-001 | 위젯은 **항상** 최신 로컬 캐시 데이터를 표시해야 한다 | HIGH | AC-U-001 |
| U-002 | 위젯은 **항상** 지정된 업데이트 주기에 따라 갱신되어야 한다 | HIGH | AC-U-002 |
| U-003 | 위젯은 **항상** 탭 시 WeDo 앱의 해당 화면으로 이동해야 한다 | HIGH | AC-U-003 |
| U-004 | 위젯은 **항상** 한국어 UI를 제공해야 한다 | MEDIUM | AC-U-004 |
| U-005 | 위젯 데이터는 **항상** Flutter 앱과 동기화되어야 한다 | HIGH | AC-U-005 |

### 3.2 Event-Driven Requirements (이벤트 기반)

> **WHEN** [이벤트] **THEN** [동작]

| ID | 이벤트 | 동작 | 우선순위 | 테스트 시나리오 |
|----|--------|------|----------|-----------------|
| E-001 | **WHEN** 앱에서 Todo 데이터 변경 **THEN** SharedPreferences 업데이트 및 위젯 갱신 트리거 | HIGH | AC-E-001 |
| E-002 | **WHEN** 4시간 경과 **THEN** WorkManager가 위젯 데이터 자동 갱신 | HIGH | AC-E-002 |
| E-003 | **WHEN** 사용자가 위젯 Todo 항목 탭 **THEN** 해당 날짜의 Todo 목록 화면으로 앱 실행 | HIGH | AC-E-003 |
| E-004 | **WHEN** 사용자가 캘린더 위젯 날짜 탭 **THEN** 해당 날짜의 일간 보기로 앱 실행 | HIGH | AC-E-004 |
| E-005 | **WHEN** 앱이 포그라운드 전환 **THEN** 위젯 데이터 동기화 트리거 | MEDIUM | AC-E-005 |
| E-006 | **WHEN** 캘린더 위젯에서 스와이프 **THEN** 이전/다음 월로 이동 | MEDIUM | AC-E-006 |
| E-007 | **WHEN** 위젯 최초 추가 **THEN** 현재 데이터로 즉시 렌더링 | HIGH | AC-E-007 |

### 3.3 State-Driven Requirements (상태 기반)

> **IF** [조건] **THEN** [동작]

| ID | 조건 | 동작 | 우선순위 | 테스트 시나리오 |
|----|------|------|----------|-----------------|
| S-001 | **IF** 주간 위젯 표시 중 **THEN** 현재 주(월-일)의 Todo 목록 표시 | HIGH | AC-S-001 |
| S-002 | **IF** 캘린더 위젯 표시 중 **THEN** 현재 월의 캘린더와 일별 Todo 개수 표시 | HIGH | AC-S-002 |
| S-003 | **IF** Todo가 완료 상태 **THEN** 취소선 스타일로 표시 | HIGH | AC-S-003 |
| S-004 | **IF** Todo 마감일이 지남 **THEN** 빨간색 강조 표시 | MEDIUM | AC-S-004 |
| S-005 | **IF** 오늘 마감 Todo 존재 **THEN** 주간 위젯에서 강조 표시 | MEDIUM | AC-S-005 |
| S-006 | **IF** 캐시 데이터 없음 **THEN** "앱을 실행해주세요" 메시지 표시 | HIGH | AC-S-006 |
| S-007 | **IF** 위젯 크기 4x2 **THEN** 최대 5개 Todo 표시 | HIGH | AC-S-007 |
| S-008 | **IF** 위젯 크기 4x3 **THEN** 최대 8개 Todo 표시 | HIGH | AC-S-008 |

### 3.4 Unwanted Requirements (금지 사항)

> 시스템은 [동작]**하지 않아야 한다**

| ID | 금지 동작 | 이유 | 우선순위 | 테스트 시나리오 |
|----|-----------|------|----------|-----------------|
| N-001 | 위젯은 과도한 배터리를 소모**하지 않아야 한다** | 사용자 경험 | HIGH | AC-N-001 |
| N-002 | 위젯은 오래된 데이터(24시간 초과)를 표시**하지 않아야 한다** | 데이터 신뢰성 | HIGH | AC-N-002 |
| N-003 | 위젯은 네트워크 요청을 직접 수행**하지 않아야 한다** | 아키텍처 제약 | HIGH | AC-N-003 |
| N-004 | 위젯은 민감한 사용자 정보를 평문 표시**하지 않아야 한다** | 보안 | MEDIUM | AC-N-004 |
| N-005 | WorkManager는 5분 미만 간격으로 실행**하지 않아야 한다** | Android 제약 | HIGH | AC-N-005 |

### 3.5 Optional Requirements (선택적)

> **가능하면** [동작] 제공

| ID | 기능 | 설명 | 우선순위 | 테스트 시나리오 |
|----|------|------|----------|-----------------|
| O-001 | **가능하면** 다크 모드 테마 지원 제공 | 시스템 테마 연동 | LOW | AC-O-001 |
| O-002 | **가능하면** 위젯 크기 선택 옵션 제공 | 4x2, 4x3 선택 | LOW | AC-O-002 |
| O-003 | **가능하면** 위젯 배경 투명도 조절 제공 | 사용자 커스터마이징 | LOW | AC-O-003 |
| O-004 | **가능하면** 캘린더 위젯 주 시작일 설정 제공 | 월요일/일요일 선택 | LOW | AC-O-004 |
| O-005 | **가능하면** 위젯에서 Todo 완료 토글 제공 | 빠른 상태 변경 | LOW | AC-O-005 |

---

## 4. Specifications (세부 명세)

### 4.1 Weekly Todo Widget (주간 Todo 목록 위젯)

#### 4.1.1 레이아웃 명세

```
┌─────────────────────────────────────────────────┐
│  WeDo 이번 주 할 일                    [새로고침] │
├─────────────────────────────────────────────────┤
│ ○ 장보기 - 마트                      1/21 (화)  │
│ ● ̶마̶감̶ ̶서̶류̶ ̶제̶출̶                    1/20 (월)  │
│ ○ 병원 예약                          1/22 (수)  │
│ ○ 운동하기                           1/23 (목)  │
│ ○ 데이트 준비                        1/25 (토)  │
│                                                 │
│          + 3개 더 보기                          │
├─────────────────────────────────────────────────┤
│ 마지막 동기화: 오늘 09:30                        │
└─────────────────────────────────────────────────┘

크기: 4x2 (280dp x 110dp) 또는 4x3 (280dp x 180dp)
```

#### 4.1.2 데이터 구조

```kotlin
// SharedPreferences Key: "widget_todos_weekly"
data class WeeklyWidgetData(
    val todos: List<WidgetTodo>,
    val weekStart: String,        // "2026-01-20" (ISO 8601)
    val weekEnd: String,          // "2026-01-26"
    val lastSyncTimestamp: Long,  // Unix timestamp
    val totalCount: Int           // 전체 개수 (표시 제한 초과 시)
)

data class WidgetTodo(
    val id: String,
    val title: String,
    val category: String?,
    val dueDate: String?,         // "2026-01-21"
    val dueTime: String?,         // "14:30"
    val isCompleted: Boolean,
    val isOverdue: Boolean,
    val creatorName: String
)
```

#### 4.1.3 업데이트 전략

| 트리거 | 타이밍 | 메커니즘 |
|--------|--------|----------|
| 정기 자동 갱신 | 4시간마다 | WorkManager PeriodicWorkRequest |
| 앱 포그라운드 | 앱 활성화 시 | home_widget.updateWidget() |
| Todo 변경 | CRUD 이벤트 | home_widget.saveWidgetData() + updateWidget() |
| 새로고침 버튼 | 사용자 탭 | PendingIntent → BroadcastReceiver |

### 4.2 Calendar Widget (캘린더 위젯)

#### 4.2.1 레이아웃 명세

```
┌─────────────────────────────────────────────────┐
│  ◀  2026년 1월  ▶                              │
├─────────────────────────────────────────────────┤
│  월   화   수   목   금   토   일               │
├─────────────────────────────────────────────────┤
│       1    2    3    4    5    6               │
│            (2)       (1)                       │
│  7    8    9   10   11   12   13              │
│       (3)                                      │
│ 14   15   16   17   18   19   20              │
│                               (1)              │
│ 21   22   23   24   25   26   27              │
│ ●(2) (1)            (4)                       │
│ 28   29   30   31                             │
│                                                │
├─────────────────────────────────────────────────┤
│ 오늘: 3개 할 일 | 이번 주: 8개                   │
└─────────────────────────────────────────────────┘

크기: 4x4 (280dp x 280dp)
● = 오늘, (n) = 해당 일자 Todo 개수
```

#### 4.2.2 데이터 구조

```kotlin
// SharedPreferences Key: "widget_calendar_data"
data class CalendarWidgetData(
    val currentMonth: String,        // "2026-01"
    val todoCountByDate: Map<String, Int>,  // {"2026-01-21": 3, ...}
    val todayTodoCount: Int,
    val weekTodoCount: Int,
    val lastSyncTimestamp: Long
)
```

#### 4.2.3 인터랙션 명세

| 액션 | 동작 | Deep Link |
|------|------|-----------|
| 날짜 탭 | 해당 날짜 일간 보기로 앱 실행 | `wedo://todo/daily?date=2026-01-21` |
| 이전 월 버튼 | 캘린더 이전 월로 이동 | 위젯 내부 상태 변경 |
| 다음 월 버튼 | 캘린더 다음 월로 이동 | 위젯 내부 상태 변경 |
| 좌우 스와이프 | 월 이동 | ViewFlipper 애니메이션 |

### 4.3 Android Native 컴포넌트

#### 4.3.1 파일 구조

```
android/app/src/main/
├── kotlin/com/wedo/app/
│   ├── widget/
│   │   ├── WeeklyTodoWidgetProvider.kt
│   │   ├── CalendarWidgetProvider.kt
│   │   ├── WidgetDataManager.kt
│   │   └── WidgetUpdateWorker.kt
│   └── MainActivity.kt (수정)
├── res/
│   ├── layout/
│   │   ├── widget_weekly_todo.xml
│   │   ├── widget_weekly_todo_item.xml
│   │   ├── widget_calendar.xml
│   │   └── widget_calendar_day.xml
│   ├── xml/
│   │   ├── widget_weekly_todo_info.xml
│   │   └── widget_calendar_info.xml
│   ├── drawable/
│   │   ├── widget_background.xml
│   │   ├── widget_background_dark.xml
│   │   └── ic_widget_refresh.xml
│   └── values/
│       ├── strings_widget.xml
│       └── colors_widget.xml
└── AndroidManifest.xml (수정)
```

#### 4.3.2 AndroidManifest.xml 추가 항목

```xml
<!-- Weekly Todo Widget -->
<receiver
    android:name=".widget.WeeklyTodoWidgetProvider"
    android:exported="true">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
        <action android:name="com.wedo.app.WIDGET_REFRESH" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/widget_weekly_todo_info" />
</receiver>

<!-- Calendar Widget -->
<receiver
    android:name=".widget.CalendarWidgetProvider"
    android:exported="true">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
        <action android:name="com.wedo.app.CALENDAR_WIDGET_REFRESH" />
        <action android:name="com.wedo.app.CALENDAR_WIDGET_PREV_MONTH" />
        <action android:name="com.wedo.app.CALENDAR_WIDGET_NEXT_MONTH" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/widget_calendar_info" />
</receiver>
```

### 4.4 Flutter 측 구현

#### 4.4.1 home_widget 통합

```dart
// lib/features/widget/widget_data_sync.dart
class WidgetDataSync {
  static const String weeklyWidgetKey = 'widget_todos_weekly';
  static const String calendarWidgetKey = 'widget_calendar_data';

  Future<void> syncWeeklyWidget(List<Todo> todos) async {
    final weeklyData = _buildWeeklyWidgetData(todos);
    await HomeWidget.saveWidgetData<String>(
      weeklyWidgetKey,
      jsonEncode(weeklyData.toJson()),
    );
    await HomeWidget.updateWidget(
      androidName: 'WeeklyTodoWidgetProvider',
    );
  }

  Future<void> syncCalendarWidget(List<Todo> todos) async {
    final calendarData = _buildCalendarWidgetData(todos);
    await HomeWidget.saveWidgetData<String>(
      calendarWidgetKey,
      jsonEncode(calendarData.toJson()),
    );
    await HomeWidget.updateWidget(
      androidName: 'CalendarWidgetProvider',
    );
  }
}
```

#### 4.4.2 Deep Link 처리

```dart
// lib/core/router/app_router.dart
final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/todo/daily',
      builder: (context, state) {
        final date = state.uri.queryParameters['date'];
        return HomePage(initialDate: DateTime.parse(date!));
      },
    ),
  ],
);
```

---

## 5. Traceability (추적성)

### 관련 문서

| 문서 | 경로 | 설명 |
|------|------|------|
| 부모 SPEC | `.moai/specs/SPEC-TODO-001/spec.md` | 메인 Todo 시스템 명세 |
| 구현 계획 | `.moai/specs/SPEC-WIDGET-001/plan.md` | 구현 마일스톤 및 기술 전략 |
| 인수 기준 | `.moai/specs/SPEC-WIDGET-001/acceptance.md` | Given-When-Then 테스트 시나리오 |

### 요구사항 매핑

| 요구사항 ID | 테스트 시나리오 ID | 구현 우선순위 | 상위 SPEC 참조 |
|-------------|-------------------|---------------|----------------|
| U-001 ~ U-005 | AC-U-001 ~ AC-U-005 | Phase 1 | SPEC-TODO-001 O-004 |
| E-001 ~ E-007 | AC-E-001 ~ AC-E-007 | Phase 2 | - |
| S-001 ~ S-008 | AC-S-001 ~ AC-S-008 | Phase 2 | - |
| N-001 ~ N-005 | AC-N-001 ~ AC-N-005 | Phase 1 | - |
| O-001 ~ O-005 | AC-O-001 ~ AC-O-005 | Phase 3 | - |

---

## 6. Constraints (제약사항)

### 기술적 제약

| 제약 | 설명 | 영향 |
|------|------|------|
| RemoteViews 제한 | 지원 위젯만 사용 가능 (TextView, ImageView, Button 등) | 복잡한 UI 구현 불가 |
| WorkManager 최소 간격 | 15분 미만 주기 작업 불가 | 실시간 동기화 제한 |
| SharedPreferences 용량 | 단일 키당 권장 1MB 미만 | 데이터 페이징 필요 |
| Widget Size 제한 | 최대 4x4 셀 | 캘린더 위젯 최대 크기 |
| Background 제한 | Android 12+ 백그라운드 실행 제한 | WorkManager 필수 |

### 비기능적 제약

| 항목 | 목표 | 측정 방법 |
|------|------|-----------|
| 위젯 업데이트 시간 | < 1초 | Systrace 프로파일링 |
| 배터리 소모 | < 1% / 24시간 | Battery Historian |
| 메모리 사용량 | < 10MB | Android Profiler |
| APK 크기 증가 | < 500KB | APK Analyzer |

---

## 7. Risk Analysis (위험 분석)

| ID | 위험 | 발생 확률 | 영향도 | 대응 전략 |
|----|------|-----------|--------|-----------|
| R-001 | 배터리 최적화로 WorkManager 지연 | Medium | High | Foreground Service 대안 검토 |
| R-002 | RemoteViews 레이아웃 복잡도 한계 | Low | Medium | 단순화된 UI 디자인 |
| R-003 | home_widget 패키지 버전 호환성 | Low | Medium | 직접 MethodChannel 구현 대안 |
| R-004 | Android 버전별 위젯 동작 차이 | Medium | Medium | 다양한 기기 테스트 |
| R-005 | 데이터 동기화 실패 시 stale 데이터 표시 | Medium | High | 타임스탬프 기반 경고 표시 |

---

**문서 끝**
