import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/couple_provider.dart';
import '../providers/couple_state.dart';
import '../widgets/invite_code_display.dart';
import '../widgets/invite_code_input.dart';

/// 커플 설정 페이지
///
/// 커플 연결을 위한 메인 설정 화면입니다.
/// - Tab 1: 초대 코드 생성 및 표시 (파트너 초대)
/// - Tab 2: 초대 코드 입력 (파트너 합류)
class CoupleSetupPage extends ConsumerStatefulWidget {
  const CoupleSetupPage({super.key});

  @override
  ConsumerState<CoupleSetupPage> createState() => _CoupleSetupPageState();
}

class _CoupleSetupPageState extends ConsumerState<CoupleSetupPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coupleState = ref.watch(coupleControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // 커플 연결 완료 시 홈으로 이동
    ref.listen<CoupleState>(coupleControllerProvider, (previous, next) {
      if (next is CoupleConnected) {
        context.go(Routes.home);
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          '커플 연결',
          style: AppTextStyles.appBarTitle.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(colorScheme),
            const SizedBox(height: 24),

            // 탭 바
            _buildTabBar(colorScheme),
            const SizedBox(height: 24),

            // 탭 콘텐츠
            Expanded(
              child: _buildTabContent(coupleState, colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // 아이콘
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // 타이틀
          Text(
            '파트너와 연결하기',
            style: AppTextStyles.headlineSmall.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '함께 할 일을 관리하고 공유하세요',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: AppTextStyles.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.labelLarge,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: '초대 코드 생성'),
          Tab(text: '코드 입력'),
        ],
      ),
    );
  }

  Widget _buildTabContent(CoupleState state, ColorScheme colorScheme) {
    return TabBarView(
      controller: _tabController,
      children: [
        // Tab 1: 초대 코드 생성
        _buildCreateTab(state, colorScheme),

        // Tab 2: 코드 입력
        _buildJoinTab(state, colorScheme),
      ],
    );
  }

  Widget _buildCreateTab(CoupleState state, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: state.maybeWhen(
        loading: () => _buildLoadingState(colorScheme),
        waitingForPartner: (couple) => Column(
          children: [
            InviteCodeDisplay(inviteCode: couple.inviteCode),
            const SizedBox(height: 32),
            _buildWaitingMessage(colorScheme),
          ],
        ),
        error: (message) => _buildErrorState(
          message,
          colorScheme,
          onRetry: () => ref.read(coupleControllerProvider.notifier).clearError(),
        ),
        orElse: () => _buildCreateCodeButton(colorScheme),
      ),
    );
  }

  Widget _buildJoinTab(CoupleState state, ColorScheme colorScheme) {
    final errorMessage = state is CoupleError ? state.message : null;
    final isLoading = state is CoupleLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: isLoading
          ? _buildLoadingState(colorScheme)
          : InviteCodeInput(
              enabled: !isLoading,
              errorMessage: errorMessage,
              onSubmit: (code) {
                ref.read(coupleControllerProvider.notifier).joinCouple(
                      inviteCode: code,
                    );
              },
            ),
    );
  }

  Widget _buildCreateCodeButton(ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.qr_code_rounded,
                size: 64,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                '초대 코드를 생성하여\n파트너에게 공유하세요',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () {
            ref.read(coupleControllerProvider.notifier).createInviteCode();
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text(
            '초대 코드 생성',
            style: AppTextStyles.button.copyWith(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingMessage(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '파트너를 기다리는 중...',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.infoDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '파트너가 코드를 입력하면 자동으로 연결됩니다',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            '처리 중...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    String message,
    ColorScheme colorScheme, {
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.bodyLarge.copyWith(
              color: colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
