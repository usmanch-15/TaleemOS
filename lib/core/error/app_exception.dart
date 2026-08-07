class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => message;
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

class NetworkException extends AppException {
  const NetworkException([String message = 'No internet connection'])
      : super(message, code: 'network_error');
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}