import 'dart:math';

/// 초대 코드 생성기
///
/// 커플 매칭을 위한 6자리 영숫자 초대 코드를 생성합니다.
/// 대문자 알파벳과 숫자로 구성되며, 혼동하기 쉬운 문자(0, O, I, L, 1)는 제외됩니다.
class InviteCodeGenerator {
  InviteCodeGenerator({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  /// 초대 코드에 사용할 문자 집합
  /// 혼동하기 쉬운 문자 제외: 0(숫자), O(알파벳), I, L, 1
  static const String _characters = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

  /// 기본 초대 코드 길이
  static const int defaultCodeLength = 6;

  /// 초대 코드 생성
  ///
  /// [length] 생성할 코드의 길이 (기본값: 6)
  ///
  /// Returns: 대문자 영숫자로 구성된 초대 코드
  String generate({int length = defaultCodeLength}) {
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      final index = _random.nextInt(_characters.length);
      buffer.write(_characters[index]);
    }
    return buffer.toString();
  }

  /// 초대 코드 유효성 검사
  ///
  /// [code] 검사할 초대 코드
  ///
  /// Returns: 유효한 형식이면 true
  static bool isValidFormat(String code) {
    if (code.length != defaultCodeLength) {
      return false;
    }

    // 대문자로 변환 후 모든 문자가 허용된 문자인지 확인
    final upperCode = code.toUpperCase();
    for (var i = 0; i < upperCode.length; i++) {
      if (!_characters.contains(upperCode[i])) {
        return false;
      }
    }

    return true;
  }

  /// 초대 코드 정규화 (대문자 변환 및 공백 제거)
  ///
  /// [code] 정규화할 초대 코드
  ///
  /// Returns: 정규화된 초대 코드
  static String normalize(String code) {
    return code.toUpperCase().replaceAll(RegExp(r'\s'), '');
  }
}
