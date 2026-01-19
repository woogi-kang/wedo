import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/category.dart';
import 'category_selector.dart';
import 'date_time_picker.dart';

/// Todo 폼 데이터 모델
///
/// 폼 입력값을 담는 데이터 클래스입니다.
class TodoFormData {
  const TodoFormData({
    required this.title,
    this.description,
    this.category,
    this.dueDate,
    this.dueTime,
  });

  /// 제목 (필수)
  final String title;

  /// 설명 (선택)
  final String? description;

  /// 카테고리 (선택)
  final TodoCategory? category;

  /// 마감일 (선택)
  final DateTime? dueDate;

  /// 마감 시간 (선택, "HH:mm" 형식)
  final String? dueTime;
}

/// Todo 폼 위젯
///
/// 할 일 생성/수정에 사용되는 재사용 가능한 폼 위젯입니다.
/// - 제목 입력 (필수)
/// - 설명 입력 (선택, 여러 줄)
/// - 카테고리 선택 (칩 형태)
/// - 마감일/시간 선택
///
/// 사용 예:
/// ```dart
/// TodoForm(
///   onSubmit: (data) async {
///     await controller.createTodo(
///       title: data.title,
///       description: data.description,
///       category: data.category?.value,
///       dueDate: data.dueDate,
///       dueTime: data.dueTime,
///     );
///   },
/// )
/// ```
class TodoForm extends StatefulWidget {
  const TodoForm({
    super.key,
    required this.onSubmit,
    this.initialData,
    this.isLoading = false,
    this.submitButtonText = '저장',
  });

  /// 폼 제출 콜백
  final Future<bool> Function(TodoFormData data) onSubmit;

  /// 초기 데이터 (수정 모드에서 사용)
  final TodoFormData? initialData;

  /// 로딩 상태
  final bool isLoading;

  /// 제출 버튼 텍스트
  final String submitButtonText;

  @override
  State<TodoForm> createState() => _TodoFormState();
}

class _TodoFormState extends State<TodoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  TodoCategory? _selectedCategory;
  DateTime? _dueDate;
  String? _dueTime;

  @override
  void initState() {
    super.initState();

    // 초기값 설정
    _titleController = TextEditingController(
      text: widget.initialData?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialData?.description ?? '',
    );
    _selectedCategory = widget.initialData?.category;
    _dueDate = widget.initialData?.dueDate;
    _dueTime = widget.initialData?.dueTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 제목 입력
          _buildTitleField(theme, colorScheme),
          const SizedBox(height: 20),

          // 설명 입력
          _buildDescriptionField(theme, colorScheme),
          const SizedBox(height: 24),

          // 카테고리 선택
          CategorySelector(
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() => _selectedCategory = category);
            },
          ),
          const SizedBox(height: 24),

          // 날짜/시간 선택
          DateTimePicker(
            selectedDate: _dueDate,
            selectedTime: _dueTime,
            onDateChanged: (date) {
              setState(() {
                _dueDate = date;
                // 날짜가 해제되면 시간도 해제
                if (date == null) {
                  _dueTime = null;
                }
              });
            },
            onTimeChanged: (time) {
              setState(() => _dueTime = time);
            },
          ),
          const SizedBox(height: 32),

          // 제출 버튼
          _buildSubmitButton(theme, colorScheme),
        ],
      ),
    );
  }

  /// 제목 입력 필드 빌드
  Widget _buildTitleField(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '제목',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          enabled: !widget.isLoading,
          autofocus: widget.initialData == null,
          textInputAction: TextInputAction.next,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: '할 일을 입력하세요',
            prefixIcon: Icon(
              Icons.edit_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            errorStyle: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.error,
            ),
          ),
          validator: _validateTitle,
        ),
      ],
    );
  }

  /// 설명 입력 필드 빌드
  Widget _buildDescriptionField(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '설명',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          enabled: !widget.isLoading,
          maxLines: 4,
          minLines: 3,
          textInputAction: TextInputAction.newline,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: '설명을 입력하세요 (선택)',
            alignLabelWithHint: true,
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }

  /// 제출 버튼 빌드
  Widget _buildSubmitButton(ThemeData theme, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: widget.isLoading ? null : _handleSubmit,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: widget.isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                widget.submitButtonText,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  /// 제목 유효성 검사
  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '제목을 입력해주세요.';
    }
    return null;
  }

  /// 폼 제출 처리
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final data = TodoFormData(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      category: _selectedCategory,
      dueDate: _dueDate,
      dueTime: _dueTime,
    );

    await widget.onSubmit(data);
  }
}
