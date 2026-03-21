import 'package:equatable/equatable.dart';
import 'package:stack_trace/stack_trace.dart'; // Add this package to your pubspec.yaml

abstract class Failure extends Equatable {
  final String? code;
  final StackTrace? stackTrace;

  const Failure({
    this.code,
    this.stackTrace,
  });

  String get formattedStackTrace => stackTrace != null
      ? Trace.from(stackTrace!).terse.toString()
      : 'No stack trace available';

  @override
  List<Object?> get props => [code, stackTrace];
}

class ServerFailure extends Failure {
  final String message;
  final dynamic error;
  final String? sourceFile;
  final int? lineNumber;
  final String? methodName;

  ServerFailure({
    this.message = "Something went wrong!",
    this.error,
    this.sourceFile,
    this.lineNumber,
    this.methodName,
    super.code,
    StackTrace? stackTrace,
  }) : super(
          stackTrace: stackTrace ?? (error is Error ? error.stackTrace : null),
        );

  factory ServerFailure.fromError(dynamic error, [StackTrace? stackTrace]) {
    final trace = stackTrace ?? (error is Error ? error.stackTrace : null);
    final frame = trace != null
        ? Trace.from(trace).frames.firstWhere(
              (f) => !f.uri.toString().contains('packages'),
              orElse: () => Trace.from(trace).frames.first,
            )
        : null;

    return ServerFailure(
      message: _getErrorMessage(error),
      error: error,
      sourceFile: frame?.uri.toString(),
      lineNumber: frame?.line,
      methodName: frame?.member,
      stackTrace: trace,
      code: _getErrorCode(error),
    );
  }

  static String _getErrorMessage(dynamic error) {
    if (error is String) return error;
    if (error is Error) return error.toString();
    if (error is Exception) return error.toString();
    return "Something went wrong!";
  }

  static String? _getErrorCode(dynamic error) {
    if (error is FormatException) return 'FORMAT_ERROR';
    if (error is TypeError) return 'TYPE_ERROR';
    if (error is StateError) return 'STATE_ERROR';
    return null;
  }

  @override
  String toString() {
    return '''
ServerFailure:
  Message: $message
  Error: ${error?.toString() ?? 'None'}
  Code: ${code ?? 'None'}
  Location: ${sourceFile ?? 'Unknown'}:${lineNumber ?? '?'} in ${methodName ?? 'unknown method'}
  Stack Trace:
${formattedStackTrace.split('\n').map((line) => '    $line').join('\n')}
''';
  }

  @override
  List<Object?> get props => [
        message,
        error,
        sourceFile,
        lineNumber,
        methodName,
        code,
        stackTrace,
      ];
}
