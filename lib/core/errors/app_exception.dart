class AppException implements Exception {
  const AppException({required this.message, this.code, this.stackTrace});

  final String message;
  final String? code;
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppException($code): $message';
}

class StorageException extends AppException {
  const StorageException({required super.message, super.code, super.stackTrace});
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class NotFoundException extends AppException {
  const NotFoundException({required super.message, super.code, super.stackTrace});
}

class AuthException extends AppException {
  const AuthException({required super.message, super.code, super.stackTrace});
}

class BiometricException extends AppException {
  const BiometricException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}
