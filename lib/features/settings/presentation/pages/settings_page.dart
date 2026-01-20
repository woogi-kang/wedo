import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_tile.dart';

/// 설정 화면
///
/// 앱 설정을 관리하는 메인 설정 페이지입니다.
/// - 프로필 섹션: 사용자 이름, 이메일 표시
/// - 커플 정보 섹션: 파트너 이름, 커플 연결일
/// - 알림 설정: ON/OFF 토글
/// - 앱 정보: 버전 정보
/// - 로그아웃 버튼
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 현재 사용자 정보
    final currentUser = ref.watch(currentUserProvider);

    // 알림 설정
    final notificationSettingsAsync = ref.watch(notificationSettingsProvider);

    // 앱 정보
    final packageInfoAsync = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === 프로필 섹션 ===
            ProfileCard(
              name: currentUser?.displayName ?? '사용자',
              email: currentUser?.email ?? '',
              onTap: () {
                // 프로필 상세 페이지로 이동 (구현 예정)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('프로필 수정 기능은 준비 중입니다'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            // === 알림 설정 섹션 ===
            const SettingsSectionHeader(title: '알림'),
            notificationSettingsAsync.when(
              data: (isEnabled) => SettingsToggleTile(
                icon: Icons.notifications_outlined,
                title: '알림',
                subtitle: isEnabled ? '알림이 켜져 있습니다' : '알림이 꺼져 있습니다',
                value: isEnabled,
                onChanged: (value) {
                  ref
                      .read(notificationSettingsProvider.notifier)
                      .setEnabled(value);
                },
              ),
              loading: () => const SettingsTile(
                icon: Icons.notifications_outlined,
                title: '알림',
                subtitle: '로딩 중...',
                trailing: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (error, _) => SettingsTile(
                icon: Icons.notifications_outlined,
                title: '알림',
                subtitle: '설정을 불러올 수 없습니다',
                iconColor: colorScheme.error,
              ),
            ),

            // === 일반 설정 섹션 ===
            const SettingsSectionHeader(title: '일반'),
            SettingsTile(
              icon: Icons.palette_outlined,
              title: '테마',
              subtitle: '시스템 설정',
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
              onTap: () {
                // 테마 설정 페이지로 이동 (구현 예정)
                _showThemeDialog(context, ref);
              },
            ),
            SettingsTile(
              icon: Icons.language_outlined,
              title: '언어',
              subtitle: '한국어',
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('언어 설정 기능은 준비 중입니다'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            // === 앱 정보 섹션 ===
            const SettingsSectionHeader(title: '정보'),
            packageInfoAsync.when(
              data: (info) => SettingsTile(
                icon: Icons.info_outline_rounded,
                title: '앱 버전',
                subtitle: 'v${info.version} (${info.buildNumber})',
                onTap: () {
                  // 앱 정보 페이지로 이동
                  context.push(Routes.settingsAbout);
                },
              ),
              loading: () => const SettingsTile(
                icon: Icons.info_outline_rounded,
                title: '앱 버전',
                subtitle: '로딩 중...',
              ),
              error: (_, __) => const SettingsTile(
                icon: Icons.info_outline_rounded,
                title: '앱 버전',
                subtitle: 'v1.0.0',
              ),
            ),
            SettingsTile(
              icon: Icons.description_outlined,
              title: '이용약관',
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('이용약관 페이지는 준비 중입니다'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: '개인정보 처리방침',
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('개인정보 처리방침 페이지는 준비 중입니다'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            // === 로그아웃 버튼 ===
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context, ref),
                  icon: Icon(
                    Icons.logout_rounded,
                    color: colorScheme.error,
                  ),
                  label: Text(
                    '로그아웃',
                    style: TextStyle(color: colorScheme.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colorScheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // 하단 여백
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// 로그아웃 확인 다이얼로그 표시
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    // 외부 context를 저장하여 다이얼로그 내에서 안전하게 사용
    final rootContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              // 확인 다이얼로그 닫기
              Navigator.of(dialogContext).pop();

              // rootContext가 여전히 mounted 상태인지 확인
              if (!rootContext.mounted) return;

              // 로딩 표시
              showDialog(
                context: rootContext,
                barrierDismissible: false,
                builder: (loadingContext) => const Center(
                  child: LoadingIndicator(message: '로그아웃 중...'),
                ),
              );

              // 로그아웃 실행
              await ref.read(authControllerProvider.notifier).signOut();

              // 로딩 다이얼로그 닫기 및 스플래시 페이지로 이동
              if (rootContext.mounted) {
                Navigator.of(rootContext).pop();
                rootContext.go(Routes.splash);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
            ),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }

  /// 테마 선택 다이얼로그 표시
  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.read(themeModeSettingsProvider);
    final currentMode = themeModeAsync.valueOrNull ?? 'system';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('테마 설정'),
        content: RadioGroup<String>(
          groupValue: currentMode,
          onChanged: (value) {
            if (value != null) {
              ref.read(themeModeSettingsProvider.notifier).setThemeMode(value);
              Navigator.of(dialogContext).pop();
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              _ThemeOption(
                title: '시스템 설정',
                value: 'system',
              ),
              _ThemeOption(
                title: '라이트 모드',
                value: 'light',
              ),
              _ThemeOption(
                title: '다크 모드',
                value: 'dark',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}

/// 테마 옵션 라디오 버튼
class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Text(title),
      value: value,
    );
  }
}
