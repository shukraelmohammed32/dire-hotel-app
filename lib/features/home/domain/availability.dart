import 'room.dart';

/// Represents the response from the server availability check.
class AvailabilityResult {
  const AvailabilityResult({
    required this.ok,
    required this.message,
    required this.rooms,
    required this.totalAvailable,
    this.checkIn,
    this.checkOut,
  });

  final bool ok;
  final String message;
  final List<Room> rooms;
  final int totalAvailable;
  final DateTime? checkIn;
  final DateTime? checkOut;

  bool get hasAvailableRooms => totalAvailable > 0 && rooms.isNotEmpty;

  factory AvailabilityResult.fromJson(Map<String, dynamic> json) {
    final rawRooms = json['rooms'] as List<dynamic>? ?? [];
    final parsedRooms = rawRooms
        .map((r) => Room.fromJson(r as Map<String, dynamic>))
        .toList();

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      return DateTime.tryParse(val.toString());
    }

    return AvailabilityResult(
      ok: json['ok'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      rooms: parsedRooms,
      totalAvailable: json['totalAvailable'] is int
          ? json['totalAvailable'] as int
          : parsedRooms.length,
      checkIn: parseDate(json['checkIn']),
      checkOut: parseDate(json['checkOut']),
    );
  }

  Map<String, dynamic> toJson() => {
        'ok': ok,
        'message': message,
        'rooms': rooms.map((r) => r.toJson()).toList(),
        'totalAvailable': totalAvailable,
        if (checkIn != null) 'checkIn': checkIn!.toIso8601String(),
        if (checkOut != null) 'checkOut': checkOut!.toIso8601String(),
      };
}
