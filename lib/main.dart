import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Firebase imports - uncomment after FlutterFire CLI setup
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

import 'app.dart';

/// WeDo 앱 진입점
///
/// 앱 초기화 순서:
/// 1. Flutter 바인딩 초기화
/// 2. 시스템 UI 설정
/// 3. Hive 로컬 스토리지 초기화
/// 4. Firebase 초기화 (FlutterFire CLI 설정 후)
/// 5. 앱 실행
Future<void> main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 시스템 UI 설정 (상태바, 네비게이션바)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Hive 로컬 스토리지 초기화
  await Hive.initFlutter();

  // TODO: Firebase 초기화 - FlutterFire CLI 설정 후 주석 해제
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // 앱 실행 with Riverpod ProviderScope
  runApp(
    const ProviderScope(
      child: WeDoApp(),
    ),
  );
}
