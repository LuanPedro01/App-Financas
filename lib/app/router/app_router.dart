import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financeiro/app/router/route_paths.dart';
import 'package:financeiro/features/auth/providers/auth_provider.dart';
import 'package:financeiro/features/auth/presentation/pages/splash_page.dart';
import 'package:financeiro/features/auth/presentation/pages/onboarding_page.dart';
import 'package:financeiro/features/auth/presentation/pages/pin_setup_page.dart';
import 'package:financeiro/features/auth/presentation/pages/pin_unlock_page.dart';
import 'package:financeiro/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:financeiro/features/transactions/presentation/pages/transactions_page.dart';
import 'package:financeiro/features/transactions/presentation/pages/add_transaction_page.dart';
import 'package:financeiro/features/transactions/presentation/pages/transaction_detail_page.dart';
import 'package:financeiro/features/accounts/presentation/pages/accounts_page.dart';
import 'package:financeiro/features/accounts/presentation/pages/add_account_page.dart';
import 'package:financeiro/features/accounts/presentation/pages/account_detail_page.dart';
import 'package:financeiro/features/cards/presentation/pages/cards_page.dart';
import 'package:financeiro/features/cards/presentation/pages/add_card_page.dart';
import 'package:financeiro/features/cards/presentation/pages/card_detail_page.dart';
import 'package:financeiro/features/budgets/presentation/pages/budgets_page.dart';
import 'package:financeiro/features/budgets/presentation/pages/add_budget_page.dart';
import 'package:financeiro/features/goals/presentation/pages/goals_page.dart';
import 'package:financeiro/features/goals/presentation/pages/add_goal_page.dart';
import 'package:financeiro/features/goals/presentation/pages/goal_detail_page.dart';
import 'package:financeiro/features/investments/presentation/pages/investments_page.dart';
import 'package:financeiro/features/investments/presentation/pages/add_investment_page.dart';
import 'package:financeiro/features/reports/presentation/pages/reports_page.dart';
import 'package:financeiro/features/analytics/presentation/pages/analytics_page.dart';
import 'package:financeiro/features/categories/presentation/pages/categories_page.dart';
import 'package:financeiro/features/settings/presentation/pages/settings_page.dart';
import 'package:financeiro/features/settings/presentation/pages/settings_security_page.dart';
import 'package:financeiro/features/settings/presentation/pages/settings_theme_page.dart';
import 'package:financeiro/features/settings/presentation/pages/settings_backup_page.dart';
import 'package:financeiro/shared/widgets/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    debugLogDiagnostics: false,
    initialLocation: RoutePaths.splash,
    redirect: (context, state) {
      final status = authState.status;
      final location = state.matchedLocation;

      // Splash always passes through
      if (location == RoutePaths.splash) return null;

      return switch (status) {
        AuthStatus.initial => RoutePaths.splash,
        AuthStatus.onboarding => location == RoutePaths.onboarding
            ? null
            : RoutePaths.onboarding,
        AuthStatus.pinSetup => location == RoutePaths.pinSetup
            ? null
            : RoutePaths.pinSetup,
        AuthStatus.locked => location == RoutePaths.pinUnlock
            ? null
            : RoutePaths.pinUnlock,
        AuthStatus.authenticated => location.startsWith('/app')
            ? null
            : RoutePaths.dashboard,
        AuthStatus.unauthenticated => location == RoutePaths.onboarding
            ? null
            : RoutePaths.onboarding,
      };
    },
    routes: [
      // ─── Auth routes ────────────────────────────────────────────────────
      GoRoute(
        path: RoutePaths.splash,
        pageBuilder: (ctx, state) => _fade(state, const SplashPage()),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        pageBuilder: (ctx, state) => _slide(state, const OnboardingPage()),
      ),
      GoRoute(
        path: RoutePaths.pinSetup,
        pageBuilder: (ctx, state) =>
            _slide(state, const PinSetupPage(isChange: false)),
      ),
      GoRoute(
        path: RoutePaths.pinUnlock,
        pageBuilder: (ctx, state) => _fade(state, const PinUnlockPage()),
      ),

      // ─── Shell (main navigation) ────────────────────────────────────────
      ShellRoute(
        builder: (ctx, state, child) => MainShell(child: child),
        routes: [
          // Dashboard
          GoRoute(
            path: RoutePaths.dashboard,
            pageBuilder: (ctx, state) =>
                _noTransition(state, const DashboardPage()),
          ),

          // Transactions
          GoRoute(
            path: RoutePaths.transactions,
            pageBuilder: (ctx, state) =>
                _noTransition(state, const TransactionsPage()),
            routes: [
              GoRoute(
                path: 'add',
                pageBuilder: (ctx, state) {
                  final type = state.uri.queryParameters['type'];
                  return _slideUp(
                    state,
                    AddTransactionPage(initialType: type),
                  );
                },
              ),
              GoRoute(
                path: 'edit/:id',
                pageBuilder: (ctx, state) => _slideUp(
                  state,
                  AddTransactionPage(editId: state.pathParameters['id']),
                ),
              ),
              GoRoute(
                path: 'detail/:id',
                pageBuilder: (ctx, state) => _slide(
                  state,
                  TransactionDetailPage(id: state.pathParameters['id']!),
                ),
              ),
            ],
          ),

          // Accounts
          GoRoute(
            path: RoutePaths.accounts,
            pageBuilder: (ctx, state) =>
                _noTransition(state, const AccountsPage()),
            routes: [
              GoRoute(
                path: 'add',
                pageBuilder: (ctx, state) =>
                    _slideUp(state, const AddAccountPage()),
              ),
              GoRoute(
                path: 'edit/:id',
                pageBuilder: (ctx, state) => _slideUp(
                  state,
                  AddAccountPage(editId: state.pathParameters['id']),
                ),
              ),
              GoRoute(
                path: 'detail/:id',
                pageBuilder: (ctx, state) => _slide(
                  state,
                  AccountDetailPage(id: state.pathParameters['id']!),
                ),
              ),
            ],
          ),

          // Cards
          GoRoute(
            path: RoutePaths.cards,
            pageBuilder: (ctx, state) =>
                _noTransition(state, const CardsPage()),
            routes: [
              GoRoute(
                path: 'add',
                pageBuilder: (ctx, state) =>
                    _slideUp(state, const AddCardPage()),
              ),
              GoRoute(
                path: 'edit/:id',
                pageBuilder: (ctx, state) => _slideUp(
                  state,
                  AddCardPage(editId: state.pathParameters['id']),
                ),
              ),
              GoRoute(
                path: 'detail/:id',
                pageBuilder: (ctx, state) => _slide(
                  state,
                  CardDetailPage(id: state.pathParameters['id']!),
                ),
              ),
            ],
          ),

          // Budgets
          GoRoute(
            path: RoutePaths.budgets,
            pageBuilder: (ctx, state) =>
                _noTransition(state, const BudgetsPage()),
            routes: [
              GoRoute(
                path: 'add',
                pageBuilder: (ctx, state) =>
                    _slideUp(state, const AddBudgetPage()),
              ),
              GoRoute(
                path: 'edit/:id',
                pageBuilder: (ctx, state) => _slideUp(
                  state,
                  AddBudgetPage(editId: state.pathParameters['id']),
                ),
              ),
            ],
          ),

          // Goals
          GoRoute(
            path: RoutePaths.goals,
            pageBuilder: (ctx, state) =>
                _noTransition(state, const GoalsPage()),
            routes: [
              GoRoute(
                path: 'add',
                pageBuilder: (ctx, state) =>
                    _slideUp(state, const AddGoalPage()),
              ),
              GoRoute(
                path: 'edit/:id',
                pageBuilder: (ctx, state) => _slideUp(
                  state,
                  AddGoalPage(editId: state.pathParameters['id']),
                ),
              ),
              GoRoute(
                path: 'detail/:id',
                pageBuilder: (ctx, state) => _slide(
                  state,
                  GoalDetailPage(id: state.pathParameters['id']!),
                ),
              ),
            ],
          ),

          // Investments
          GoRoute(
            path: RoutePaths.investments,
            pageBuilder: (ctx, state) =>
                _noTransition(state, const InvestmentsPage()),
            routes: [
              GoRoute(
                path: 'add',
                pageBuilder: (ctx, state) =>
                    _slideUp(state, const AddInvestmentPage()),
              ),
            ],
          ),

          // Reports
          GoRoute(
            path: RoutePaths.reports,
            pageBuilder: (ctx, state) =>
                _noTransition(state, const ReportsPage()),
          ),

          // Analytics
          GoRoute(
            path: RoutePaths.analytics,
            pageBuilder: (ctx, state) =>
                _noTransition(state, const AnalyticsPage()),
          ),

          // Categories
          GoRoute(
            path: RoutePaths.categories,
            pageBuilder: (ctx, state) =>
                _slide(state, const CategoriesPage()),
          ),

          // Settings
          GoRoute(
            path: RoutePaths.settings,
            pageBuilder: (ctx, state) =>
                _noTransition(state, const SettingsPage()),
            routes: [
              GoRoute(
                path: 'security',
                pageBuilder: (ctx, state) =>
                    _slide(state, const SettingsSecurityPage()),
              ),
              GoRoute(
                path: 'theme',
                pageBuilder: (ctx, state) =>
                    _slide(state, const SettingsThemePage()),
              ),
              GoRoute(
                path: 'backup',
                pageBuilder: (ctx, state) =>
                    _slide(state, const SettingsBackupPage()),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (ctx, state) => Scaffold(
      body: Center(child: Text('Rota não encontrada: ${state.error}')),
    ),
  );
});

// ─── Page transition helpers ──────────────────────────────────────────────────
CustomTransitionPage<T> _fade<T>(GoRouterState state, Widget child) =>
    CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (ctx, animation, _, child) => FadeTransition(
        opacity: animation,
        child: child,
      ),
    );

CustomTransitionPage<T> _slide<T>(GoRouterState state, Widget child) =>
    CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (ctx, animation, _, child) {
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );

CustomTransitionPage<T> _slideUp<T>(GoRouterState state, Widget child) =>
    CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (ctx, animation, _, child) {
        final tween = Tween(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );

CustomTransitionPage<T> _noTransition<T>(GoRouterState state, Widget child) =>
    NoTransitionPage<T>(key: state.pageKey, child: child);
