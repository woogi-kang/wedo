# SPEC-WIDGET-001: 인수 기준서

---
spec_id: SPEC-WIDGET-001
version: 1.0.0
created: 2026-01-21
updated: 2026-01-21
author: woogi
---

## 1. 개요

이 문서는 SPEC-WIDGET-001 (WeDo Android 홈 위젯 시스템)의 인수 기준을 정의합니다.
모든 테스트 시나리오는 Given-When-Then 형식으로 작성되었습니다.

---

## 2. Ubiquitous Requirements 테스트 시나리오

### AC-U-001: 위젯 데이터 표시

```gherkin
Feature: 위젯 최신 데이터 표시
  위젯은 항상 최신 로컬 캐시 데이터를 표시해야 한다

  Scenario: 주간 위젯이 캐시된 Todo 데이터를 표시함
    Given 사용자가 이번 주에 마감인 Todo 5개를 가지고 있음
    And 해당 Todo 데이터가 SharedPreferences에 캐시되어 있음
    When 사용자가 홈 화면에서 주간 위젯을 확인함
    Then 위젯에 5개의 Todo 항목이 표시됨
    And 각 항목에 제목, 카테고리, 마감일이 표시됨

  Scenario: 캘린더 위젯이 캐시된 월별 데이터를 표시함
    Given 사용자가 1월에 총 15개의 Todo를 가지고 있음
    And 각 날짜별 Todo 개수가 캐시되어 있음
    When 사용자가 홈 화면에서 캘린더 위젯을 확인함
    Then 위젯에 1월 캘린더가 표시됨
    And Todo가 있는 날짜에 개수 뱃지가 표시됨
```

### AC-U-002: 위젯 주기적 갱신

```gherkin
Feature: 위젯 주기적 갱신
  위젯은 항상 지정된 업데이트 주기에 따라 갱신되어야 한다

  Scenario: 4시간마다 위젯이 자동 갱신됨
    Given 주간 위젯이 홈 화면에 추가되어 있음
    And 마지막 갱신으로부터 4시간이 경과함
    When WorkManager PeriodicWorkRequest가 트리거됨
    Then WorkManager가 위젯 업데이트 작업을 실행함
    And 위젯 데이터가 최신 캐시로 갱신됨
    And lastSyncTimestamp가 현재 시간으로 업데이트됨

  Scenario: 앱 포그라운드 전환 시 위젯 갱신됨
    Given 위젯에 Todo 3개가 표시되어 있음
    And 앱이 백그라운드 상태임
    When 사용자가 WeDo 앱을 포그라운드로 전환함
    Then 위젯 데이터 동기화가 트리거됨
    And 위젯이 최신 데이터로 갱신됨
```

### AC-U-003: 위젯 탭 시 앱 실행

```gherkin
Feature: 위젯 탭 시 앱 실행
  위젯은 항상 탭 시 WeDo 앱의 해당 화면으로 이동해야 한다

  Scenario: 주간 위젯 Todo 항목 탭 시 앱 실행
    Given 주간 위젯에 "장보기" Todo가 1/25 마감으로 표시됨
    When 사용자가 "장보기" 항목을 탭함
    Then WeDo 앱이 실행됨
    And HomePage가 1/25 날짜로 선택된 상태로 표시됨

  Scenario: 캘린더 위젯 날짜 탭 시 앱 실행
    Given 캘린더 위젯에 1월 21일에 (3) 뱃지가 표시됨
    When 사용자가 1월 21일을 탭함
    Then WeDo 앱이 실행됨
    And HomePage가 일간 보기 모드로 1/21이 선택된 상태로 표시됨
```

### AC-U-004: 한국어 UI 제공

```gherkin
Feature: 한국어 UI 제공
  위젯은 항상 한국어 UI를 제공해야 한다

  Scenario: 주간 위젯이 한국어로 표시됨
    Given 기기 언어 설정과 무관하게
    When 사용자가 주간 위젯을 확인함
    Then 위젯 헤더가 "이번 주 할 일"로 표시됨
    And 날짜가 "1/21 (화)" 형식으로 표시됨
    And 마지막 동기화가 "오늘 09:30" 형식으로 표시됨

  Scenario: 캘린더 위젯이 한국어로 표시됨
    Given 기기 언어 설정과 무관하게
    When 사용자가 캘린더 위젯을 확인함
    Then 월 표시가 "2026년 1월"로 표시됨
    And 요일이 "월 화 수 목 금 토 일"로 표시됨
```

### AC-U-005: Flutter 앱과 데이터 동기화

```gherkin
Feature: Flutter 앱과 데이터 동기화
  위젯 데이터는 항상 Flutter 앱과 동기화되어야 한다

  Scenario: 앱에서 Todo 생성 시 위젯에 반영
    Given 주간 위젯에 Todo 3개가 표시됨
    When 사용자가 WeDo 앱에서 이번 주 마감 Todo를 생성함
    Then WidgetDataSync 서비스가 호출됨
    And SharedPreferences가 업데이트됨
    And 위젯이 갱신되어 Todo 4개가 표시됨

  Scenario: 앱에서 Todo 완료 시 위젯에 반영
    Given 주간 위젯에 미완료 Todo "운동하기"가 표시됨
    When 사용자가 WeDo 앱에서 "운동하기"를 완료 처리함
    Then 위젯이 갱신됨
    And "운동하기" 항목이 취소선 스타일로 표시됨
```

---

## 3. Event-Driven Requirements 테스트 시나리오

### AC-E-001: Todo 변경 시 위젯 갱신

```gherkin
Feature: Todo 변경 시 위젯 갱신
  앱에서 Todo 데이터 변경 시 SharedPreferences 업데이트 및 위젯 갱신 트리거

  Scenario: Todo 생성 시 위젯 업데이트
    Given 위젯이 홈 화면에 추가되어 있음
    When 사용자가 앱에서 새 Todo "약 먹기"를 생성함
    Then home_widget.saveWidgetData()가 호출됨
    And home_widget.updateWidget()이 호출됨
    And 위젯에 "약 먹기"가 표시됨

  Scenario: Todo 삭제 시 위젯 업데이트
    Given 위젯에 "회의 참석" Todo가 표시됨
    When 사용자가 앱에서 "회의 참석"을 삭제함
    Then 위젯이 갱신됨
    And "회의 참석"이 위젯에서 제거됨
```

### AC-E-002: 4시간 주기 자동 갱신

```gherkin
Feature: 4시간 주기 자동 갱신
  4시간 경과 시 WorkManager가 위젯 데이터 자동 갱신

  Scenario: 4시간 경과 시 위젯 갱신
    Given 주간 위젯이 홈 화면에 추가되어 있음
    And 마지막 동기화가 4시간 전임
    When WorkManager PeriodicWorkRequest가 실행됨
    Then WidgetUpdateWorker가 실행됨
    And 위젯 데이터가 최신 상태로 갱신됨

  Scenario: 날짜 변경 시 주간 범위 업데이트
    Given 현재 날짜가 일요일(1/26)이고 위젯이 1/20-1/26 주를 표시 중
    When 4시간 주기 갱신이 실행되고 날짜가 월요일(1/27)이 됨
    Then 주간 위젯이 새로운 주(1/27-2/2)로 업데이트됨
```

### AC-E-003: 주간 위젯 Todo 탭 시 앱 실행

```gherkin
Feature: 주간 위젯 Todo 탭 시 앱 실행
  사용자가 위젯 Todo 항목 탭 시 해당 날짜의 Todo 목록 화면으로 앱 실행

  Scenario: 특정 Todo 항목 탭
    Given 주간 위젯에 1/23 마감 "데이트 준비" Todo가 표시됨
    When 사용자가 해당 항목을 탭함
    Then PendingIntent가 실행됨
    And Deep Link "wedo://todo/daily?date=2026-01-23"이 처리됨
    And WeDo 앱이 1/23 일간 보기로 열림
```

### AC-E-004: 캘린더 위젯 날짜 탭 시 앱 실행

```gherkin
Feature: 캘린더 위젯 날짜 탭 시 앱 실행
  사용자가 캘린더 위젯 날짜 탭 시 해당 날짜의 일간 보기로 앱 실행

  Scenario: Todo가 있는 날짜 탭
    Given 캘린더 위젯에서 1/21에 (3) 뱃지가 표시됨
    When 사용자가 1/21을 탭함
    Then WeDo 앱이 실행됨
    And HomePage가 1/21 일간 보기로 표시됨
    And 해당 날짜의 Todo 3개가 목록에 표시됨

  Scenario: Todo가 없는 날짜 탭
    Given 캘린더 위젯에서 1/15에 뱃지가 없음
    When 사용자가 1/15를 탭함
    Then WeDo 앱이 실행됨
    And HomePage가 1/15 일간 보기로 표시됨
    And "할 일이 없습니다" 메시지가 표시됨
```

### AC-E-005: 앱 포그라운드 전환 시 동기화

```gherkin
Feature: 앱 포그라운드 전환 시 동기화
  앱이 포그라운드 전환 시 위젯 데이터 동기화 트리거

  Scenario: 백그라운드에서 포그라운드로 전환
    Given WeDo 앱이 백그라운드 상태임
    And 위젯에 이전 데이터가 표시됨
    When 사용자가 앱 아이콘을 탭하여 포그라운드로 전환함
    Then LifecycleObserver가 onResume 이벤트를 감지함
    And WidgetDataSync.syncAllWidgets()가 호출됨
    And 위젯이 최신 데이터로 갱신됨
```

### AC-E-006: 캘린더 위젯 스와이프 월 이동

```gherkin
Feature: 캘린더 위젯 스와이프 월 이동
  캘린더 위젯에서 스와이프 시 이전/다음 월로 이동

  Scenario: 다음 월로 스와이프
    Given 캘린더 위젯이 2026년 1월을 표시 중
    When 사용자가 위젯을 왼쪽으로 스와이프함
    Then 위젯이 2026년 2월로 업데이트됨
    And 2월의 Todo 개수가 각 날짜에 표시됨

  Scenario: 이전 월로 스와이프
    Given 캘린더 위젯이 2026년 1월을 표시 중
    When 사용자가 위젯을 오른쪽으로 스와이프함
    Then 위젯이 2025년 12월로 업데이트됨
```

### AC-E-007: 위젯 최초 추가 시 즉시 렌더링

```gherkin
Feature: 위젯 최초 추가 시 즉시 렌더링
  위젯 최초 추가 시 현재 데이터로 즉시 렌더링

  Scenario: 데이터가 있는 상태에서 위젯 추가
    Given 사용자가 WeDo 앱에서 Todo 5개를 생성함
    And 해당 데이터가 SharedPreferences에 캐시됨
    When 사용자가 홈 화면에서 주간 위젯을 추가함
    Then onUpdate()가 호출됨
    And 위젯이 캐시된 5개 Todo로 즉시 렌더링됨

  Scenario: 데이터가 없는 상태에서 위젯 추가
    Given 사용자가 WeDo 앱을 처음 설치함
    And SharedPreferences에 위젯 데이터가 없음
    When 사용자가 홈 화면에서 위젯을 추가함
    Then 위젯에 "앱을 실행하여 데이터를 동기화하세요" 메시지가 표시됨
```

---

## 4. State-Driven Requirements 테스트 시나리오

### AC-S-001: 주간 위젯 현재 주 표시

```gherkin
Feature: 주간 위젯 현재 주 표시
  IF 주간 위젯 표시 중 THEN 현재 주(월-일)의 Todo 목록 표시

  Scenario: 주 중간에 위젯 확인
    Given 오늘이 2026년 1월 22일 수요일임
    When 사용자가 주간 위젯을 확인함
    Then 위젯 헤더에 "1/20 - 1/26" 주간 범위가 표시됨
    And 해당 주에 마감인 Todo만 목록에 표시됨

  Scenario: 주말에 위젯 확인
    Given 오늘이 2026년 1월 25일 토요일임
    When 사용자가 주간 위젯을 확인함
    Then 위젯이 동일한 주(1/20-1/26) 범위를 표시함
```

### AC-S-002: 캘린더 위젯 현재 월 표시

```gherkin
Feature: 캘린더 위젯 현재 월 표시
  IF 캘린더 위젯 표시 중 THEN 현재 월의 캘린더와 일별 Todo 개수 표시

  Scenario: 월 중간에 캘린더 위젯 확인
    Given 오늘이 2026년 1월 21일임
    And 1월에 총 20개의 Todo가 있음
    When 사용자가 캘린더 위젯을 확인함
    Then 2026년 1월 캘린더가 표시됨
    And 각 날짜에 해당 일자의 Todo 개수가 뱃지로 표시됨
    And 오늘(21일)이 강조 표시됨
```

### AC-S-003: 완료 상태 취소선 표시

```gherkin
Feature: 완료 상태 취소선 표시
  IF Todo가 완료 상태 THEN 취소선 스타일로 표시

  Scenario: 완료된 Todo 표시
    Given 주간 위젯에 "마감 서류 제출" Todo가 있음
    And 해당 Todo의 isCompleted가 true임
    When 사용자가 위젯을 확인함
    Then "마감 서류 제출" 텍스트에 취소선이 적용됨
    And 체크박스 아이콘이 채워진 상태로 표시됨

  Scenario: 미완료된 Todo 표시
    Given 주간 위젯에 "장보기" Todo가 있음
    And 해당 Todo의 isCompleted가 false임
    When 사용자가 위젯을 확인함
    Then "장보기" 텍스트가 일반 스타일로 표시됨
    And 체크박스 아이콘이 빈 상태로 표시됨
```

### AC-S-004: 마감일 지난 Todo 강조

```gherkin
Feature: 마감일 지난 Todo 강조
  IF Todo 마감일이 지남 THEN 빨간색 강조 표시

  Scenario: 오버듀 Todo 표시
    Given 오늘이 1월 22일임
    And "보고서 제출" Todo의 마감일이 1월 20일임
    And 해당 Todo가 미완료 상태임
    When 사용자가 주간 위젯을 확인함
    Then "보고서 제출" 항목이 빨간색으로 표시됨
    And 마감일 텍스트에 "지남" 표시가 추가됨
```

### AC-S-005: 오늘 마감 Todo 강조

```gherkin
Feature: 오늘 마감 Todo 강조
  IF 오늘 마감 Todo 존재 THEN 주간 위젯에서 강조 표시

  Scenario: 오늘 마감인 Todo 강조
    Given 오늘이 1월 21일임
    And "약 먹기" Todo의 마감일이 1월 21일임
    When 사용자가 주간 위젯을 확인함
    Then "약 먹기" 항목이 굵은 글씨로 표시됨
    And 마감일이 "오늘"로 표시됨
```

### AC-S-006: 캐시 데이터 없음 안내

```gherkin
Feature: 캐시 데이터 없음 안내
  IF 캐시 데이터 없음 THEN "앱을 실행해주세요" 메시지 표시

  Scenario: 앱 미설치 상태에서 위젯 추가
    Given 사용자가 WeDo 앱을 설치 후 한번도 실행하지 않음
    And SharedPreferences에 위젯 데이터가 없음
    When 사용자가 홈 화면에 위젯을 추가함
    Then 위젯에 Todo 목록 대신 안내 메시지가 표시됨
    And "WeDo 앱을 실행하여 데이터를 동기화하세요" 메시지가 표시됨
    And 위젯 탭 시 앱이 실행됨
```

### AC-S-007: 4x2 위젯 최대 5개 표시

```gherkin
Feature: 4x2 위젯 최대 5개 표시
  IF 위젯 크기 4x2 THEN 최대 5개 Todo 표시

  Scenario: 5개 초과 Todo가 있는 경우
    Given 사용자가 4x2 크기의 주간 위젯을 사용 중
    And 이번 주에 마감인 Todo가 8개 있음
    When 사용자가 위젯을 확인함
    Then 위젯에 5개의 Todo만 표시됨
    And 하단에 "+ 3개 더 보기" 텍스트가 표시됨
```

### AC-S-008: 4x3 위젯 최대 8개 표시

```gherkin
Feature: 4x3 위젯 최대 8개 표시
  IF 위젯 크기 4x3 THEN 최대 8개 Todo 표시

  Scenario: 8개 초과 Todo가 있는 경우
    Given 사용자가 4x3 크기의 주간 위젯을 사용 중
    And 이번 주에 마감인 Todo가 12개 있음
    When 사용자가 위젯을 확인함
    Then 위젯에 8개의 Todo만 표시됨
    And 하단에 "+ 4개 더 보기" 텍스트가 표시됨
```

---

## 5. Unwanted Requirements 테스트 시나리오

### AC-N-001: 배터리 소모 제한

```gherkin
Feature: 배터리 소모 제한
  위젯은 과도한 배터리를 소모하지 않아야 한다

  Scenario: 24시간 배터리 사용량 측정
    Given 위젯이 홈 화면에 추가되어 24시간 동안 운영됨
    And WorkManager가 정상적으로 스케줄링됨
    When Battery Historian으로 앱별 배터리 사용량을 측정함
    Then WeDo 앱의 배터리 사용량이 전체의 1% 미만임
    And Wake Lock 사용 시간이 분당 1초 미만임
```

### AC-N-002: 오래된 데이터 표시 방지

```gherkin
Feature: 오래된 데이터 표시 방지
  위젯은 24시간 초과된 데이터를 표시하지 않아야 한다

  Scenario: 24시간 초과 데이터 감지
    Given 위젯 데이터의 lastSyncTimestamp가 25시간 전임
    When 사용자가 위젯을 확인함
    Then 위젯에 "오래된 데이터입니다" 경고가 표시됨
    And "탭하여 새로고침" 버튼이 활성화됨

  Scenario: 새로고침으로 데이터 갱신
    Given 위젯에 "오래된 데이터입니다" 경고가 표시됨
    When 사용자가 새로고침 버튼을 탭함
    Then 앱이 실행되어 데이터 동기화가 수행됨
    And 위젯이 최신 데이터로 갱신됨
```

### AC-N-003: 네트워크 요청 금지

```gherkin
Feature: 네트워크 요청 금지
  위젯은 네트워크 요청을 직접 수행하지 않아야 한다

  Scenario: 위젯 업데이트 시 네트워크 미사용
    Given 기기가 비행기 모드(오프라인)임
    And SharedPreferences에 캐시된 데이터가 있음
    When 위젯 업데이트가 트리거됨
    Then 위젯이 캐시 데이터로 정상 렌더링됨
    And 네트워크 요청 에러가 발생하지 않음
```

### AC-N-004: 민감 정보 보호

```gherkin
Feature: 민감 정보 보호
  위젯은 민감한 사용자 정보를 평문 표시하지 않아야 한다

  Scenario: Todo 데이터에 개인정보 미포함
    Given 위젯에 표시되는 데이터 스키마를 검토함
    When SharedPreferences 데이터를 확인함
    Then 사용자 이메일, 비밀번호 등 민감 정보가 포함되지 않음
    And 표시되는 정보는 Todo 제목, 카테고리, 날짜만 해당함
```

### AC-N-005: WorkManager 최소 간격 준수

```gherkin
Feature: WorkManager 최소 간격 준수
  WorkManager는 5분 미만 간격으로 실행하지 않아야 한다

  Scenario: PeriodicWorkRequest 간격 확인
    Given WidgetUpdateWorker가 등록됨
    When WorkManager의 스케줄링 설정을 확인함
    Then repeatInterval이 15분 이상으로 설정됨
    And flexInterval이 적절하게 설정됨
```

---

## 6. Optional Requirements 테스트 시나리오

### AC-O-001: 다크 모드 테마 지원

```gherkin
Feature: 다크 모드 테마 지원
  가능하면 다크 모드 테마 지원 제공

  Scenario: 시스템 다크 모드 연동
    Given 기기가 다크 모드로 설정됨
    When 사용자가 위젯을 확인함
    Then 위젯 배경이 어두운 색상으로 표시됨
    And 텍스트가 밝은 색상으로 표시됨

  Scenario: 시스템 라이트 모드 연동
    Given 기기가 라이트 모드로 설정됨
    When 사용자가 위젯을 확인함
    Then 위젯 배경이 밝은 색상으로 표시됨
    And 텍스트가 어두운 색상으로 표시됨
```

### AC-O-002: 위젯 크기 선택 옵션

```gherkin
Feature: 위젯 크기 선택 옵션
  가능하면 위젯 크기 선택 옵션 제공

  Scenario: 4x2와 4x3 크기 선택
    Given 사용자가 위젯을 길게 눌러 설정 모드 진입
    When 위젯 크기 조절 핸들을 드래그함
    Then 4x2 또는 4x3 크기로 조절 가능함
    And 크기에 따라 표시되는 Todo 개수가 조정됨
```

### AC-O-003: 위젯 배경 투명도 조절

```gherkin
Feature: 위젯 배경 투명도 조절
  가능하면 위젯 배경 투명도 조절 제공

  Scenario: 투명도 설정 변경
    Given 사용자가 WeDo 앱의 위젯 설정 화면에 접근함
    When 배경 투명도 슬라이더를 50%로 조절함
    Then 위젯 배경이 반투명으로 표시됨
    And 설정이 SharedPreferences에 저장됨
```

### AC-O-004: 주 시작일 설정

```gherkin
Feature: 주 시작일 설정
  가능하면 캘린더 위젯 주 시작일 설정 제공

  Scenario: 월요일 시작으로 설정
    Given 사용자가 WeDo 앱의 위젯 설정에서 "주 시작: 월요일" 선택
    When 캘린더 위젯을 확인함
    Then 요일 헤더가 "월 화 수 목 금 토 일" 순서로 표시됨

  Scenario: 일요일 시작으로 설정
    Given 사용자가 WeDo 앱의 위젯 설정에서 "주 시작: 일요일" 선택
    When 캘린더 위젯을 확인함
    Then 요일 헤더가 "일 월 화 수 목 금 토" 순서로 표시됨
```

### AC-O-005: 위젯에서 Todo 완료 토글

```gherkin
Feature: 위젯에서 Todo 완료 토글
  가능하면 위젯에서 Todo 완료 토글 제공

  Scenario: 위젯에서 직접 완료 처리
    Given 주간 위젯에 미완료 "운동하기" Todo가 표시됨
    When 사용자가 체크박스 영역을 탭함
    Then Todo가 완료 상태로 변경됨
    And 위젯이 즉시 갱신되어 취소선 스타일로 표시됨
    And Firestore에 변경 사항이 동기화됨
```

---

## 7. Edge Case 테스트 시나리오

### EC-001: 오프라인 모드

```gherkin
Feature: 오프라인 모드 동작
  네트워크 연결 없이 위젯이 정상 동작해야 한다

  Scenario: 오프라인에서 위젯 표시
    Given 기기가 네트워크 연결이 없음
    And SharedPreferences에 캐시된 데이터가 있음
    When 사용자가 위젯을 확인함
    Then 위젯이 캐시 데이터로 정상 표시됨
    And 네트워크 에러가 발생하지 않음
```

### EC-002: Todo 없음

```gherkin
Feature: Todo 없음 상태 처리
  Todo가 없을 때 적절한 안내를 표시해야 한다

  Scenario: 이번 주 Todo가 없는 경우
    Given 사용자의 이번 주 마감 Todo가 0개임
    When 사용자가 주간 위젯을 확인함
    Then 위젯에 "이번 주 할 일이 없습니다" 메시지가 표시됨
    And "+ 새 할 일 추가" 버튼이 표시됨
```

### EC-003: 대량 Todo

```gherkin
Feature: 대량 Todo 처리
  많은 Todo가 있을 때 성능 저하 없이 처리해야 한다

  Scenario: 100개 이상 Todo 처리
    Given 사용자가 이번 주에 100개의 Todo를 가지고 있음
    When 위젯 데이터 동기화가 실행됨
    Then 동기화가 1초 이내에 완료됨
    And 위젯에 최대 표시 개수만큼만 렌더링됨
    And 메모리 사용량이 10MB를 초과하지 않음
```

### EC-004: 앱 강제 종료 후 위젯

```gherkin
Feature: 앱 강제 종료 후 위젯 동작
  앱이 강제 종료되어도 위젯이 정상 동작해야 한다

  Scenario: 앱 강제 종료 후 위젯 표시
    Given WeDo 앱이 강제 종료됨
    And SharedPreferences에 캐시된 데이터가 있음
    When 사용자가 위젯을 확인함
    Then 위젯이 캐시 데이터로 정상 표시됨
    And 앱 재실행 없이 위젯이 동작함
```

### EC-005: 기기 재부팅 후 위젯

```gherkin
Feature: 기기 재부팅 후 위젯 복원
  기기 재부팅 후 위젯이 정상 복원되어야 한다

  Scenario: 재부팅 후 위젯 자동 복원
    Given 위젯이 홈 화면에 추가되어 있음
    And 기기를 재부팅함
    When 홈 화면이 로드됨
    Then 위젯이 이전 위치에 복원됨
    And 캐시된 데이터로 정상 표시됨
    And WorkManager 스케줄이 재등록됨
```

---

## 8. 성능 기준

| 항목 | 목표 | 측정 방법 |
|------|------|-----------|
| 위젯 업데이트 시간 | < 1초 | Systrace |
| 초기 렌더링 시간 | < 500ms | Systrace |
| 배터리 소모 | < 1% / 24h | Battery Historian |
| 메모리 사용량 | < 10MB | Android Profiler |
| SharedPreferences 쓰기 | < 100ms | 로그 측정 |

---

## 9. 품질 게이트

### Definition of Done

- [ ] 모든 Ubiquitous 요구사항 테스트 통과 (AC-U-001 ~ AC-U-005)
- [ ] 모든 Event-Driven 요구사항 테스트 통과 (AC-E-001 ~ AC-E-007)
- [ ] 모든 State-Driven 요구사항 테스트 통과 (AC-S-001 ~ AC-S-008)
- [ ] 모든 Unwanted 요구사항 테스트 통과 (AC-N-001 ~ AC-N-005)
- [ ] 성능 기준 충족
- [ ] Android 7.0 (API 24) 기기 테스트 통과
- [ ] Android 14 (API 34) 기기 테스트 통과
- [ ] 코드 리뷰 완료
- [ ] 문서화 완료

---

**문서 끝**
