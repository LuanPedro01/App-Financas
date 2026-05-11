import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:financeiro/core/theme/app_colors.dart';
import 'package:financeiro/core/theme/app_typography.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brand500.withValues(alpha: 0.4),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 40,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: const Duration(milliseconds: 400)),
            const SizedBox(height: 24),
            Text(
              'Financeiro',
              style: AppTypography.h2.copyWith(
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            )
                .animate(delay: const Duration(milliseconds: 200))
                .fadeIn(duration: const Duration(milliseconds: 400))
                .slideY(
                  begin: 0.3,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                ),
            const SizedBox(height: 8),
            Text(
              'Suas finanças sob controle',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.dark200,
              ),
            )
                .animate(delay: const Duration(milliseconds: 300))
                .fadeIn(duration: const Duration(milliseconds: 400)),
          ],
        ),
      ),
    );
  }
}
