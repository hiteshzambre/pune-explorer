/// Centralized Exception Classes
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Unable to connect. Please check your internet connection.', super.code = 'NETWORK_ERROR']);
}

class BookingException extends AppException {
  const BookingException(super.message, [super.code = 'BOOKING_ERROR']);
}

class PaymentException extends AppException {
  const PaymentException(super.message, [super.code = 'PAYMENT_ERROR']);
}

class AuthenticationException extends AppException {
  const AuthenticationException(super.message, [super.code = 'AUTH_ERROR']);
}

class ValidationException extends AppException {
  const ValidationException(super.message, [super.code = 'VALIDATION_ERROR']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'An unexpected server error occurred.', super.code = 'SERVER_ERROR']);
}
