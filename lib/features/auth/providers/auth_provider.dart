import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:financeiro/core/constants/app_constants.dart';
import 'package:financeiro/core/services/storage_service.dart';
import 'package:financeiro/core/services/local_auth_service.dart';

part 'auth_provider.freezed.dart';

enum AuthStatus {
  initial,
  onboarding,
  pinSetup,
  locked,
  authenticated,
  unauthenticated,
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(AuthStatus.initial) AuthStatus status,
    @Default(false) bool biometricEnabled,
    @Default(false) bool pinEnabled,
    @Default(false) bool isLoading,
    @Default(0) int failedAttempts,
    String? error,
  }) = _AuthState;
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
      final lastLockStr = StorageService.getString(AppConstants.keyLastLockTime);
      final shouldLock = _shouldAutoLock(lastLockStr, autoLock);

      if (shouldLock) {
        state = state.copyWith(
          status: AuthStatus.locked,
          pinEnabled: pinEnabled,
          biometricEnabled: biometricEnabled,
          isLoading: false,
        );

        if (biometricEnabled) {
          await authenticateWithBiometrics();
        }
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
        error: null,
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
    final result = await _authService.authenticate(
      reason: 'Use sua biometria para acessar o Financeiro',
    );

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (success) {
        if (success) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            error: null,
          );
        }
      },
    );
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
    final now = DateTime.now().toIso8601String();
    StorageService.setString(AppConstants.keyLastLockTime, now);
    state = state.copyWith(status: AuthStatus.locked);
  }

  void clearError() => state = state.copyWith(error: null);
}

final localAuthServiceProvider = Provider<LocalAuthService>(
  (ref) => LocalAuthService(),
);

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(localAuthServiceProvider));
});
