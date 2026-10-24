import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/core/network/api_exception.dart';

void main() {
  setUp(() {
    ApiConfig.setBaseUrl('https://jalo-hotel.vercel.app');
  });

  group('ApiClient Tests', () {
    test('checkHealth returns valid health response on success', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/health');
        return http.Response(
          jsonEncode({'ok': true, 'service': 'jalo-hotel', 'database': 'ok'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final health = await apiClient.checkHealth();

      expect(health.ok, true);
      expect(health.service, 'jalo-hotel');
      expect(health.database, 'ok');
      expect(health.isDatabaseOk, true);
    });

    test('getRooms parses list of rooms with filters', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/rooms');
        expect(request.url.queryParameters['type'], 'Standard');
        expect(request.url.queryParameters['capacity'], '2');

        final responseData = {
          'ok': true,
          'count': 1,
          'rooms': [
            {
              'id': 'room-101',
              'number': '101',
              'floor': 1,
              'type': 'Standard Room',
              'capacity': 2,
              'baseRate': 2800.0,
              'status': 'AVAILABLE',
            }
          ]
        };

        return http.Response(
          jsonEncode(responseData),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final rooms = await apiClient.getRooms(type: 'Standard', capacity: 2);

      expect(rooms.length, 1);
      expect(rooms.first.id, 'room-101');
      expect(rooms.first.number, '101');
      expect(rooms.first.pricePerNight, 2800);
    });

    test('getRoomById parses single room data', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/rooms/room-201');

        final responseData = {
          'ok': true,
          'room': {
            'id': 'room-201',
            'number': '201',
            'floor': 2,
            'type': 'Superior King Suite',
            'capacity': 2,
            'baseRate': 4500.0,
            'status': 'AVAILABLE',
          }
        };

        return http.Response(
          jsonEncode(responseData),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final room = await apiClient.getRoomById('room-201');

      expect(room.id, 'room-201');
      expect(room.type, 'Superior King Suite');
      expect(room.baseRate, 4500.0);
    });

    test('getRoomById throws ServerException on 404', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'ok': false, 'message': 'Room not found.'}),
          404,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);

      expect(
        () => apiClient.getRoomById('invalid-id'),
        throwsA(isA<ServerException>().having((e) => e.statusCode, 'statusCode', 404)),
      );
    });

    test('checkAvailability passes formatted dates and returns conflicts/available rooms', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/availability');
        expect(request.url.queryParameters['checkIn'], '2026-11-01');
        expect(request.url.queryParameters['checkOut'], '2026-11-03');
        expect(request.url.queryParameters['guests'], '2');

        final responseData = {
          'ok': true,
          'totalAvailable': 1,
          'message': '1 room available for the selected dates.',
          'rooms': [
            {
              'id': 'room-101',
              'number': '101',
              'floor': 1,
              'type': 'Standard Room',
              'capacity': 2,
              'baseRate': 2800.0,
              'status': 'AVAILABLE',
            }
          ]
        };

        return http.Response(
          jsonEncode(responseData),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final result = await apiClient.checkAvailability(
        checkIn: DateTime(2026, 11, 1),
        checkOut: DateTime(2026, 11, 3),
        guests: 2,
      );

      expect(result.ok, true);
      expect(result.totalAvailable, 1);
      expect(result.hasAvailableRooms, true);
      expect(result.rooms.first.number, '101');
    });

    test('handles 500 server error properly', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'ok': false, 'message': 'Database connection error'}),
          500,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);

      expect(
        () => apiClient.getRooms(),
        throwsA(isA<ServerException>().having((e) => e.message, 'message', contains('Database connection error'))),
      );
    });
  });
}
