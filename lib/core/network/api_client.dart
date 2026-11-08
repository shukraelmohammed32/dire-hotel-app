import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../features/bookings/domain/booking.dart';
import '../../features/bookings/domain/booking_request.dart';
import '../../features/bookings/domain/payment.dart';
import '../../features/dining/domain/dining_reservation.dart';
import '../../features/dining/domain/dining_reservation_request.dart';
import '../../features/delivery/domain/delivery_order.dart';
import '../../features/delivery/domain/delivery_order_request.dart';
import '../../features/events/domain/event_booking.dart';
import '../../features/events/domain/event_booking_request.dart';
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
      throw const ApiException('This room is not available right now. Please try another.', statusCode: 404);
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
      throw const ApiException('Unable to calculate pricing. Please try again.');
    }
    return Pricing.fromJson(pricingJson);
  }

  /// Create a real reservation with server-revalidated prices and concurrency conflict detection.
  Future<Booking> createBooking(BookingRequest request) async {
    final uri = ApiConfig.buildUri(ApiConfig.bookingsPath);
    final json = await _post(uri, request.toJson());

    final bookingJson = json['booking'] as Map<String, dynamic>?;
    if (bookingJson == null) {
      throw const ApiException('Your booking could not be confirmed. Please try again.');
    }
    return Booking.fromJson(bookingJson);
  }

  /// Start or resume a hosted Chapa checkout. The access token is a booking-scoped capability,
  /// never a Chapa credential, and is sent only over HTTPS to the hotel API.
  Future<PaymentCheckout> initializePayment({
    required String invoiceId,
    required String paymentAccessToken,
    required String idempotencyKey,
  }) async {
    final uri = ApiConfig.buildUri('${ApiConfig.paymentsPath}/initialize');
    final json = await _post(
      uri,
      {'invoiceId': invoiceId, 'idempotencyKey': idempotencyKey},
      extraHeaders: {'Authorization': 'Bearer $paymentAccessToken'},
    );
    final paymentJson = json['payment'] as Map<String, dynamic>?;
    if (paymentJson == null) {
      throw const ApiException('Payment checkout could not be started.');
    }
    return PaymentCheckout.fromJson(paymentJson);
  }

  /// Ask the backend to verify an attempt with Chapa and return its trusted status.
  Future<PaymentVerification> verifyPayment({
    required String reference,
    required String paymentAccessToken,
  }) async {
    final uri = ApiConfig.buildUri('${ApiConfig.paymentsPath}/$reference/verify');
    final json = await _get(
      uri,
      extraHeaders: {'Authorization': 'Bearer $paymentAccessToken'},
    );
    final paymentJson = json['payment'] as Map<String, dynamic>?;
    if (paymentJson == null) {
      throw const ApiException('Payment status is not available yet.');
    }
    return PaymentVerification.fromJson(paymentJson);
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
      throw const ApiException('Reservation not found. Please check your confirmation number.', statusCode: 404);
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

  /// Create a dining reservation.
  Future<DiningReservation> createDiningReservation(DiningReservationRequest request) async {
    final uri = ApiConfig.buildUri(ApiConfig.diningReservationsPath);
    final json = await _post(uri, request.toJson());

    final reservationJson = json;
    return DiningReservation.fromJson({
      'id': reservationJson['reservationId'] ?? 'DIN-${DateTime.now().millisecondsSinceEpoch}',
      'createdAt': DateTime.now().toIso8601String(),
      'metadata': request.toJson(),
    });
  }

  /// Retrieve dining reservations for a customer.
  Future<List<DiningReservation>> getCustomerDiningReservations({
    required String phone,
    String? email,
  }) async {
    final queryParams = <String, String>{
      'phone': phone.trim(),
      if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
    };

    final uri = ApiConfig.buildUri(ApiConfig.diningReservationsPath, queryParams);
    final json = await _get(uri);

    final rawList = json['reservations'] as List<dynamic>? ?? [];
    return rawList
        .map((item) => DiningReservation.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Create an event booking.
  Future<EventBooking> createEventBooking(EventBookingRequest request) async {
    final uri = ApiConfig.buildUri(ApiConfig.eventsBookingsPath);
    final json = await _post(uri, request.toJson());

    final bookingJson = json;
    return EventBooking.fromJson({
      'id': bookingJson['bookingId'] ?? 'EVT-${DateTime.now().millisecondsSinceEpoch}',
      'createdAt': DateTime.now().toIso8601String(),
      'metadata': request.toJson(),
    });
  }

  /// Retrieve event bookings for a customer.
  Future<List<EventBooking>> getCustomerEventBookings({
    required String phone,
    String? email,
  }) async {
    final queryParams = <String, String>{
      'phone': phone.trim(),
      if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
    };

    final uri = ApiConfig.buildUri(ApiConfig.eventsBookingsPath, queryParams);
    final json = await _get(uri);

    final rawList = json['bookings'] as List<dynamic>? ?? [];
    return rawList
        .map((item) => EventBooking.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Create a delivery order.
  Future<DeliveryOrder> createDeliveryOrder(DeliveryOrderRequest request) async {
    final uri = ApiConfig.buildUri(ApiConfig.deliveryOrdersPath);
    final json = await _post(uri, request.toJson());

    final orderJson = json;
    return DeliveryOrder.fromJson({
      'id': orderJson['orderId'] ?? 'DEL-${DateTime.now().millisecondsSinceEpoch}',
      'createdAt': DateTime.now().toIso8601String(),
      'metadata': request.toJson(),
    });
  }

  /// Retrieve delivery orders for a customer.
  Future<List<DeliveryOrder>> getCustomerDeliveryOrders({
    required String phone,
    String? email,
  }) async {
    final queryParams = <String, String>{
      'phone': phone.trim(),
      if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
    };

    final uri = ApiConfig.buildUri(ApiConfig.deliveryOrdersPath, queryParams);
    final json = await _get(uri);

    final rawList = json['orders'] as List<dynamic>? ?? [];
    return rawList
        .map((item) => DeliveryOrder.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Internal GET helper that handles timeouts and converts HTTP responses.
  Future<Map<String, dynamic>> _get(Uri uri, {Map<String, String>? extraHeaders}) async {
    try {
      final response = await _client
          .get(uri, headers: {..._headers, ...?extraHeaders})
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const TimeoutException();
    }
  }

  /// Internal POST helper that handles timeouts and converts HTTP responses.
  Future<Map<String, dynamic>> _post(Uri uri, Map<String, dynamic> payload, {Map<String, String>? extraHeaders}) async {
    try {
      final response = await _client
          .post(uri, headers: {..._headers, ...?extraHeaders}, body: jsonEncode(payload))
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const TimeoutException();
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
        'Something went wrong. Please try again.';

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
