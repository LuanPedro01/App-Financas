import 'package:flutter/material.dart';
import 'package:financeiro/core/theme/app_colors.dart';
import 'package:financeiro/core/theme/app_spacing.dart';
import 'package:financeiro/core/theme/app_typography.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  static const _defaultCategories = [
    _Category('Alimentação', Icons.restaurant_rounded, AppColors.categoryFood, 'expense'),
    _Category('Transporte', Icons.directions_car_rounded, AppColors.categoryTransport, 'expense'),
    _Category('Saúde', Icons.favorite_rounded, AppColors.categoryHealth, 'expense'),
    _Category('Educação', Icons.school_rounded, AppColors.categoryEducation, 'expense'),
    _Category('Lazer', Icons.movie_rounded, AppColors.categoryEntertainment, 'expense'),
    _Category('Moradia', Icons.home_rounded, AppColors.categoryHome, 'expense'),
    _Category('Compras', Icons.shopping_bag_rounded, AppColors.categoryShopping, 'expense'),
    _Category('Viagem', Icons.flight_rounded, AppColors.categoryTravel, 'expense'),
    _Category('Salário', Icons.work_rounded, AppColors.categoryIncome, 'income'),
    _Category('Freelance', Icons.laptop_mac_rounded, AppColors.categoryIncome, 'income'),
    _Category('Investimentos', Icons.trending_up_rounded, AppColors.categoryInvestment, 'income'),
    _Category('Outros', Icons.more_horiz_rounded, AppColors.categoryOther, 'both'),
  ];

  @override
  Widget build(BuildContext context) {
    final expense = _defaultCategories.where((c) => c.type == 'expense').toList();
    final income = _defaultCategories.where((c) => c.type == 'income').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          _SectionHeader(title: 'Despesas', count: expense.length),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHPadding,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.9,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
            ),
            itemCount: expense.length,
            itemBuilder: (ctx, i) => _CategoryGridItem(category: expense[i]),
          ),
          _SectionHeader(title: 'Receitas', count: income.length),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHPadding,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.9,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
            ),
            itemCount: income.length,
            itemBuilder: (ctx, i) => _CategoryGridItem(category: income[i]),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHPadding,
        AppSpacing.xl,
        AppSpacing.pageHPadding,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: AppTypography.overline.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            ),
            child: Text(
              '$count',
              style: AppTypography.overline.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryGridItem extends StatelessWidget {
  const _CategoryGridItem({required this.category});

  final _Category category;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(category.icon, color: category.color, size: 22),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            category.name,
            style: AppTypography.overline.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Category {
  const _Category(this.name, this.icon, this.color, this.type);
  final String name;
  final IconData icon;
  final Color color;
  final String type;
}
