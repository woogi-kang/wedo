import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';

/// 앱 생명주기 옵저버
///
/// 앱이 포그라운드로 돌아올 때 위젯 동기화를 트리거합니다.
/// WidgetsBindingObserver를 구현하여 앱 상태 변화를 감지합니다.
///
/// 사용법:
/// ```dart
/// // main.dart에서 초기화
/// final observer = AppLifecycleObserver();
/// WidgetsBinding.instance.addObserver(observer);
///
/// // 앱 종료 시 해제
/// WidgetsBinding.instance.removeObserver(observer);
/// ```
class AppLifecycleObserver with WidgetsBindingObserver {
  /// 마지막 포그라운드 전환 시간 (디바운싱용)
  DateTime? _lastResumeTime;

  /// 디바운스 간격 (밀리초)
  /// 연속된 포그라운드 전환 시 중복 동기화 방지
  static const int _debounceIntervalMs = 1000;

  /// 옵저버 활성화
  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    developer.log('AppLifecycleObserver 초기화됨', name: 'WidgetSync');
  }

  /// 옵저버 해제
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    developer.log('AppLifecycleObserver 해제됨', name: 'WidgetSync');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.inactive:
        developer.log('앱 상태: inactive', name: 'WidgetSync');
        break;
      case AppLifecycleState.paused:
        developer.log('앱 상태: paused', name: 'WidgetSync');
        break;
      case AppLifecycleState.detached:
        developer.log('앱 상태: detached', name: 'WidgetSync');
        break;
      case AppLifecycleState.hidden:
        developer.log('앱 상태: hidden', name: 'WidgetSync');
        break;
    }
  }

  /// 앱이 포그라운드로 돌아왔을 때 처리
  void _onAppResumed() {
    developer.log('앱 포그라운드 전환 감지', name: 'WidgetSync');

    // 디바운싱: 1초 이내 연속 호출 무시
    final now = DateTime.now();
    if (_lastResumeTime != null) {
      final diff = now.difference(_lastResumeTime!).inMilliseconds;
      if (diff < _debounceIntervalMs) {
        developer.log('디바운스로 위젯 동기화 스킵 (${diff}ms)', name: 'WidgetSync');
        return;
      }
    }
    _lastResumeTime = now;

    // 위젯 업데이트 트리거
    _triggerWidgetSync();
  }

  /// 모든 위젯 동기화 트리거
  ///
  /// home_widget 패키지를 통해 Android 위젯에 업데이트 신호를 보냅니다.
  /// Flutter에서 저장한 SharedPreferences 데이터를 위젯이 다시 읽도록 합니다.
  Future<void> _triggerWidgetSync() async {
    try {
      developer.log('위젯 동기화 트리거 시작', name: 'WidgetSync');

      // 주간 Todo 위젯 업데이트
      await HomeWidget.updateWidget(
        androidName: 'WeeklyTodoWidgetProvider',
      );

      // 캘린더 위젯 업데이트
      await HomeWidget.updateWidget(
        androidName: 'CalendarWidgetProvider',
      );

      developer.log('위젯 동기화 트리거 완료', name: 'WidgetSync');
    } catch (e) {
      developer.log('위젯 동기화 트리거 실패: $e', name: 'WidgetSync');
    }
  }

  /// 즉시 위젯 동기화 (외부 호출용)
  ///
  /// Todo CRUD 작업 후 호출하여 위젯을 즉시 업데이트합니다.
  static Future<void> syncWidgetsNow() async {
    try {
      developer.log('즉시 위젯 동기화 요청', name: 'WidgetSync');

      await Future.wait([
        HomeWidget.updateWidget(androidName: 'WeeklyTodoWidgetProvider'),
        HomeWidget.updateWidget(androidName: 'CalendarWidgetProvider'),
      ]);

      developer.log('즉시 위젯 동기화 완료', name: 'WidgetSync');
    } catch (e) {
      developer.log('즉시 위젯 동기화 실패: $e', name: 'WidgetSync');
    }
  }
}
