import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financeiro/core/constants/app_constants.dart';
import 'package:financeiro/core/services/storage_service.dart';
import 'package:financeiro/core/services/local_auth_service.dart';

enum AuthStatus {
  initial,
  onboarding,
  pinSetup,
  locked,
  authenticated,
  unauthenticated,
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.biometricEnabled = false,
    this.pinEnabled = false,
    this.isLoading = false,
    this.failedAttempts = 0,
    this.error,
  });

  final AuthStatus status;
  final bool biometricEnabled;
  final bool pinEnabled;
  final bool isLoading;
  final int failedAttempts;
  final String? error;

  AuthState copyWith({
    AuthStatus? status,
    bool? biometricEnabled,
    bool? pinEnabled,
    bool? isLoading,
    int? failedAttempts,
    String? error,
    bool clearError = false,
  }) =>
      AuthState(
        status: status ?? this.status,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
        pinEnabled: pinEnabled ?? this.pinEnabled,
        isLoading: isLoading ?? this.isLoading,
        failedAttempts: failedAttempts ?? this.failedAttempts,
        error: clearError ? null : (error ?? this.error),
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService) : super(const AuthState()) {
    _initialize();
  }

  final LocalAuthService _authService;

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    final onboardingDone =
        StorageService.getBool(AppConstants.keyOnboardingDone) ?? false;
    final pinEnabled =
        StorageService.getBool(AppConstants.keyPinEnabled) ?? false;
    final biometricEnabled =
        StorageService.getBool(AppConstants.keyBiometricEnabled) ?? false;
    final autoLock =
        StorageService.getBool(AppConstants.keyAutoLock) ?? false;

    if (!onboardingDone) {
      state = state.copyWith(
        status: AuthStatus.onboarding,
        isLoading: false,
      );
      return;
    }

    if (pinEnabled || biometricEnabled) {
      final lastLockStr =
          StorageService.getString(AppConstants.keyLastLockTime);
      final shouldLock = _shouldAutoLock(lastLockStr, autoLock);

      if (shouldLock) {
        state = state.copyWith(
          status: AuthStatus.locked,
          pinEnabled: pinEnabled,
          biometricEnabled: biometricEnabled,
          isLoading: false,
        );

        if (biometricEnabled) await authenticateWithBiometrics();
        return;
      }
    }

    state = state.copyWith(
      status: AuthStatus.authenticated,
      pinEnabled: pinEnabled,
      biometricEnabled: biometricEnabled,
      isLoading: false,
    );
  }

  bool _shouldAutoLock(String? lastLockStr, bool autoLock) {
    if (!autoLock) return false;
    if (lastLockStr == null) return false;
    final lastLock = DateTime.tryParse(lastLockStr);
    if (lastLock == null) return true;
    final timeout = StorageService.getInt(AppConstants.keyAutoLockTimeout) ??
        AppConstants.defaultAutoLockTimeoutMinutes;
    return DateTime.now().difference(lastLock).inMinutes >= timeout;
  }

  Future<void> completeOnboarding() async {
    await StorageService.setBool(AppConstants.keyOnboardingDone, value: true);
    state = state.copyWith(status: AuthStatus.authenticated);
  }

  Future<void> setupPin(String pin) async {
    await StorageService.setSecure(AppConstants.secureKeyPin, pin);
    await StorageService.setBool(AppConstants.keyPinEnabled, value: true);
    state = state.copyWith(
      status: AuthStatus.authenticated,
      pinEnabled: true,
    );
  }

  Future<bool> validatePin(String pin) async {
    final storedPin = await StorageService.getSecure(AppConstants.secureKeyPin);
    final valid = storedPin == pin;

    if (valid) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        failedAttempts: 0,
        clearError: true,
      );
    } else {
      final attempts = state.failedAttempts + 1;
      state = state.copyWith(
        failedAttempts: attempts,
        error: attempts >= AppConstants.maxPinAttempts
            ? 'Muitas tentativas incorretas'
            : 'PIN incorreto',
      );
    }
    return valid;
  }

  Future<void> authenticateWithBiometrics() async {
    try {
      final success = await _authService.authenticate(
        reason: 'Use sua biometria para acessar o App Finanças',
      );
      if (success) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          clearError: true,
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> enableBiometric(bool value) async {
    await StorageService.setBool(AppConstants.keyBiometricEnabled, value: value);
    state = state.copyWith(biometricEnabled: value);
  }

  Future<void> removePin() async {
    await StorageService.deleteSecure(AppConstants.secureKeyPin);
    await StorageService.setBool(AppConstants.keyPinEnabled, value: false);
    state = state.copyWith(pinEnabled: false);
  }

  void lock() {
    StorageService.setString(
        AppConstants.keyLastLockTime, DateTime.now().toIso8601String(),);
    state = state.copyWith(status: AuthStatus.locked);
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final localAuthServiceProvider = Provider<LocalAuthService>(
  (ref) => LocalAuthService(),
);

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(localAuthServiceProvider));
});
