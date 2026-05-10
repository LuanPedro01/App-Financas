import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure({required this.message, this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

final class StorageFailure extends Failure {
  const StorageFailure({required super.message, super.code});
}

final class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});

  @override
  List<Object?> get props => [...super.props];
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, super.code});
}

final class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

final class BiometricFailure extends Failure {
  const BiometricFailure({required super.message, super.code});
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message, super.code});
}

final class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

final class ParseFailure extends Failure {
  const ParseFailure({required super.message, super.code});
}

final class PermissionFailure extends Failure {
  const PermissionFailure({required super.message, super.code});
}
