# WeDo - 커플 투두 앱

커플이 함께 할 일을 관리하고 공유하는 Flutter 기반 모바일 애플리케이션입니다.

## 주요 기능

### 투두 관리
- 할 일 생성, 수정, 삭제
- 카테고리별 분류
- 마감일 및 시간 설정
- 완료 상태 관리
- 파트너와 실시간 동기화

### Android 홈 위젯
- **주간 투두 위젯 (4x2, 4x3)**: 이번 주 할 일 목록을 홈 화면에서 바로 확인
- **캘린더 위젯 (4x4)**: 월간 캘린더와 일별 투두 개수 표시
- 4시간 주기 자동 동기화 (WorkManager)
- 위젯 탭 시 앱의 해당 화면으로 이동

### 실시간 동기화
- Firebase Firestore 기반 클라우드 동기화
- 커플 간 투두 공유 및 실시간 업데이트
- 오프라인 지원

## 기술 스택

| 구분 | 기술 |
|------|------|
| Framework | Flutter 3.27.x |
| Language | Dart, Kotlin |
| Backend | Firebase (Firestore, Auth) |
| State Management | Riverpod |
| Widget Bridge | home_widget 0.7.x |
| Background Task | WorkManager 2.9.x |
| Platform | Android (minSdk 24, targetSdk 34) |

## 시작하기

### 요구사항
- Flutter SDK 3.27.0 이상
- Android Studio 또는 VS Code
- Firebase 프로젝트 설정

### 설치

```bash
# 저장소 클론
git clone https://github.com/woogi/wedo.git
cd wedo

# 의존성 설치
flutter pub get

# 앱 실행
flutter run
```

### Firebase 설정
1. Firebase Console에서 새 프로젝트 생성
2. Android 앱 추가 (패키지명: com.wedo.app)
3. `google-services.json` 파일을 `android/app/` 디렉토리에 추가
4. Firestore 데이터베이스 생성

## 프로젝트 구조

```
wedo/
├── lib/
│   ├── core/              # 핵심 유틸리티 및 설정
│   ├── features/          # 기능별 모듈
│   │   ├── auth/          # 인증
│   │   ├── todo/          # 투두 관리
│   │   ├── home/          # 홈 화면
│   │   └── widget/        # 위젯 데이터 동기화
│   └── main.dart
├── android/
│   └── app/src/main/
│       ├── kotlin/.../widget/   # Android 위젯 구현
│       └── res/
│           ├── layout/          # 위젯 레이아웃
│           └── xml/             # 위젯 설정
└── .moai/
    └── specs/             # SPEC 문서
```

## 위젯 기능 상세

### 주간 투두 위젯
- 현재 주(월-일)의 할 일 목록 표시
- 완료된 항목은 취소선으로 표시
- 마감일 지난 항목은 빨간색 강조
- 새로고침 버튼으로 수동 갱신 가능

### 캘린더 위젯
- 월간 캘린더 뷰
- 각 날짜별 투두 개수 표시
- 오늘 날짜 하이라이트
- 이전/다음 월 네비게이션

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 기여하기

버그 리포트, 기능 제안, Pull Request를 환영합니다.

---

개발: woogi
