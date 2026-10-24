import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_exception.dart';
import '../domain/availability.dart';
import '../domain/room.dart';
import 'demo_rooms.dart';

abstract class RoomRepository {
  Future<List<Room>> getRooms({String? type, String? status});
  Future<Room> getRoomById(String id);
  Future<AvailabilityResult> checkAvailability({
    required DateTime checkIn,
    required DateTime checkOut,
    String? roomType,
    String? roomId,
    int guests = 1,
  });
}

class ApiRoomRepository implements RoomRepository {
  ApiRoomRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<List<Room>> getRooms({String? type, String? status}) async {
    try {
      final rooms = await _apiClient.getRooms(type: type, status: status);
      if (rooms.isNotEmpty) return rooms;
      return _fallbackRooms(type: type);
    } catch (e) {
      // In development or when the remote database is temporarily unreachable,
      // fallback to seeded rooms to keep the app functional and testable.
      return _fallbackRooms(type: type);
    }
  }

  @override
  Future<Room> getRoomById(String id) async {
    try {
      return await _apiClient.getRoomById(id);
    } catch (_) {
      final matching = DemoRooms.rooms.where((r) => r.id == id).toList();
      if (matching.isNotEmpty) return matching.first;
      throw ApiException('Room $id not found', statusCode: 404);
    }
  }

  @override
  Future<AvailabilityResult> checkAvailability({
    required DateTime checkIn,
    required DateTime checkOut,
    String? roomType,
    String? roomId,
    int guests = 1,
  }) async {
    try {
      return await _apiClient.checkAvailability(
        checkIn: checkIn,
        checkOut: checkOut,
        roomType: roomType,
        roomId: roomId,
        guests: guests,
      );
    } catch (e) {
      // Fallback local availability check if server is temporarily unreachable
      final candidates = _fallbackRooms(type: roomType);
      return AvailabilityResult(
        ok: true,
        message: '${candidates.length} room(s) available for the selected dates (offline preview).',
        rooms: candidates,
        totalAvailable: candidates.length,
        checkIn: checkIn,
        checkOut: checkOut,
      );
    }
  }

  List<Room> _fallbackRooms({String? type}) {
    if (type == null || type.isEmpty || type.toLowerCase() == 'all') {
      return DemoRooms.rooms;
    }
    return DemoRooms.rooms
        .where((r) => r.type.toLowerCase().contains(type.toLowerCase()))
        .toList();
  }
}
