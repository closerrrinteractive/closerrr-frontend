import 'package:equatable/equatable.dart';

/// Custom class to catch ServerExceptions.
///
/// [message] field provides reason of the exception in short.
class ServerException extends Equatable implements Exception {
  final int? code;
  final String? message;

  const ServerException({
    this.code = 404,
    this.message = 'Could not process your request at the moment.',
  });

  @override
  List<Object?> get props => [code, message];
}
