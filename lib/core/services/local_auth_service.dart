import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class LocalAuthService {
  LocalAuthService() : _auth = LocalAuthentication();

  final LocalAuthentication _auth;

  Future<bool> get isDeviceSupported => _auth.isDeviceSupported();

  Future<bool> get canCheckBiometrics => _auth.canCheckBiometrics;

  Future<bool> authenticate({
    String reason = 'Confirme sua identidade para continuar',
    bool biometricOnly = false,
  }) async {
    final canBiometrics = await _auth.canCheckBiometrics;
    final isSupported = await _auth.isDeviceSupported();
    if (!canBiometrics && !isSupported) return false;

    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: biometricOnly,
          sensitiveTransaction: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      final blocked = [
        auth_error.lockedOut,
        auth_error.permanentlyLockedOut,
      ];
      if (blocked.contains(e.code)) rethrow;
      return false;
    }
  }

  Future<void> stopAuthentication() => _auth.stopAuthentication();
}
