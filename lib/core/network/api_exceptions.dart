class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}

class TimeoutException extends ApiException {
  TimeoutException(super.message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message, {super.statusCode, super.data});
}

class BadRequestException extends ApiException {
  BadRequestException(super.message, {super.statusCode, super.data});
}

class ServerException extends ApiException {
  ServerException(super.message, {super.statusCode, super.data});
}

class ConflictException extends ApiException {
  ConflictException(super.message, {super.statusCode, super.data});
}

class ValidationException extends ApiException {
  ValidationException(super.message, {super.statusCode, super.data});
}

