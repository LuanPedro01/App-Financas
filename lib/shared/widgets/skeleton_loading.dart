import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:financeiro/core/theme/app_colors.dart';
import 'package:financeiro/core/theme/app_spacing.dart';

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark
          ? AppColors.dark600
          : AppColors.light700,
      highlightColor: isDark
          ? AppColors.dark500
          : AppColors.light600,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.dark600 : AppColors.light700,
          borderRadius:
              BorderRadius.circular(borderRadius ?? AppSpacing.cardSmallRadius),
        ),
      ),
    );
  }
}

class TransactionSkeleton extends StatelessWidget {
  const TransactionSkeleton({super.key, this.count = 5});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (i) => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHPadding,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              SkeletonBox(
                width: AppSpacing.avatarSize,
                height: AppSpacing.avatarSize,
                borderRadius: AppSpacing.avatarSize / 2,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(
                      width: double.infinity,
                      height: 14,
                      borderRadius: 7,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SkeletonBox(
                      width: 80,
                      height: 11,
                      borderRadius: 5.5,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              SkeletonBox(
                width: 70,
                height: 16,
                borderRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.pageInsets,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl2),
          // Balance card skeleton
          SkeletonBox(
            width: double.infinity,
            height: 160,
            borderRadius: AppSpacing.cardRadius,
          ),
          const SizedBox(height: AppSpacing.lg),
          // Stats row
          Row(
            children: [
              Expanded(
                child: SkeletonBox(
                  width: double.infinity,
                  height: 90,
                  borderRadius: AppSpacing.cardRadius,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SkeletonBox(
                  width: double.infinity,
                  height: 90,
                  borderRadius: AppSpacing.cardRadius,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Chart skeleton
          SkeletonBox(
            width: double.infinity,
            height: 220,
            borderRadius: AppSpacing.cardRadius,
          ),
          const SizedBox(height: AppSpacing.lg),
          // Transactions list skeleton
          const TransactionSkeleton(count: 4),
        ],
      ),
    );
  }
}

class CardSkeleton extends StatelessWidget {
  const CardSkeleton({super.key, this.count = 2});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (i) => Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: SkeletonBox(
            width: double.infinity,
            height: 120,
            borderRadius: AppSpacing.cardRadius,
          ),
        ),
      ),
    );
  }
}
