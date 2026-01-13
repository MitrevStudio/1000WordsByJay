/// Base exception for the app
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() =>
      'AppException: $message${code != null ? ' ($code)' : ''}';
}

/// Exception for database operations
class DatabaseException extends AppException {
  DatabaseException(super.message, {super.code});
}

/// Exception for data not found
class NotFoundException extends AppException {
  NotFoundException(super.message, {super.code});
}

/// Exception for invalid data
class ValidationException extends AppException {
  ValidationException(super.message, {super.code});
}
