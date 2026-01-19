/// Todo 카테고리 enum
///
/// Todo 항목의 분류를 위한 카테고리입니다.
/// Firestore에는 name 값(영문)으로 저장됩니다.
enum TodoCategory {
  /// 집안일
  housework('housework', '집안일'),

  /// 쇼핑
  shopping('shopping', '쇼핑'),

  /// 약속
  appointment('appointment', '약속'),

  /// 기념일
  anniversary('anniversary', '기념일'),

  /// 운동
  exercise('exercise', '운동'),

  /// 기타
  other('other', '기타');

  const TodoCategory(this.value, this.displayName);

  /// Firestore 저장용 값 (영문)
  final String value;

  /// UI 표시용 이름 (한글)
  final String displayName;

  /// 문자열에서 TodoCategory 변환
  ///
  /// [value] Firestore에 저장된 카테고리 문자열
  ///
  /// Returns: 매칭되는 [TodoCategory], 없으면 [TodoCategory.other]
  static TodoCategory fromString(String? value) {
    if (value == null) return TodoCategory.other;

    return TodoCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => TodoCategory.other,
    );
  }

  /// 모든 카테고리 목록 (UI 표시용)
  static List<TodoCategory> get allCategories => TodoCategory.values;
}
