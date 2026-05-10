import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:financeiro/core/constants/app_constants.dart';
import 'package:financeiro/core/services/storage_service.dart';
import 'package:financeiro/core/theme/app_theme.dart';

part 'settings_provider.freezed.dart';

@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(AppThemeMode.dark) AppThemeMode themeMode,
    @Default('BRL') String currency,
    @Default('pt_BR') String locale,
    @Default(false) bool hideBalance,
    @Default(true) bool hapticEnabled,
    @Default(true) bool notificationsEnabled,
    @Default(false) bool autoLock,
    @Default(5) int autoLockTimeout,
    @Default('Usuário') String userName,
    String? userAvatar,
  }) = _AppSettings;
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
        AppConstants.keyNotificationsEnabled, value: value);
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

  void toggleHideBalance() {
    setHideBalance(!state.hideBalance);
  }
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

final appThemeDataProvider = Provider<({ThemeData light, ThemeData dark})>((ref) {
  final mode = ref.watch(settingsProvider).themeMode;
  return (
    light: AppTheme.light,
    dark: mode == AppThemeMode.amoled ? AppTheme.amoled : AppTheme.dark,
  );
});
