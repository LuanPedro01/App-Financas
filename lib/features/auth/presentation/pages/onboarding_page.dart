import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:financeiro/core/theme/app_colors.dart';
import 'package:financeiro/core/theme/app_spacing.dart';
import 'package:financeiro/core/theme/app_typography.dart';
import 'package:financeiro/features/auth/providers/auth_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingData(
      icon: Icons.account_balance_wallet_rounded,
      gradientColors: [AppColors.brand500, AppColors.brand700],
      title: 'Controle total\nsuas finanças',
      subtitle:
          'Acompanhe receitas, despesas e investimentos em um único lugar. Tome decisões financeiras mais inteligentes.',
    ),
    _OnboardingData(
      icon: Icons.bar_chart_rounded,
      gradientColors: [AppColors.accent500, AppColors.accent700],
      title: 'Relatórios\ndetalhados',
      subtitle:
          'Visualize gráficos interativos, tendências de gastos e compare meses para entender melhor seus hábitos.',
    ),
    _OnboardingData(
      icon: Icons.flag_rounded,
      gradientColors: [AppColors.success500, AppColors.success600],
      title: 'Metas que\nfuncionam',
      subtitle:
          'Defina objetivos financeiros, acompanhe o progresso e celebre cada conquista. Seu futuro começa hoje.',
    ),
    _OnboardingData(
      icon: Icons.lock_rounded,
      gradientColors: [AppColors.dark500, AppColors.dark600],
      title: 'Privacidade\ngarantida',
      subtitle:
          'Todos os dados ficam no seu dispositivo. Biometria e PIN opcionais. Sem contas, sem rastreamento.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _complete();
    }
  }

  void _complete() {
    ref.read(authStateProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: scheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (ctx, i) => _PageContent(data: _pages[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl2,
                0,
                AppSpacing.xl2,
                AppSpacing.xl2,
              ),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? scheme.primary
                              : scheme.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl2),
                  // CTA Button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    height: AppSpacing.buttonHeight,
                    decoration: BoxDecoration(
                      gradient: isLast
                          ? AppColors.brandGradient
                          : const LinearGradient(
                              colors: [AppColors.brand500, AppColors.accent500],
                            ),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.buttonRadius),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brand500.withOpacity(0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.buttonRadius),
                      child: InkWell(
                        onTap: _next,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.buttonRadius),
                        child: Center(
                          child: Text(
                            isLast ? 'Começar agora' : 'Continuar',
                            style: AppTypography.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!isLast) ...[
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: _complete,
                      child: Text(
                        'Pular introdução',
                        style: AppTypography.bodySmall.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({required this.data});

  final _OnboardingData data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: data.gradientColors,
              ),
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: data.gradientColors[0].withOpacity(0.35),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(
              data.icon,
              size: 56,
              color: Colors.white,
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.7, 0.7),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
              )
              .fadeIn(),
          const SizedBox(height: AppSpacing.xl3),
          Text(
            data.title,
            style: AppTypography.h2.copyWith(
              color: scheme.onBackground,
            ),
            textAlign: TextAlign.center,
          )
              .animate(delay: const Duration(milliseconds: 100))
              .fadeIn(duration: const Duration(milliseconds: 400))
              .slideY(begin: 0.2),
          const SizedBox(height: AppSpacing.lg),
          Text(
            data.subtitle,
            style: AppTypography.bodyLarge.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          )
              .animate(delay: const Duration(milliseconds: 150))
              .fadeIn(duration: const Duration(milliseconds: 400))
              .slideY(begin: 0.2),
        ],
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.icon,
    required this.gradientColors,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final String subtitle;
}
