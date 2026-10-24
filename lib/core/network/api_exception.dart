/// Custom exception for Ras Hotel API operations.
class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.details,
    this.isNetworkError = false,
  });

  final String message;
  final int? statusCode;
  final dynamic details;
  final bool isNetworkError;

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException ($statusCode): $message';
    }
    return 'ApiException: $message';
  }
}

class NetworkException extends ApiException {
  const NetworkException([super.message = 'Unable to reach the Ras Hotel server. Please check your internet connection.'])
      : super(isNetworkError: true);
}

class TimeoutException extends ApiException {
  const TimeoutException([super.message = 'Server request timed out. Please try again.'])
      : super(isNetworkError: true);
}

class ServerException extends ApiException {
  const ServerException(super.message, {super.statusCode, super.details});
}

class BookingConflictException extends ApiException {
  const BookingConflictException([super.message = 'Room is already booked for the selected dates. Please choose another date or room.'])
      : super(statusCode: 409);
}

class AuthorizationException extends ApiException {
  const AuthorizationException([super.message = 'You are not authorized to perform this operation.'])
      : super(statusCode: 403);
}
