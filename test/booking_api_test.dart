import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/features/bookings/domain/booking_request.dart';

void main() {
  setUp(() {
    ApiConfig.setBaseUrl('https://jalo-hotel.vercel.app');
  });

  group('ApiClient Booking Flow Tests', () {
    test('calculatePricing calculates nights and tax breakdown from server', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/pricing');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['roomId'], 'room-201');
        expect(body['checkIn'], '2026-11-01');
        expect(body['checkOut'], '2026-11-03');

        return http.Response(
          jsonEncode({
            'ok': true,
            'pricing': {
              'roomId': 'room-201',
              'roomType': 'Superior King Suite',
              'roomNumber': '201',
              'floor': 2,
              'capacity': 2,
              'checkIn': '2026-11-01T12:00:00.000Z',
              'checkOut': '2026-11-03T10:00:00.000Z',
              'nights': 2,
              'adults': 2,
              'children': 0,
              'nightlyRate': 4500.0,
              'subtotal': 9000.0,
              'vatRate': 15.0,
              'vatAmount': 1350.0,
              'municipalRate': 0.0,
              'municipalTax': 0.0,
              'serviceRate': 0.0,
              'serviceCharge': 0.0,
              'totalEtb': 10350.0,
              'currency': 'ETB',
            }
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final pricing = await apiClient.calculatePricing(
        roomId: 'room-201',
        checkIn: DateTime(2026, 11, 1),
        checkOut: DateTime(2026, 11, 3),
        adults: 2,
      );

      expect(pricing.nights, 2);
      expect(pricing.nightlyRate, 4500.0);
      expect(pricing.subtotal, 9000.0);
      expect(pricing.vatAmount, 1350.0);
      expect(pricing.totalEtb, 10350.0);
    });

    test('createBooking successfully creates reservation with confirmation reference', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/bookings');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['guestName'], 'Abebe Bikila');
        expect(body['guestPhone'], '+251911223344');

        return http.Response(
          jsonEncode({
            'ok': true,
            'message': 'Booking confirmed successfully.',
            'booking': {
              'id': 'res-101',
              'confirmationNo': 'RAS-2026-TEST99',
              'status': 'CONFIRMED',
              'checkInDate': '2026-11-01T12:00:00.000Z',
              'checkOutDate': '2026-11-03T10:00:00.000Z',
              'nights': 2,
              'adults': 2,
              'children': 0,
              'createdAt': '2026-10-24T20:00:00.000Z',
              'pricing': {
                'roomId': 'room-201',
                'roomType': 'Superior King Suite',
                'roomNumber': '201',
                'floor': 2,
                'capacity': 2,
                'checkIn': '2026-11-01T12:00:00.000Z',
                'checkOut': '2026-11-03T10:00:00.000Z',
                'nights': 2,
                'adults': 2,
                'children': 0,
                'nightlyRate': 4500.0,
                'subtotal': 9000.0,
                'vatRate': 15.0,
                'vatAmount': 1350.0,
                'municipalRate': 0.0,
                'municipalTax': 0.0,
                'serviceRate': 0.0,
                'serviceCharge': 0.0,
                'totalEtb': 10350.0,
                'currency': 'ETB',
              },
              'room': {
                'id': 'room-201',
                'number': '201',
                'floor': 2,
                'type': 'Superior King Suite',
                'capacity': 2,
                'baseRate': 4500.0,
              },
              'guest': {
                'name': 'Abebe Bikila',
                'phone': '+251911223344',
                'email': 'abebe@example.com',
              },
              'invoice': {
                'invoiceNo': 'RAS-2026-INV1',
                'total': 10350.0,
              },
            }
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final booking = await apiClient.createBooking(
        BookingRequest(
          roomId: 'room-201',
          checkIn: DateTime(2026, 11, 1),
          checkOut: DateTime(2026, 11, 3),
          guestName: 'Abebe Bikila',
          guestPhone: '+251911223344',
        ),
      );

      expect(booking.confirmationNo, 'RAS-2026-TEST99');
      expect(booking.status, 'CONFIRMED');
      expect(booking.totalEtb, 10350.0);
    });

    test('createBooking throws BookingConflictException on 409 conflict', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'ok': false,
            'code': 'BOOKING_CONFLICT',
            'message': 'Room is already booked for the selected dates.',
          }),
          409,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);

      expect(
        () => apiClient.createBooking(
          BookingRequest(
            roomId: 'room-201',
            checkIn: DateTime(2026, 11, 1),
            checkOut: DateTime(2026, 11, 3),
            guestName: 'Conflict Guest',
            guestPhone: '+251911000000',
          ),
        ),
        throwsA(isA<BookingConflictException>().having((e) => e.statusCode, 'statusCode', 409)),
      );
    });

    test('getCustomerBookings enforces customer phone lookup', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/bookings');
        expect(request.url.queryParameters['phone'], '+251911223344');

        return http.Response(
          jsonEncode({
            'ok': true,
            'count': 1,
            'bookings': [
              {
                'id': 'res-101',
                'confirmationNo': 'RAS-2026-TEST99',
                'status': 'CONFIRMED',
                'checkInDate': '2026-11-01T12:00:00.000Z',
                'checkOutDate': '2026-11-03T10:00:00.000Z',
                'nights': 2,
                'adults': 2,
                'children': 0,
                'createdAt': '2026-10-24T20:00:00.000Z',
                'pricing': {
                  'roomId': 'room-201',
                  'roomType': 'Superior King Suite',
                  'roomNumber': '201',
                  'floor': 2,
                  'capacity': 2,
                  'checkIn': '2026-11-01T12:00:00.000Z',
                  'checkOut': '2026-11-03T10:00:00.000Z',
                  'nights': 2,
                  'adults': 2,
                  'children': 0,
                  'nightlyRate': 4500.0,
                  'subtotal': 9000.0,
                  'vatRate': 15.0,
                  'vatAmount': 1350.0,
                  'municipalRate': 0.0,
                  'municipalTax': 0.0,
                  'serviceRate': 0.0,
                  'serviceCharge': 0.0,
                  'totalEtb': 10350.0,
                  'currency': 'ETB',
                },
                'room': {
                  'id': 'room-201',
                  'number': '201',
                  'floor': 2,
                  'type': 'Superior King Suite',
                  'capacity': 2,
                  'baseRate': 4500.0,
                },
                'guest': {
                  'name': 'Abebe Bikila',
                  'phone': '+251911223344',
                },
                'invoice': {
                  'invoiceNo': 'RAS-2026-INV1',
                  'total': 10350.0,
                },
              }
            ]
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final bookings = await apiClient.getCustomerBookings(phone: '+251911223344');

      expect(bookings.length, 1);
      expect(bookings.first.confirmationNo, 'RAS-2026-TEST99');
      expect(bookings.first.guestPhone, '+251911223344');
    });

    test('cancelBooking calls cancellation endpoint with authorization', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/bookings/RAS-2026-TEST99/cancel');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['phone'], '+251911223344');

        return http.Response(
          jsonEncode({
            'ok': true,
            'message': 'Reservation cancelled successfully.',
            'confirmationNo': 'RAS-2026-TEST99',
            'status': 'CANCELLED',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final success = await apiClient.cancelBooking(
        confirmationNo: 'RAS-2026-TEST99',
        phone: '+251911223344',
      );

      expect(success, true);
    });
  });
}
