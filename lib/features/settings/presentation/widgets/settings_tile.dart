import 'package:flutter/material.dart';

/// 설정 타일 위젯
///
/// 설정 화면에서 각 설정 항목을 표시하는 재사용 가능한 위젯입니다.
/// ListTile 기반으로 일관된 UI를 제공합니다.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.enabled = true,
  });

  /// 아이콘
  final IconData icon;

  /// 제목
  final String title;

  /// 부제목 (선택)
  final String? subtitle;

  /// 우측 위젯 (선택)
  final Widget? trailing;

  /// 탭 콜백 (선택)
  final VoidCallback? onTap;

  /// 아이콘 색상 (선택, null이면 primary 사용)
  final Color? iconColor;

  /// 활성화 상태
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? colorScheme.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: enabled
              ? (iconColor ?? colorScheme.primary)
              : colorScheme.onSurface.withValues(alpha: 0.38),
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: enabled
              ? colorScheme.onSurface
              : colorScheme.onSurface.withValues(alpha: 0.38),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: enabled
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurface.withValues(alpha: 0.38),
              ),
            )
          : null,
      trailing: trailing,
      onTap: enabled ? onTap : null,
      enabled: enabled,
    );
  }
}

/// 설정 토글 타일 위젯
///
/// 설정 화면에서 ON/OFF 토글이 있는 설정 항목을 표시합니다.
class SettingsToggleTile extends StatelessWidget {
  const SettingsToggleTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.iconColor,
    this.enabled = true,
  });

  /// 아이콘
  final IconData icon;

  /// 제목
  final String title;

  /// 부제목 (선택)
  final String? subtitle;

  /// 토글 값
  final bool value;

  /// 값 변경 콜백
  final ValueChanged<bool>? onChanged;

  /// 아이콘 색상 (선택)
  final Color? iconColor;

  /// 활성화 상태
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      iconColor: iconColor,
      enabled: enabled,
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
      onTap: enabled && onChanged != null ? () => onChanged!(!value) : null,
    );
  }
}

/// 설정 섹션 헤더 위젯
///
/// 설정 화면에서 섹션을 구분하는 헤더를 표시합니다.
class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader({
    super.key,
    required this.title,
    this.padding,
  });

  /// 섹션 제목
  final String title;

  /// 패딩 (선택)
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: padding ??
          const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 프로필 카드 위젯
///
/// 설정 화면 상단에 사용자 프로필 정보를 표시합니다.
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.name,
    required this.email,
    this.avatarText,
    this.onTap,
  });

  /// 사용자 이름
  final String name;

  /// 사용자 이메일
  final String email;

  /// 아바타에 표시할 텍스트 (선택, null이면 이름 첫 글자 사용)
  final String? avatarText;

  /// 탭 콜백 (선택)
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 아바타 텍스트 결정 (첫 글자 또는 지정된 텍스트)
    final displayText =
        avatarText ?? (name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?');

    return Card(
      margin: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 아바타
              CircleAvatar(
                radius: 30,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  displayText,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 사용자 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // 화살표 아이콘
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 커플 정보 카드 위젯
///
/// 설정 화면에서 커플 정보를 표시합니다.
class CoupleInfoCard extends StatelessWidget {
  const CoupleInfoCard({
    super.key,
    required this.partnerName,
    this.connectedDate,
    this.onTap,
  });

  /// 파트너 이름
  final String partnerName;

  /// 커플 연결일 (선택)
  final DateTime? connectedDate;

  /// 탭 콜백 (선택)
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 연결일 포맷팅
    String? connectedDateText;
    if (connectedDate != null) {
      final diff = DateTime.now().difference(connectedDate!);
      final days = diff.inDays;
      connectedDateText = '함께한 지 ${days + 1}일';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 하트 아이콘
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // 커플 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partnerName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (connectedDateText != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        connectedDateText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // 화살표 아이콘
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
