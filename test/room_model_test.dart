import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/network/health_response.dart';
import 'package:mobile/features/home/domain/availability.dart';
import 'package:mobile/features/home/domain/room.dart';

void main() {
  group('Room Model (Prisma Backend Alignment)', () {
    test('parses real backend room JSON correctly', () {
      final json = {
        'id': 'cm7test123',
        'number': '201',
        'floor': 2,
        'type': 'Superior King Suite',
        'capacity': 2,
        'baseRate': 4500.0,
        'status': 'AVAILABLE',
        'notes': 'Quiet floor with mountain view',
        'createdAt': '2026-08-10T12:00:00.000Z',
        'updatedAt': '2026-08-10T12:00:00.000Z',
      };

      final room = Room.fromJson(json);

      expect(room.id, 'cm7test123');
      expect(room.number, '201');
      expect(room.floor, 2);
      expect(room.type, 'Superior King Suite');
      expect(room.capacity, 2);
      expect(room.baseRate, 4500.0);
      expect(room.pricePerNight, 4500);
      expect(room.status, 'AVAILABLE');
      expect(room.isAvailable, true);
      expect(room.notes, 'Quiet floor with mountain view');
      expect(room.badge, 'Superior');
      expect(room.sizeInSquareMeters, 42);
      expect(room.imageAssetPath, 'assets/images/room_deluxe.png');
      expect(room.name, 'Superior King Suite (Room 201)');
    });

    test('parses Standard Room with defaults', () {
      final json = {
        'id': 'cm7test101',
        'number': '101',
        'floor': 1,
        'type': 'Standard Room',
        'capacity': 2,
        'baseRate': 2800,
        'status': 'OCCUPIED',
      };

      final room = Room.fromJson(json);

      expect(room.number, '101');
      expect(room.baseRate, 2800.0);
      expect(room.isAvailable, false);
      expect(room.badge, 'Standard');
      expect(room.sizeInSquareMeters, 28);
      expect(room.imageAssetPath, 'assets/images/room_dining.png');
    });

    test('converts to JSON matching schema', () {
      const room = Room(
        id: 'test-room',
        number: '301',
        floor: 3,
        type: 'Family Suite',
        capacity: 4,
        baseRate: 6200.0,
        status: 'AVAILABLE',
      );

      final json = room.toJson();
      expect(json['id'], 'test-room');
      expect(json['number'], '301');
      expect(json['floor'], 3);
      expect(json['type'], 'Family Suite');
      expect(json['capacity'], 4);
      expect(json['baseRate'], 6200.0);
      expect(json['status'], 'AVAILABLE');
    });
  });

  group('AvailabilityResult Model', () {
    test('parses server availability JSON correctly', () {
      final json = {
        'ok': true,
        'totalAvailable': 2,
        'message': '2 matching rooms available.',
        'checkIn': '2026-11-01T12:00:00.000Z',
        'checkOut': '2026-11-03T10:00:00.000Z',
        'rooms': [
          {
            'id': 'room-1',
            'number': '101',
            'floor': 1,
            'type': 'Standard Room',
            'capacity': 2,
            'baseRate': 2800,
            'status': 'AVAILABLE',
          },
          {
            'id': 'room-2',
            'number': '102',
            'floor': 1,
            'type': 'Standard Room',
            'capacity': 2,
            'baseRate': 2800,
            'status': 'AVAILABLE',
          },
        ],
      };

      final result = AvailabilityResult.fromJson(json);

      expect(result.ok, true);
      expect(result.totalAvailable, 2);
      expect(result.hasAvailableRooms, true);
      expect(result.rooms.length, 2);
      expect(result.rooms.first.number, '101');
      expect(result.checkIn, isNotNull);
      expect(result.checkOut, isNotNull);
    });
  });

  group('HealthResponse Model', () {
    test('parses health check response', () {
      final json = {
        'ok': true,
        'service': 'jalo-hotel',
        'database': 'ok',
      };

      final health = HealthResponse.fromJson(json);
      expect(health.ok, true);
      expect(health.service, 'jalo-hotel');
      expect(health.database, 'ok');
      expect(health.isDatabaseOk, true);
    });
  });
}
