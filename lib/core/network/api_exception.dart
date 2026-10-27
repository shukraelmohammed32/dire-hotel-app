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

  /// Returns only the human-readable message — no technical codes.
  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException([
    super.message = 'No connection. Please check your internet and try again.',
  ]) : super(isNetworkError: true);
}

class TimeoutException extends ApiException {
  const TimeoutException([
    super.message = 'Request timed out. Please try again.',
  ]) : super(isNetworkError: true);
}

class ServerException extends ApiException {
  const ServerException(super.message, {super.statusCode, super.details});
}

class BookingConflictException extends ApiException {
  const BookingConflictException([
    super.message =
        'This room is already booked for those dates. Please choose different dates or another room.',
  ]) : super(statusCode: 409);
}

class AuthorizationException extends ApiException {
  const AuthorizationException([
    super.message = 'You are not authorised to perform this action.',
  ]) : super(statusCode: 403);
}
