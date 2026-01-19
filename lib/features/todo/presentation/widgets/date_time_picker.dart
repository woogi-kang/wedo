import 'package:flutter/material.dart';

/// 날짜 및 시간 선택 위젯
///
/// 마감일과 마감 시간을 선택할 수 있는 결합 위젯입니다.
/// - 날짜: yyyy년 MM월 dd일 형식으로 표시
/// - 시간: HH:mm 형식으로 표시
///
/// 사용 예:
/// ```dart
/// DateTimePicker(
///   selectedDate: _dueDate,
///   selectedTime: _dueTime,
///   onDateChanged: (date) => setState(() => _dueDate = date),
///   onTimeChanged: (time) => setState(() => _dueTime = time),
/// )
/// ```
class DateTimePicker extends StatelessWidget {
  const DateTimePicker({
    super.key,
    this.selectedDate,
    this.selectedTime,
    required this.onDateChanged,
    required this.onTimeChanged,
  });

  /// 선택된 날짜 (null이면 미선택)
  final DateTime? selectedDate;

  /// 선택된 시간 (null이면 미선택, "HH:mm" 형식)
  final String? selectedTime;

  /// 날짜 변경 콜백
  final ValueChanged<DateTime?> onDateChanged;

  /// 시간 변경 콜백
  final ValueChanged<String?> onTimeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 날짜 선택
        _DatePickerField(
          label: '마감일',
          selectedDate: selectedDate,
          onDateChanged: onDateChanged,
        ),

        const SizedBox(height: 16),

        // 시간 선택 (날짜가 선택된 경우에만 활성화)
        _TimePickerField(
          label: '마감 시간',
          selectedTime: selectedTime,
          onTimeChanged: onTimeChanged,
          enabled: selectedDate != null,
        ),
      ],
    );
  }
}

/// 날짜 선택 필드 위젯
class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    this.selectedDate,
    required this.onDateChanged,
  });

  final String label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showDatePicker(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? _formatDate(selectedDate!)
                        : '날짜를 선택하세요',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: selectedDate != null
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                if (selectedDate != null)
                  IconButton(
                    onPressed: () => onDateChanged(null),
                    icon: Icon(
                      Icons.clear_rounded,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = selectedDate ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
      locale: const Locale('ko', 'KR'),
      helpText: '마감일 선택',
      cancelText: '취소',
      confirmText: '확인',
    );

    if (pickedDate != null) {
      onDateChanged(pickedDate);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month.toString().padLeft(2, '0')}월 ${date.day.toString().padLeft(2, '0')}일';
  }
}

/// 시간 선택 필드 위젯
class _TimePickerField extends StatelessWidget {
  const _TimePickerField({
    required this.label,
    this.selectedTime,
    required this.onTimeChanged,
    this.enabled = true,
  });

  final String label;
  final String? selectedTime;
  final ValueChanged<String?> onTimeChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: enabled
                ? colorScheme.onSurfaceVariant
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: enabled ? () => _showTimePicker(context) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: enabled
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: enabled
                    ? colorScheme.outline.withValues(alpha: 0.3)
                    : colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_outlined,
                  size: 20,
                  color: enabled
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedTime ?? (enabled ? '시간을 선택하세요' : '먼저 날짜를 선택하세요'),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: selectedTime != null && enabled
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant.withValues(
                              alpha: enabled ? 0.7 : 0.5,
                            ),
                    ),
                  ),
                ),
                if (selectedTime != null && enabled)
                  IconButton(
                    onPressed: () => onTimeChanged(null),
                    icon: Icon(
                      Icons.clear_rounded,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final initialTime = _parseTime(selectedTime) ?? TimeOfDay.now();

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: '마감 시간 선택',
      cancelText: '취소',
      confirmText: '확인',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      onTimeChanged(_formatTime(pickedTime));
    }
  }

  TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null) return null;

    final parts = timeStr.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
