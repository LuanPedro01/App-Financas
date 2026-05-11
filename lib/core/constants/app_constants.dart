abstract final class AppConstants {
  // ─── App Info ─────────────────────────────────────────────────────────────
  static const String appName = 'App Finanças';
  static const String appVersion = '1.0.0';
  static const String appPackage = 'com.financeiro.app';

  // ─── Storage Keys ─────────────────────────────────────────────────────────
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyThemeMode = 'theme_mode';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyPinEnabled = 'pin_enabled';
  static const String keyAutoLock = 'auto_lock';
  static const String keyAutoLockTimeout = 'auto_lock_timeout';
  static const String keyHideBalance = 'hide_balance';
  static const String keyCurrency = 'currency';
  static const String keyLocale = 'locale';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyLastLockTime = 'last_lock_time';
  static const String keyHapticEnabled = 'haptic_enabled';
  static const String keyNotificationsEnabled = 'notifications_enabled';

  // ─── Secure Storage Keys ──────────────────────────────────────────────────
  static const String secureKeyPin = 'secure_pin';
  static const String secureKeyUserData = 'secure_user_data';

  // ─── Defaults ─────────────────────────────────────────────────────────────
  static const String defaultCurrency = 'BRL';
  static const String defaultLocale = 'pt_BR';
  static const int defaultAutoLockTimeoutMinutes = 5;
  static const int pinLength = 6;
  static const int maxPinAttempts = 5;

  // ─── Pagination ───────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int dashboardTransactionsLimit = 5;
  static const int recentTransactionsLimit = 10;

  // ─── Animation Durations ─────────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animMedium = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration animVerySlow = Duration(milliseconds: 800);
  static const Duration splashDuration = Duration(milliseconds: 2000);

  // ─── Chart ────────────────────────────────────────────────────────────────
  static const int chartMonthsToShow = 6;
  static const int chartWeeksToShow = 4;

  // ─── Budget Thresholds ────────────────────────────────────────────────────
  static const double budgetWarningThreshold = 0.75;
  static const double budgetCriticalThreshold = 0.90;

  // ─── Transaction ──────────────────────────────────────────────────────────
  static const int maxTagsPerTransaction = 10;
  static const int maxAttachmentsPerTransaction = 5;
  static const int maxInstallments = 60;

  // ─── Notification Channels ────────────────────────────────────────────────
  static const String notifChannelDue = 'channel_due_dates';
  static const String notifChannelBudget = 'channel_budget';
  static const String notifChannelGoals = 'channel_goals';
  static const String notifChannelReminders = 'channel_reminders';
  static const String notifChannelGeneral = 'channel_general';
}
