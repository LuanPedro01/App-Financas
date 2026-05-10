import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:financeiro/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

enum BiometricType { fingerprint, face, iris, none }

class LocalAuthService {
  LocalAuthService() : _auth = LocalAuthentication();

  final LocalAuthentication _auth;

  Future<bool> get isDeviceSupported => _auth.isDeviceSupported();

  Future<bool> get canCheckBiometrics => _auth.canCheckBiometrics;

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final available = await _auth.getAvailableBiometrics();
      return available.map((b) {
        return switch (b) {
          BiometricType.fingerprint => BiometricType.fingerprint,
          BiometricType.face => BiometricType.face,
          BiometricType.iris => BiometricType.iris,
          _ => BiometricType.none,
        };
      }).toList();
    } catch (_) {
      return [BiometricType.none];
    }
  }

  Future<Either<Failure, bool>> authenticate({
    String reason = 'Confirme sua identidade para continuar',
    bool biometricOnly = false,
  }) async {
    try {
      final canAuth =
          await _auth.canCheckBiometrics || await _auth.isDeviceSupported;
      if (!canAuth) {
        return const Left(
          BiometricFailure(message: 'Biometria não disponível neste dispositivo'),
        );
      }

      final result = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: biometricOnly,
          sensitiveTransaction: true,
          useErrorDialogs: true,
        ),
      );

      return Right(result);
    } on PlatformException catch (e) {
      final message = switch (e.code) {
        auth_error.notAvailable => 'Biometria não disponível',
        auth_error.notEnrolled => 'Nenhuma biometria cadastrada',
        auth_error.lockedOut =>
          'Biometria bloqueada. Tente novamente mais tarde',
        auth_error.permanentlyLockedOut =>
          'Biometria permanentemente bloqueada',
        auth_error.passcodeNotSet =>
          'Nenhum método de desbloqueio configurado',
        _ => e.message ?? 'Erro de autenticação',
      };
      return Left(BiometricFailure(message: message, code: e.code));
    } catch (e) {
      return Left(BiometricFailure(message: e.toString()));
    }
  }

  Future<void> stopAuthentication() => _auth.stopAuthentication();
}
