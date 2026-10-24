import '../../home/domain/pricing.dart';
import '../../home/domain/room.dart';

class Booking {
  const Booking({
    required this.id,
    required this.confirmationNo,
    required this.status,
    required this.checkInDate,
    required this.checkOutDate,
    required this.nights,
    required this.adults,
    required this.children,
    required this.createdAt,
    required this.pricing,
    required this.room,
    required this.guestName,
    required this.guestPhone,
    this.guestEmail,
    this.specialRequests,
    this.invoiceNo,
    required this.totalEtb,
  });

  final String id;
  final String confirmationNo;
  final String status;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int nights;
  final int adults;
  final int children;
  final DateTime createdAt;
  final Pricing pricing;
  final Room room;
  final String guestName;
  final String guestPhone;
  final String? guestEmail;
  final String? specialRequests;
  final String? invoiceNo;
  final double totalEtb;

  bool get isCancellable => status == 'CONFIRMED' || status == 'PENDING';
  bool get isCancelled => status == 'CANCELLED';
  bool get isCompleted => status == 'CHECKED_OUT';
  bool get isActive =>
      status == 'CONFIRMED' || status == 'PENDING' || status == 'CHECKED_IN';

  factory Booking.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    final pricingJson = json['pricing'] is Map<String, dynamic>
        ? json['pricing'] as Map<String, dynamic>
        : <String, dynamic>{};

    final roomJson = json['room'] is Map<String, dynamic>
        ? json['room'] as Map<String, dynamic>
        : <String, dynamic>{};

    final guestJson = json['guest'] is Map<String, dynamic>
        ? json['guest'] as Map<String, dynamic>
        : <String, dynamic>{};

    final invoiceJson = json['invoice'] is Map<String, dynamic>
        ? json['invoice'] as Map<String, dynamic>
        : <String, dynamic>{};

    final total = pricingJson['totalEtb'] is num
        ? (pricingJson['totalEtb'] as num).toDouble()
        : invoiceJson['total'] is num
            ? (invoiceJson['total'] as num).toDouble()
            : 0.0;

    return Booking(
      id: (json['id'] ?? '').toString(),
      confirmationNo: (json['confirmationNo'] ?? '').toString(),
      status: (json['status'] ?? 'CONFIRMED').toString().toUpperCase(),
      checkInDate: parseDate(json['checkInDate']),
      checkOutDate: parseDate(json['checkOutDate']),
      nights: json['nights'] is int
          ? json['nights'] as int
          : pricingJson['nights'] is int
              ? pricingJson['nights'] as int
              : 1,
      adults: json['adults'] is int ? json['adults'] as int : 1,
      children: json['children'] is int ? json['children'] as int : 0,
      createdAt: parseDate(json['createdAt']),
      specialRequests: json['specialRequests'] as String?,
      pricing: Pricing.fromJson(pricingJson),
      room: Room.fromJson(roomJson),
      guestName: (guestJson['name'] ?? 'Guest').toString(),
      guestPhone: (guestJson['phone'] ?? '').toString(),
      guestEmail: guestJson['email'] as String?,
      invoiceNo: invoiceJson['invoiceNo'] as String?,
      totalEtb: total,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'confirmationNo': confirmationNo,
        'status': status,
        'checkInDate': checkInDate.toIso8601String(),
        'checkOutDate': checkOutDate.toIso8601String(),
        'nights': nights,
        'adults': adults,
        'children': children,
        'createdAt': createdAt.toIso8601String(),
        'specialRequests': specialRequests,
        'pricing': pricing.toJson(),
        'room': room.toJson(),
        'guest': {
          'name': guestName,
          'phone': guestPhone,
          'email': guestEmail,
        },
        'invoice': {
          'invoiceNo': invoiceNo,
          'total': totalEtb,
        },
      };
}
