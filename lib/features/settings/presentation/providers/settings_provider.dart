import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/fcm_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/settings_repository.dart';

part 'settings_provider.g.dart';

/// SharedPreferences Provider
///
/// SharedPreferences 인스턴스를 제공합니다.
/// 앱 시작 시 초기화되어야 합니다.
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return await SharedPreferences.getInstance();
}

/// SettingsRepository Provider
///
/// 설정 저장소 인스턴스를 제공합니다.
@Riverpod(keepAlive: true)
Future<SettingsRepository> settingsRepository(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return SettingsRepositoryImpl(prefs);
}

/// 앱 정보 Provider
///
/// 앱 버전 정보를 제공합니다.
@riverpod
Future<PackageInfo> packageInfo(Ref ref) async {
  return await PackageInfo.fromPlatform();
}

/// 알림 설정 상태 Provider
///
/// 알림 활성화 상태를 제공하고 관리합니다.
///
/// keepAlive: true로 설정하여 설정 화면 이동 시에도 알림 상태가 유지됩니다.
@Riverpod(keepAlive: true)
class NotificationSettings extends _$NotificationSettings {
  @override
  Future<bool> build() async {
    final repository = await ref.watch(settingsRepositoryProvider.future);
    return await repository.getNotificationsEnabled();
  }

  /// 알림 설정 토글
  Future<void> toggle() async {
    final repository = await ref.read(settingsRepositoryProvider.future);
    final currentValue = state.valueOrNull ?? true;
    final newValue = !currentValue;

    // 낙관적 업데이트
    state = AsyncData(newValue);

    try {
      await repository.setNotificationsEnabled(newValue);
    } catch (e) {
      // 실패 시 롤백
      state = AsyncData(currentValue);
      rethrow;
    }
  }

  /// 알림 설정 값 직접 설정
  ///
  /// FCM 토큰을 Firestore에 저장하거나 삭제합니다.
  Future<void> setEnabled(bool enabled) async {
    final repository = await ref.read(settingsRepositoryProvider.future);

    // 낙관적 업데이트
    final previousValue = state.valueOrNull ?? true;
    state = AsyncData(enabled);

    try {
      // 로컬 설정 저장
      await repository.setNotificationsEnabled(enabled);

      // FCM 토큰 관리
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        if (enabled) {
          // 알림 활성화: FCM 토큰을 Firestore에 저장
          await _saveFcmTokenToFirestore(currentUser.uid);
        } else {
          // 알림 비활성화: FCM 토큰을 Firestore에서 삭제
          await _removeFcmTokenFromFirestore(currentUser.uid);
        }
      }
    } catch (e) {
      // 실패 시 롤백
      state = AsyncData(previousValue);
      debugPrint('Failed to update notification settings: $e');
      rethrow;
    }
  }

  /// FCM 토큰을 Firestore에 저장
  Future<void> _saveFcmTokenToFirestore(String userId) async {
    try {
      final token = await FcmService.instance.getToken();
      if (token == null) {
        debugPrint('Cannot save FCM token: Token is null');
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
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

  /// FCM 토큰을 Firestore에서 삭제
  Future<void> _removeFcmTokenFromFirestore(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
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
}

/// 테마 모드 상태 Provider
///
/// 앱 테마 모드를 제공하고 관리합니다.
/// 'system', 'light', 'dark' 중 하나의 값을 가집니다.
///
/// keepAlive: true로 설정하여 설정 화면 이동 시에도 테마 상태가 유지됩니다.
@Riverpod(keepAlive: true)
class ThemeModeSettings extends _$ThemeModeSettings {
  @override
  Future<String> build() async {
    final repository = await ref.watch(settingsRepositoryProvider.future);
    return await repository.getThemeMode();
  }

  /// 테마 모드 변경
  Future<void> setThemeMode(String mode) async {
    if (!['system', 'light', 'dark'].contains(mode)) {
      throw ArgumentError('Invalid theme mode: $mode');
    }

    final repository = await ref.read(settingsRepositoryProvider.future);
    final previousValue = state.valueOrNull ?? 'system';

    // 낙관적 업데이트
    state = AsyncData(mode);

    try {
      await repository.setThemeMode(mode);
    } catch (e) {
      // 실패 시 롤백
      state = AsyncData(previousValue);
      rethrow;
    }
  }
}
