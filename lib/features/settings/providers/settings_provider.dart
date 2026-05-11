import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financeiro/core/constants/app_constants.dart';
import 'package:financeiro/core/services/storage_service.dart';
import 'package:financeiro/core/theme/app_theme.dart';

class AppSettings {
  const AppSettings({
    this.themeMode = AppThemeMode.dark,
    this.currency = 'BRL',
    this.locale = 'pt_BR',
    this.hideBalance = false,
    this.hapticEnabled = true,
    this.notificationsEnabled = true,
    this.autoLock = false,
    this.autoLockTimeout = 5,
    this.userName = 'Usuário',
    this.userAvatar,
  });

  final AppThemeMode themeMode;
  final String currency;
  final String locale;
  final bool hideBalance;
  final bool hapticEnabled;
  final bool notificationsEnabled;
  final bool autoLock;
  final int autoLockTimeout;
  final String userName;
  final String? userAvatar;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    String? currency,
    String? locale,
    bool? hideBalance,
    bool? hapticEnabled,
    bool? notificationsEnabled,
    bool? autoLock,
    int? autoLockTimeout,
    String? userName,
    String? userAvatar,
  }) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        currency: currency ?? this.currency,
        locale: locale ?? this.locale,
        hideBalance: hideBalance ?? this.hideBalance,
        hapticEnabled: hapticEnabled ?? this.hapticEnabled,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        autoLock: autoLock ?? this.autoLock,
        autoLockTimeout: autoLockTimeout ?? this.autoLockTimeout,
        userName: userName ?? this.userName,
        userAvatar: userAvatar ?? this.userAvatar,
      );
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  void _load() {
    final themeModeStr =
        StorageService.getString(AppConstants.keyThemeMode) ?? 'dark';
    final themeMode = AppThemeMode.values.firstWhere(
      (e) => e.name == themeModeStr,
      orElse: () => AppThemeMode.dark,
    );

    state = state.copyWith(
      themeMode: themeMode,
      currency: StorageService.getString(AppConstants.keyCurrency) ??
          AppConstants.defaultCurrency,
      locale: StorageService.getString(AppConstants.keyLocale) ??
          AppConstants.defaultLocale,
      hideBalance:
          StorageService.getBool(AppConstants.keyHideBalance) ?? false,
      hapticEnabled:
          StorageService.getBool(AppConstants.keyHapticEnabled) ?? true,
      notificationsEnabled:
          StorageService.getBool(AppConstants.keyNotificationsEnabled) ?? true,
      autoLock: StorageService.getBool(AppConstants.keyAutoLock) ?? false,
      autoLockTimeout:
          StorageService.getInt(AppConstants.keyAutoLockTimeout) ??
              AppConstants.defaultAutoLockTimeoutMinutes,
    );
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    await StorageService.setString(AppConstants.keyThemeMode, mode.name);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setHideBalance(bool value) async {
    await StorageService.setBool(AppConstants.keyHideBalance, value: value);
    state = state.copyWith(hideBalance: value);
  }

  Future<void> setHapticEnabled(bool value) async {
    await StorageService.setBool(AppConstants.keyHapticEnabled, value: value);
    state = state.copyWith(hapticEnabled: value);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await StorageService.setBool(
        AppConstants.keyNotificationsEnabled, value: value,);
    state = state.copyWith(notificationsEnabled: value);
  }

  Future<void> setAutoLock(bool value) async {
    await StorageService.setBool(AppConstants.keyAutoLock, value: value);
    state = state.copyWith(autoLock: value);
  }

  Future<void> setAutoLockTimeout(int minutes) async {
    await StorageService.setInt(AppConstants.keyAutoLockTimeout, minutes);
    state = state.copyWith(autoLockTimeout: minutes);
  }

  Future<void> setUserName(String name) async {
    state = state.copyWith(userName: name);
  }

  void toggleHideBalance() => setHideBalance(!state.hideBalance);
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  final mode = ref.watch(settingsProvider).themeMode;
  return switch (mode) {
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.amoled => ThemeMode.dark,
    AppThemeMode.light => ThemeMode.light,
  };
});

final appThemeDataProvider =
    Provider<({ThemeData light, ThemeData dark})>((ref) {
  final mode = ref.watch(settingsProvider).themeMode;
  return (
    light: AppTheme.light,
    dark: mode == AppThemeMode.amoled ? AppTheme.amoled : AppTheme.dark,
  );
});
