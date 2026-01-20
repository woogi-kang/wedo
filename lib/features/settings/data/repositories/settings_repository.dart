import 'package:shared_preferences/shared_preferences.dart';

/// Settings 예외 클래스
class SettingsException implements Exception {
  const SettingsException(this.message);
  final String message;

  @override
  String toString() => 'SettingsException: $message';
}

/// Settings Repository
///
/// SharedPreferences를 사용하여 앱 설정을 로컬에 저장하고 관리합니다.
/// 알림 설정, 테마 설정 등 사용자 환경설정을 처리합니다.
abstract class SettingsRepository {
  /// 알림 설정 조회
  Future<bool> getNotificationsEnabled();

  /// 알림 설정 저장
  Future<void> setNotificationsEnabled(bool enabled);

  /// 테마 모드 조회 ('system', 'light', 'dark')
  Future<String> getThemeMode();

  /// 테마 모드 저장
  Future<void> setThemeMode(String mode);

  /// 모든 설정 초기화
  Future<void> clearSettings();
}

/// Settings Repository 구현체
///
/// SharedPreferences를 사용하여 설정을 영구 저장합니다.
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  // SharedPreferences 키 상수
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyThemeMode = 'theme_mode';

  // 기본값
  static const bool _defaultNotificationsEnabled = true;
  static const String _defaultThemeMode = 'system';

  // 유효한 테마 모드 목록
  static const List<String> _validThemeModes = ['system', 'light', 'dark'];

  @override
  Future<bool> getNotificationsEnabled() async {
    try {
      return _prefs.getBool(_keyNotificationsEnabled) ??
          _defaultNotificationsEnabled;
    } catch (e) {
      // SharedPreferences 읽기 실패 시 기본값 반환
      return _defaultNotificationsEnabled;
    }
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      final result = await _prefs.setBool(_keyNotificationsEnabled, enabled);
      if (!result) {
        throw const SettingsException('알림 설정 저장에 실패했습니다.');
      }
    } catch (e) {
      if (e is SettingsException) rethrow;
      throw SettingsException('알림 설정 저장 중 오류 발생: $e');
    }
  }

  @override
  Future<String> getThemeMode() async {
    try {
      final mode = _prefs.getString(_keyThemeMode) ?? _defaultThemeMode;
      // 유효하지 않은 테마 모드인 경우 기본값 반환
      if (!_validThemeModes.contains(mode)) {
        return _defaultThemeMode;
      }
      return mode;
    } catch (e) {
      // SharedPreferences 읽기 실패 시 기본값 반환
      return _defaultThemeMode;
    }
  }

  @override
  Future<void> setThemeMode(String mode) async {
    // 유효한 테마 모드인지 검증
    if (!_validThemeModes.contains(mode)) {
      throw SettingsException(
        '유효하지 않은 테마 모드입니다. 허용: ${_validThemeModes.join(", ")}',
      );
    }

    try {
      final result = await _prefs.setString(_keyThemeMode, mode);
      if (!result) {
        throw const SettingsException('테마 설정 저장에 실패했습니다.');
      }
    } catch (e) {
      if (e is SettingsException) rethrow;
      throw SettingsException('테마 설정 저장 중 오류 발생: $e');
    }
  }

  @override
  Future<void> clearSettings() async {
    try {
      final results = await Future.wait([
        _prefs.remove(_keyNotificationsEnabled),
        _prefs.remove(_keyThemeMode),
      ]);

      // 모든 삭제 작업이 성공했는지 확인
      if (results.any((result) => !result)) {
        throw const SettingsException('일부 설정 초기화에 실패했습니다.');
      }
    } catch (e) {
      if (e is SettingsException) rethrow;
      throw SettingsException('설정 초기화 중 오류 발생: $e');
    }
  }
}
