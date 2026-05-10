abstract final class RoutePaths {
  // ─── Root ─────────────────────────────────────────────────────────────────
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const pinSetup = '/pin-setup';
  static const pinUnlock = '/pin-unlock';

  // ─── Shell ────────────────────────────────────────────────────────────────
  static const shell = '/app';

  // ─── Dashboard ────────────────────────────────────────────────────────────
  static const dashboard = '/app/dashboard';

  // ─── Transactions ─────────────────────────────────────────────────────────
  static const transactions = '/app/transactions';
  static const addTransaction = '/app/transactions/add';
  static const editTransaction = '/app/transactions/edit/:id';
  static const transactionDetail = '/app/transactions/detail/:id';

  // ─── Accounts ─────────────────────────────────────────────────────────────
  static const accounts = '/app/accounts';
  static const addAccount = '/app/accounts/add';
  static const editAccount = '/app/accounts/edit/:id';
  static const accountDetail = '/app/accounts/detail/:id';

  // ─── Cards ────────────────────────────────────────────────────────────────
  static const cards = '/app/cards';
  static const addCard = '/app/cards/add';
  static const editCard = '/app/cards/edit/:id';
  static const cardDetail = '/app/cards/detail/:id';
  static const cardInvoice = '/app/cards/invoice/:id';

  // ─── Budgets ──────────────────────────────────────────────────────────────
  static const budgets = '/app/budgets';
  static const addBudget = '/app/budgets/add';
  static const editBudget = '/app/budgets/edit/:id';

  // ─── Goals ────────────────────────────────────────────────────────────────
  static const goals = '/app/goals';
  static const addGoal = '/app/goals/add';
  static const editGoal = '/app/goals/edit/:id';
  static const goalDetail = '/app/goals/detail/:id';

  // ─── Investments ──────────────────────────────────────────────────────────
  static const investments = '/app/investments';
  static const addInvestment = '/app/investments/add';
  static const investmentDetail = '/app/investments/detail/:id';

  // ─── Reports ──────────────────────────────────────────────────────────────
  static const reports = '/app/reports';
  static const analytics = '/app/analytics';

  // ─── Categories ───────────────────────────────────────────────────────────
  static const categories = '/app/categories';
  static const addCategory = '/app/categories/add';
  static const editCategory = '/app/categories/edit/:id';

  // ─── Subscriptions ────────────────────────────────────────────────────────
  static const subscriptions = '/app/subscriptions';
  static const addSubscription = '/app/subscriptions/add';

  // ─── Settings ─────────────────────────────────────────────────────────────
  static const settings = '/app/settings';
  static const settingsSecurity = '/app/settings/security';
  static const settingsTheme = '/app/settings/theme';
  static const settingsNotifications = '/app/settings/notifications';
  static const settingsBackup = '/app/settings/backup';
  static const settingsProfile = '/app/settings/profile';
  static const settingsCategories = '/app/settings/categories';
  static const settingsCurrencies = '/app/settings/currencies';

  // ─── Helpers ──────────────────────────────────────────────────────────────
  static String editTransactionPath(String id) =>
      '/app/transactions/edit/$id';
  static String transactionDetailPath(String id) =>
      '/app/transactions/detail/$id';
  static String editAccountPath(String id) =>
      '/app/accounts/edit/$id';
  static String accountDetailPath(String id) =>
      '/app/accounts/detail/$id';
  static String editCardPath(String id) => '/app/cards/edit/$id';
  static String cardDetailPath(String id) => '/app/cards/detail/$id';
  static String cardInvoicePath(String id) => '/app/cards/invoice/$id';
  static String editBudgetPath(String id) => '/app/budgets/edit/$id';
  static String editGoalPath(String id) => '/app/goals/edit/$id';
  static String goalDetailPath(String id) => '/app/goals/detail/$id';
  static String investmentDetailPath(String id) =>
      '/app/investments/detail/$id';
  static String editCategoryPath(String id) =>
      '/app/categories/edit/$id';
}
