import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/fcm_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

part 'notification_provider.g.dart';

/// FCM 토큰 Provider
///
/// 현재 기기의 FCM 토큰을 관리합니다.
@riverpod
class FcmToken extends _$FcmToken {
  @override
  Future<String?> build() async {
    // FCM 토큰 획득
    final token = await FcmService.instance.getToken();
    return token;
  }

  /// FCM 토큰 새로고침
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => FcmService.instance.getToken());
  }
}

/// 푸시 알림 관리 Provider
///
/// FCM 토큰을 Firestore에 저장하고 알림 설정을 관리합니다.
@riverpod
class PushNotificationManager extends _$PushNotificationManager {
  @override
  Future<void> build() async {
    // 초기화 시 별도 작업 없음
  }

  /// FCM 토큰을 Firestore에 저장
  ///
  /// 로그인 후 또는 토큰 갱신 시 호출합니다.
  Future<void> saveFcmToken() async {
    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        debugPrint('Cannot save FCM token: User not logged in');
        return;
      }

      final token = await FcmService.instance.getToken();
      if (token == null) {
        debugPrint('Cannot save FCM token: Token is null');
        return;
      }

      // Firestore에 토큰 저장
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'fcmToken': token,
        'notificationsEnabled': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('FCM token saved to Firestore');
    } catch (e) {
      debugPrint('Failed to save FCM token: $e');
      rethrow;
    }
  }

  /// FCM 토큰 삭제 (Firestore에서)
  ///
  /// 로그아웃 시 또는 알림 비활성화 시 호출합니다.
  Future<void> removeFcmToken() async {
    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        debugPrint('Cannot remove FCM token: User not logged in');
        return;
      }

      // Firestore에서 토큰 삭제
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'fcmToken': FieldValue.delete(),
        'notificationsEnabled': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('FCM token removed from Firestore');
    } catch (e) {
      debugPrint('Failed to remove FCM token: $e');
      rethrow;
    }
  }

  /// 알림 활성화/비활성화
  ///
  /// 설정 화면에서 알림 토글 시 호출합니다.
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        debugPrint('Cannot update notification settings: User not logged in');
        return;
      }

      if (enabled) {
        // 알림 활성화: 토큰 저장
        await saveFcmToken();
      } else {
        // 알림 비활성화: 토큰 삭제
        await removeFcmToken();
      }

      // 로컬 설정도 업데이트
      await ref.read(notificationSettingsProvider.notifier).setEnabled(enabled);

      debugPrint('Notifications ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('Failed to update notification settings: $e');
      rethrow;
    }
  }
}

/// 파트너에게 푸시 알림 전송 Provider
///
/// 투두 생성/완료/삭제 시 파트너에게 알림을 전송합니다.
///
/// 주의: 이 방식은 클라이언트에서 직접 HTTP 요청을 보내는 방식으로,
/// 프로덕션에서는 보안상 Cloud Functions 사용을 권장합니다.
@riverpod
class NotificationSender extends _$NotificationSender {
  @override
  Future<void> build() async {
    // 초기화 시 별도 작업 없음
  }

  /// 파트너의 FCM 토큰 조회
  Future<String?> _getPartnerFcmToken(String partnerId) async {
    try {
      final partnerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(partnerId)
          .get();

      if (!partnerDoc.exists) {
        debugPrint('Partner document not found');
        return null;
      }

      final data = partnerDoc.data();
      final notificationsEnabled = data?['notificationsEnabled'] ?? false;

      if (!notificationsEnabled) {
        debugPrint('Partner has notifications disabled');
        return null;
      }

      return data?['fcmToken'] as String?;
    } catch (e) {
      debugPrint('Failed to get partner FCM token: $e');
      return null;
    }
  }

  /// 새 투두 생성 알림 전송
  Future<void> sendTodoCreatedNotification({
    required String partnerId,
    required String todoTitle,
    required String creatorName,
  }) async {
    await _sendNotificationToPartner(
      partnerId: partnerId,
      title: '새로운 할 일이 추가되었어요',
      body: '$creatorName님이 "$todoTitle"을(를) 추가했습니다',
      data: {'type': 'todo_created'},
    );
  }

  /// 투두 완료 알림 전송
  Future<void> sendTodoCompletedNotification({
    required String partnerId,
    required String todoTitle,
    required String completerName,
  }) async {
    await _sendNotificationToPartner(
      partnerId: partnerId,
      title: '할 일을 완료했어요!',
      body: '$completerName님이 "$todoTitle"을(를) 완료했습니다',
      data: {'type': 'todo_completed'},
    );
  }

  /// 투두 삭제 알림 전송
  Future<void> sendTodoDeletedNotification({
    required String partnerId,
    required String todoTitle,
    required String deleterName,
  }) async {
    await _sendNotificationToPartner(
      partnerId: partnerId,
      title: '할 일이 삭제되었어요',
      body: '$deleterName님이 "$todoTitle"을(를) 삭제했습니다',
      data: {'type': 'todo_deleted'},
    );
  }

  /// 파트너에게 알림 전송 (내부 메서드)
  ///
  /// Firestore를 통해 알림 데이터를 저장하여 Cloud Functions에서 처리하거나,
  /// 클라이언트에서 직접 로컬 알림으로 표시할 수 있습니다.
  Future<void> _sendNotificationToPartner({
    required String partnerId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final partnerToken = await _getPartnerFcmToken(partnerId);

      if (partnerToken == null) {
        debugPrint('Cannot send notification: Partner token not available');
        return;
      }

      // Firestore에 알림 기록 저장
      // Cloud Functions가 이를 감지하여 실제 푸시 알림을 전송할 수 있습니다.
      await FirebaseFirestore.instance.collection('notifications').add({
        'recipientId': partnerId,
        'recipientToken': partnerToken,
        'title': title,
        'body': body,
        'data': data,
        'createdAt': FieldValue.serverTimestamp(),
        'sent': false,
      });

      debugPrint('Notification queued for partner: $partnerId');
    } catch (e) {
      debugPrint('Failed to send notification: $e');
      // 알림 전송 실패는 주요 기능에 영향을 주지 않도록 예외를 던지지 않습니다.
    }
  }
}
