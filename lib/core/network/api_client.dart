import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../features/bookings/domain/booking.dart';
import '../../features/bookings/domain/booking_request.dart';
import '../../features/home/domain/availability.dart';
import '../../features/home/domain/pricing.dart';
import '../../features/home/domain/room.dart';
import 'api_config.dart';
import 'api_exception.dart';
import 'health_response.dart';

/// Configurable HTTPS API client connecting to the Next.js backend.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Default headers sent with requests.
  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  /// Check server and database health status.
  Future<HealthResponse> checkHealth() async {
    final uri = ApiConfig.buildUri(ApiConfig.healthPath);
    final response = await _get(uri);
    return HealthResponse.fromJson(response);
  }

  /// Fetch all active rooms from the server with optional filters.
  Future<List<Room>> getRooms({
    String? type,
    String? status,
    int? capacity,
    int? floor,
  }) async {
    final queryParams = <String, String>{};
    if (type != null && type.isNotEmpty) queryParams['type'] = type;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (capacity != null && capacity > 0) queryParams['capacity'] = capacity.toString();
    if (floor != null) queryParams['floor'] = floor.toString();

    final uri = ApiConfig.buildUri(ApiConfig.roomsPath, queryParams);
    final json = await _get(uri);

    final rawList = json['rooms'] as List<dynamic>? ?? [];
    return rawList
        .map((item) => Room.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Fetch a single room by its unique id or number.
  Future<Room> getRoomById(String id) async {
    final uri = ApiConfig.buildUri('${ApiConfig.roomsPath}/$id');
    final json = await _get(uri);

    final roomJson = json['room'] as Map<String, dynamic>?;
    if (roomJson == null) {
      throw const ApiException('Room data missing in server response', statusCode: 404);
    }
    return Room.fromJson(roomJson);
  }

  /// Check room availability for specific dates with server-side conflict detection.
  Future<AvailabilityResult> checkAvailability({
    required DateTime checkIn,
    required DateTime checkOut,
    String? roomType,
    String? roomId,
    int guests = 1,
  }) async {
    String formatDate(DateTime d) {
      final y = d.year.toString().padLeft(4, '0');
      final m = d.month.toString().padLeft(2, '0');
      final day = d.day.toString().padLeft(2, '0');
      return '$y-$m-$day';
    }

    final queryParams = <String, String>{
      'checkIn': formatDate(checkIn),
      'checkOut': formatDate(checkOut),
      'guests': guests.toString(),
    };
    if (roomType != null && roomType.isNotEmpty) queryParams['roomType'] = roomType;
    if (roomId != null && roomId.isNotEmpty) queryParams['roomId'] = roomId;

    final uri = ApiConfig.buildUri(ApiConfig.availabilityPath, queryParams);
    final json = await _get(uri);
    return AvailabilityResult.fromJson(json);
  }

  /// Calculate server-enforced price breakdown in ETB based on HotelConfig.
  Future<Pricing> calculatePricing({
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    int adults = 1,
    int children = 0,
  }) async {
    String formatDate(DateTime d) {
      final y = d.year.toString().padLeft(4, '0');
      final m = d.month.toString().padLeft(2, '0');
      final day = d.day.toString().padLeft(2, '0');
      return '$y-$m-$day';
    }

    final uri = ApiConfig.buildUri(ApiConfig.pricingPath);
    final payload = {
      'roomId': roomId,
      'checkIn': formatDate(checkIn),
      'checkOut': formatDate(checkOut),
      'adults': adults,
      'children': children,
    };

    final json = await _post(uri, payload);
    final pricingJson = json['pricing'] as Map<String, dynamic>?;
    if (pricingJson == null) {
      throw const ApiException('Pricing data missing in server response');
    }
    return Pricing.fromJson(pricingJson);
  }

  /// Create a real reservation with server-revalidated prices and concurrency conflict detection.
  Future<Booking> createBooking(BookingRequest request) async {
    final uri = ApiConfig.buildUri(ApiConfig.bookingsPath);
    final json = await _post(uri, request.toJson());

    final bookingJson = json['booking'] as Map<String, dynamic>?;
    if (bookingJson == null) {
      throw const ApiException('Booking confirmation missing in server response');
    }
    return Booking.fromJson(bookingJson);
  }

  /// Retrieve bookings belonging to a specific customer using their phone number.
  Future<List<Booking>> getCustomerBookings({
    required String phone,
    String? email,
  }) async {
    final queryParams = <String, String>{
      'phone': phone.trim(),
      if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
    };

    final uri = ApiConfig.buildUri(ApiConfig.bookingsPath, queryParams);
    final json = await _get(uri);

    final rawList = json['bookings'] as List<dynamic>? ?? [];
    return rawList
        .map((item) => Booking.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Retrieve a specific booking by confirmation number.
  Future<Booking> getBookingByConfirmationNo(
    String confirmationNo, {
    String? phone,
  }) async {
    final queryParams = <String, String>{
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
    };

    final uri = ApiConfig.buildUri('${ApiConfig.bookingsPath}/$confirmationNo', queryParams);
    final json = await _get(uri);

    final bookingJson = json['booking'] as Map<String, dynamic>?;
    if (bookingJson == null) {
      throw const ApiException('Reservation not found', statusCode: 404);
    }
    return Booking.fromJson(bookingJson);
  }

  /// Cancel a confirmed or pending reservation.
  Future<bool> cancelBooking({
    required String confirmationNo,
    required String phone,
    String? reason,
  }) async {
    final uri = ApiConfig.buildUri('${ApiConfig.bookingsPath}/$confirmationNo/cancel');
    final payload = {
      'phone': phone.trim(),
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
    };

    final json = await _post(uri, payload);
    return json['ok'] as bool? ?? false;
  }

  /// Internal GET helper that handles timeouts and converts HTTP responses.
  Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on SocketException catch (e) {
      throw NetworkException('Network error connecting to ${uri.host}: ${e.message}');
    } on TimeoutException {
      throw const TimeoutException();
    } on FormatException catch (e) {
      throw ApiException('Malformed response received from server: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected communication error: $e');
    }
  }

  /// Internal POST helper that handles timeouts and converts HTTP responses.
  Future<Map<String, dynamic>> _post(Uri uri, Map<String, dynamic> payload) async {
    try {
      final response = await _client
          .post(uri, headers: _headers, body: jsonEncode(payload))
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on SocketException catch (e) {
      throw NetworkException('Network error connecting to ${uri.host}: ${e.message}');
    } on TimeoutException {
      throw const TimeoutException();
    } on FormatException catch (e) {
      throw ApiException('Malformed response received from server: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected communication error: $e');
    }
  }

  /// Handles parsing HTTP status and JSON response body.
  Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> bodyJson = {};
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          bodyJson = decoded;
        }
      } catch (_) {
        // Non-JSON response
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return bodyJson;
    }

    final serverMessage = bodyJson['message'] as String? ??
        bodyJson['error'] as String? ??
        'Server returned error code ${response.statusCode}';

    if (response.statusCode == 409 || bodyJson['code'] == 'BOOKING_CONFLICT') {
      throw BookingConflictException(serverMessage);
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw AuthorizationException(serverMessage);
    }

    throw ServerException(
      serverMessage,
      statusCode: response.statusCode,
      details: bodyJson,
    );
  }

  void close() {
    _client.close();
  }
}
