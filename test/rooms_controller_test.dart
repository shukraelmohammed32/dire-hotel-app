import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/features/home/data/room_repository.dart';
import 'package:mobile/features/home/domain/availability.dart';
import 'package:mobile/features/home/domain/room.dart';
import 'package:mobile/features/home/presentation/controllers/rooms_controller.dart';

class MockSuccessRoomRepository implements RoomRepository {
  final List<Room> sampleRooms = const [
    Room(
      id: '1',
      number: '101',
      floor: 1,
      type: 'Standard Room',
      baseRate: 2800,
      capacity: 2,
    ),
    Room(
      id: '2',
      number: '201',
      floor: 2,
      type: 'Superior King Suite',
      baseRate: 4500,
      capacity: 2,
      isFeatured: true,
    ),
    Room(
      id: '3',
      number: '301',
      floor: 3,
      type: 'Family Suite',
      baseRate: 6200,
      capacity: 4,
    ),
  ];

  @override
  Future<List<Room>> getRooms({String? type, String? status}) async {
    return sampleRooms;
  }

  @override
  Future<Room> getRoomById(String id) async {
    return sampleRooms.firstWhere((r) => r.id == id);
  }

  @override
  Future<AvailabilityResult> checkAvailability({
    required DateTime checkIn,
    required DateTime checkOut,
    String? roomType,
    String? roomId,
    int guests = 1,
  }) async {
    return AvailabilityResult(
      ok: true,
      message: '1 room available',
      rooms: [sampleRooms.first],
      totalAvailable: 1,
      checkIn: checkIn,
      checkOut: checkOut,
    );
  }
}

class MockErrorRoomRepository implements RoomRepository {
  @override
  Future<List<Room>> getRooms({String? type, String? status}) async {
    throw const NetworkException('Failed to reach backend server');
  }

  @override
  Future<Room> getRoomById(String id) async {
    throw const ApiException('Not found', statusCode: 404);
  }

  @override
  Future<AvailabilityResult> checkAvailability({
    required DateTime checkIn,
    required DateTime checkOut,
    String? roomType,
    String? roomId,
    int guests = 1,
  }) async {
    throw const ApiException('Booking conflict', statusCode: 409);
  }
}

void main() {
  group('RoomsController Tests', () {
    test('loadRooms successfully updates rooms and clears loading', () async {
      final controller = RoomsController(repository: MockSuccessRoomRepository());

      expect(controller.isLoading, false);
      expect(controller.rooms, isEmpty);

      final future = controller.loadRooms();
      expect(controller.isLoading, true);

      await future;

      expect(controller.isLoading, false);
      expect(controller.rooms.length, 3);
      expect(controller.errorMessage, isNull);
      expect(controller.featuredRooms.length, 1);
      expect(controller.featuredRooms.first.number, '201');
    });

    test('loadRooms sets error message on failure', () async {
      final controller = RoomsController(repository: MockErrorRoomRepository());

      await controller.loadRooms();

      expect(controller.isLoading, false);
      expect(controller.rooms, isEmpty);
      expect(controller.errorMessage, contains('Failed to reach backend server'));
    });

    test('filterByCategory filters rooms appropriately', () async {
      final controller = RoomsController(repository: MockSuccessRoomRepository());
      await controller.loadRooms();

      controller.setCategory('Standard');
      expect(controller.filteredRooms.length, 1);
      expect(controller.filteredRooms.first.type, 'Standard Room');

      controller.setCategory('Superior');
      expect(controller.filteredRooms.length, 1);
      expect(controller.filteredRooms.first.type, 'Superior King Suite');

      controller.setCategory('Family');
      expect(controller.filteredRooms.length, 1);
      expect(controller.filteredRooms.first.type, 'Family Suite');

      controller.setCategory('All');
      expect(controller.filteredRooms.length, 3);
    });

    test('checkAvailability updates availabilityResult and errors', () async {
      final controller = RoomsController(repository: MockSuccessRoomRepository());
      final dates = DateTimeRange(
        start: DateTime.now().add(const Duration(days: 1)),
        end: DateTime.now().add(const Duration(days: 3)),
      );

      await controller.checkAvailability(dates);

      expect(controller.isCheckingAvailability, false);
      expect(controller.availabilityResult, isNotNull);
      expect(controller.availabilityResult!.totalAvailable, 1);
      expect(controller.availabilityError, isNull);

      controller.clearAvailability();
      expect(controller.selectedDates, isNull);
      expect(controller.availabilityResult, isNull);
    });
  });
}
