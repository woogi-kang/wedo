import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// FCM 푸시 알림 서비스
///
/// Firebase Cloud Messaging을 사용하여 푸시 알림을 처리합니다.
/// - FCM 초기화 및 권한 요청
/// - FCM 토큰 관리
/// - 포그라운드/백그라운드 메시지 핸들링
/// - 로컬 알림 표시
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // 알림 채널 ID (Android)
  static const String _channelId = 'wedo_notifications';
  static const String _channelName = 'WeDo 알림';
  static const String _channelDescription = '커플 투두 알림';

  // FCM 토큰 변경 콜백
  Function(String token)? onTokenRefresh;

  // 알림 탭 콜백
  Function(Map<String, dynamic> data)? onNotificationTap;

  /// FCM 서비스 초기화
  ///
  /// 앱 시작 시 호출하여 FCM 및 로컬 알림을 설정합니다.
  Future<void> initialize() async {
    // 1. 로컬 알림 초기화
    await _initializeLocalNotifications();

    // 2. FCM 권한 요청
    await requestPermission();

    // 3. 포그라운드 메시지 리스너 설정
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 4. 알림 탭으로 앱이 열린 경우 처리
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // 5. 앱이 종료된 상태에서 알림으로 열린 경우 처리
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // 6. 토큰 갱신 리스너
    // 보안: FCM 토큰은 민감 정보이므로 프로덕션에서 로깅하지 않음
    _messaging.onTokenRefresh.listen((token) {
      debugPrint('FCM Token refreshed');
      onTokenRefresh?.call(token);
    });

    debugPrint('FCM Service initialized');
  }

  /// 로컬 알림 초기화
  Future<void> _initializeLocalNotifications() async {
    // Android 설정
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 설정
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Android 알림 채널 생성
    if (Platform.isAndroid) {
      await _createAndroidNotificationChannel();
    }
  }

  /// Android 알림 채널 생성
  Future<void> _createAndroidNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// FCM 권한 요청
  ///
  /// iOS에서는 사용자에게 권한을 요청합니다.
  /// Android 13 이상에서도 POST_NOTIFICATIONS 권한이 필요합니다.
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final isAuthorized =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;

    debugPrint('FCM Permission status: ${settings.authorizationStatus}');

    return isAuthorized;
  }

  /// FCM 토큰 획득
  ///
  /// 현재 기기의 FCM 토큰을 반환합니다.
  /// 토큰은 Firestore에 저장하여 푸시 알림 전송에 사용합니다.
  /// 보안: 토큰은 민감 정보이므로 프로덕션 로그에 포함하지 않습니다.
  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      // 보안: FCM 토큰은 민감 정보이므로 프로덕션에서 로깅하지 않음
      // 디버그 빌드에서만 토큰 존재 여부만 로깅
      debugPrint('FCM Token obtained: ${token != null ? 'yes' : 'no'}');
      return token;
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
      return null;
    }
  }

  /// FCM 토큰 삭제
  ///
  /// 로그아웃 시 호출하여 기기의 FCM 토큰을 삭제합니다.
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      debugPrint('FCM Token deleted');
    } catch (e) {
      debugPrint('Failed to delete FCM token: $e');
    }
  }

  /// 포그라운드 메시지 처리
  ///
  /// 앱이 포그라운드에 있을 때 받은 메시지를 로컬 알림으로 표시합니다.
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.messageId}');

    final notification = message.notification;
    if (notification != null) {
      _showLocalNotification(
        title: notification.title ?? 'WeDo',
        body: notification.body ?? '',
        data: message.data,
      );
    }
  }

  /// 알림 탭 처리
  ///
  /// 사용자가 알림을 탭하여 앱을 열었을 때 호출됩니다.
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    onNotificationTap?.call(message.data);
  }

  /// 로컬 알림 응답 처리
  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('Local notification tapped');

    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        onNotificationTap?.call(data);
      } catch (e) {
        debugPrint('Failed to parse notification payload: $e');
      }
    }
  }

  /// 로컬 알림 표시
  ///
  /// 포그라운드에서 받은 FCM 메시지를 로컬 알림으로 표시합니다.
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: data != null ? jsonEncode(data) : null,
    );
  }

  /// 수동으로 로컬 알림 표시 (테스트용)
  Future<void> showNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _showLocalNotification(title: title, body: body, data: data);
  }
}

/// 백그라운드 메시지 핸들러 (Top-level function)
///
/// 앱이 백그라운드 또는 종료된 상태에서 메시지를 받을 때 호출됩니다.
/// main.dart에서 Firebase.initializeApp() 후에 등록해야 합니다.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 백그라운드에서는 Firebase가 자동으로 알림을 표시합니다.
  // 추가 처리가 필요한 경우 여기에 로직을 추가합니다.
  debugPrint('Background message received: ${message.messageId}');
}
