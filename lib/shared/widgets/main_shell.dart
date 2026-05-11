import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:financeiro/app/router/route_paths.dart';
import 'package:financeiro/core/theme/app_colors.dart';
import 'package:financeiro/core/theme/app_spacing.dart';
import 'package:financeiro/core/theme/app_typography.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;

  static const _tabs = [
    _TabItem(
      label: 'Início',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      route: RoutePaths.dashboard,
    ),
    _TabItem(
      label: 'Transações',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      route: RoutePaths.transactions,
    ),
    _TabItem(
      label: 'Contas',
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
      route: RoutePaths.accounts,
    ),
    _TabItem(
      label: 'Metas',
      icon: Icons.flag_outlined,
      activeIcon: Icons.flag_rounded,
      route: RoutePaths.goals,
    ),
    _TabItem(
      label: 'Mais',
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      route: RoutePaths.settings,
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].route)) {
        if (_selectedIndex != i) {
          setState(() => _selectedIndex = i);
        }
        break;
      }
    }
  }

  void _onTap(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    context.go(_tabs[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: widget.child,
      floatingActionButton: _selectedIndex <= 1
          ? _AddFab(
              onTap: () => context.push(RoutePaths.addTransaction),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border(
            top: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: AppSpacing.bottomNavHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (int i = 0; i < _tabs.length; i++) ...[
                  if (i == 2) const SizedBox(width: 56),
                  Expanded(
                    child: _NavItem(
                      tab: _tabs[i],
                      isSelected: _selectedIndex == i,
                      onTap: () => _onTap(i),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddFab extends StatelessWidget {
  const _AddFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand500.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    ).animate().scale(
          begin: const Offset(0.8, 0.8),
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
        );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  final _TabItem tab;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color =
        isSelected ? scheme.primary : scheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isSelected ? tab.activeIcon : tab.icon,
              color: color,
              size: 24,
              key: ValueKey(isSelected),
            ),
          ),
          const SizedBox(height: 3),
          AnimatedDefaultTextStyle(
            style: AppTypography.overline.copyWith(
              color: color,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            duration: const Duration(milliseconds: 200),
            child: Text(tab.label),
          ),
        ],
      ),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
}
