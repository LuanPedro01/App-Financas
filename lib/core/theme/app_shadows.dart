import 'package:flutter/material.dart';
import 'package:financeiro/core/theme/app_colors.dart';

abstract final class AppShadows {
  static List<BoxShadow> get sm => [
        BoxShadow(
          color: AppColors.black.withOpacity(0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: AppColors.black.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: AppColors.black.withOpacity(0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
          color: AppColors.black.withOpacity(0.12),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: AppColors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get xl => [
        BoxShadow(
          color: AppColors.black.withOpacity(0.16),
          blurRadius: 48,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: AppColors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> brand({double opacity = 0.35}) => [
        BoxShadow(
          color: AppColors.brand500.withOpacity(opacity),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> income({double opacity = 0.3}) => [
        BoxShadow(
          color: AppColors.income.withOpacity(opacity),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> expense({double opacity = 0.3}) => [
        BoxShadow(
          color: AppColors.expense.withOpacity(opacity),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> coloredCard(Color color, {double opacity = 0.25}) => [
        BoxShadow(
          color: color.withOpacity(opacity),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}
