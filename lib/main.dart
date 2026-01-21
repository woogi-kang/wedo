import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/services/fcm_service.dart';
import 'features/widget/app_lifecycle_observer.dart';
import 'features/widget/widget_data_sync.dart';
import 'firebase_options.dart';

/// 앱 생명주기 옵저버 (위젯 동기화용)
late final AppLifecycleObserver _appLifecycleObserver;

/// WeDo 앱 진입점
///
/// 앱 초기화 순서:
/// 1. Flutter 바인딩 초기화
/// 2. 시스템 UI 설정
/// 3. Firebase 초기화
/// 4. FCM 백그라운드 핸들러 등록
/// 5. FCM 서비스 초기화
/// 6. 위젯 동기화 서비스 초기화
/// 7. 앱 생명주기 옵저버 등록
/// 8. 앱 실행
Future<void> main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 한국어 로케일 데이터 초기화 (DateFormat 사용을 위해 필수)
  await initializeDateFormatting('ko_KR', null);

  // 시스템 UI 설정 (상태바, 네비게이션바)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FCM 백그라운드 메시지 핸들러 등록
  // 앱이 백그라운드 또는 종료된 상태에서 메시지를 받을 때 호출됩니다.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // FCM 서비스 초기화
  await FcmService.instance.initialize();

  // 위젯 데이터 동기화 서비스 초기화
  await WidgetDataSync.initialize();

  // 앱 생명주기 옵저버 등록 (포그라운드 전환 시 위젯 동기화)
  _appLifecycleObserver = AppLifecycleObserver();
  _appLifecycleObserver.initialize();

  // 앱 실행 with Riverpod ProviderScope
  runApp(
    const ProviderScope(
      child: WeDoApp(),
    ),
  );
}
