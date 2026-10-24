// ignore_for_file: prefer_initializing_formals

/// Typed domain model representing a hotel room, matching the backend Prisma Room model.
class Room {
  const Room({
    required this.id,
    this.number = '',
    this.floor = 1,
    required this.type,
    this.capacity = 2,
    this.baseRate = 0.0,
    this.status = 'AVAILABLE',
    this.notes,
    this.createdAt,
    this.updatedAt,
    String? name,
    String? description,
    int? pricePerNight,
    String? imageAssetPath,
    String? badge,
    double? rating,
    int? sizeInSquareMeters,
    this.isFeatured = false,
  })  : _name = name,
        _description = description,
        _pricePerNight = pricePerNight,
        _imageAssetPath = imageAssetPath,
        _badge = badge,
        _rating = rating,
        _sizeInSquareMeters = sizeInSquareMeters;

  // Real backend fields from Prisma Room model
  final String id;
  final String number;
  final int floor;
  final String type;
  final int capacity;
  final double baseRate;
  final String status;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isFeatured;

  // Optional presentation overrides
  final String? _name;
  final String? _description;
  final int? _pricePerNight;
  final String? _imageAssetPath;
  final String? _badge;
  final double? _rating;
  final int? _sizeInSquareMeters;

  // Presentation getters compatible with Flutter UI
  String get name => _name ?? (number.isNotEmpty ? '$type (Room $number)' : type);

  int get pricePerNight => _pricePerNight ?? baseRate.round();

  String get description {
    final desc = _description;
    if (desc != null && desc.isNotEmpty) {
      return desc;
    }
    final note = notes;
    if (note != null && note.trim().isNotEmpty) {
      return note.trim();
    }
    return _defaultDescriptionForType(type);
  }

  String get badge {
    final b = _badge;
    if (b != null && b.isNotEmpty) return b;
    final lower = type.toLowerCase();
    if (lower.contains('superior') || lower.contains('king')) return 'Superior';
    if (lower.contains('family')) return 'Family';
    if (lower.contains('suite')) return 'Signature';
    return 'Standard';
  }

  double get rating {
    final r = _rating;
    if (r != null) return r;
    final lower = type.toLowerCase();
    if (lower.contains('superior') || lower.contains('king')) return 4.9;
    if (lower.contains('family')) return 4.8;
    return 4.7;
  }

  int get sizeInSquareMeters {
    final s = _sizeInSquareMeters;
    if (s != null) return s;
    final lower = type.toLowerCase();
    if (lower.contains('family')) return 55;
    if (lower.contains('superior') || lower.contains('king') || lower.contains('suite')) return 42;
    return 28;
  }

  String get imageAssetPath {
    final path = _imageAssetPath;
    if (path != null && path.isNotEmpty) {
      return path;
    }
    final lower = type.toLowerCase();
    if (lower.contains('superior') || lower.contains('king') || lower.contains('deluxe')) {
      return 'assets/images/room_deluxe.png';
    }
    if (lower.contains('family') || lower.contains('wellness')) {
      return 'assets/images/room_wellness.png';
    }
    return 'assets/images/room_dining.png';
  }

  bool get isAvailable => status.toUpperCase() == 'AVAILABLE';

  factory Room.fromJson(Map<String, dynamic> json) {
    final rawBaseRate = json['baseRate'] ?? json['pricePerNight'] ?? 0;
    final double parsedRate = rawBaseRate is num
        ? rawBaseRate.toDouble()
        : double.tryParse(rawBaseRate.toString()) ?? 0.0;

    final typeVal = (json['type'] ?? json['name'] ?? 'Standard Room').toString();
    final numberVal = (json['number'] ?? '').toString();

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      return DateTime.tryParse(val.toString());
    }

    final isSuite = typeVal.toLowerCase().contains('suite') ||
        typeVal.toLowerCase().contains('king');

    return Room(
      id: (json['id'] ?? '').toString(),
      number: numberVal,
      floor: json['floor'] is int ? json['floor'] as int : int.tryParse(json['floor']?.toString() ?? '1') ?? 1,
      type: typeVal,
      capacity: json['capacity'] is int ? json['capacity'] as int : int.tryParse(json['capacity']?.toString() ?? '2') ?? 2,
      baseRate: parsedRate,
      status: (json['status'] ?? 'AVAILABLE').toString().toUpperCase(),
      notes: json['notes'] as String?,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      name: json['name'] as String?,
      description: json['description'] as String?,
      pricePerNight: parsedRate.round(),
      imageAssetPath: json['imageAssetPath'] as String?,
      badge: json['badge'] as String?,
      rating: json['rating'] is num ? (json['rating'] as num).toDouble() : null,
      sizeInSquareMeters: json['sizeInSquareMeters'] is int ? json['sizeInSquareMeters'] as int : null,
      isFeatured: json['isFeatured'] as bool? ?? isSuite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'floor': floor,
        'type': type,
        'capacity': capacity,
        'baseRate': baseRate,
        'status': status,
        'notes': notes,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
        'name': name,
        'description': description,
        'pricePerNight': pricePerNight,
        'imageAssetPath': imageAssetPath,
        'badge': badge,
        'rating': rating,
        'sizeInSquareMeters': sizeInSquareMeters,
        'isFeatured': isFeatured,
      };

  static String _defaultDescriptionForType(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('superior') || lower.contains('king')) {
      return 'Spacious luxury suite featuring plush bedding, quiet workspace, private balcony, and city views.';
    }
    if (lower.contains('family')) {
      return 'Generous multi-room suite accommodating up to four guests with panoramic city views.';
    }
    return 'Comfortable standard room with satellite TV, high-speed Wi-Fi, work desk, and private bathroom.';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Room && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
