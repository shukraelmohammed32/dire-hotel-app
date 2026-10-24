/// Server-calculated pricing breakdown in ETB according to HotelConfig.
class Pricing {
  const Pricing({
    required this.roomId,
    required this.roomType,
    required this.roomNumber,
    required this.floor,
    required this.capacity,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.adults,
    required this.children,
    required this.nightlyRate,
    required this.subtotal,
    required this.vatRate,
    required this.vatAmount,
    required this.municipalRate,
    required this.municipalTax,
    required this.serviceRate,
    required this.serviceCharge,
    required this.totalEtb,
    required this.currency,
  });

  final String roomId;
  final String roomType;
  final String roomNumber;
  final int floor;
  final int capacity;
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;
  final int adults;
  final int children;
  final double nightlyRate;
  final double subtotal;
  final double vatRate;
  final double vatAmount;
  final double municipalRate;
  final double municipalTax;
  final double serviceRate;
  final double serviceCharge;
  final double totalEtb;
  final String currency;

  factory Pricing.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    int parseInt(dynamic val, [int fallback = 1]) {
      if (val == null) return fallback;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? fallback;
    }

    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return Pricing(
      roomId: (json['roomId'] ?? '').toString(),
      roomType: (json['roomType'] ?? 'Standard Room').toString(),
      roomNumber: (json['roomNumber'] ?? '').toString(),
      floor: parseInt(json['floor'], 1),
      capacity: parseInt(json['capacity'], 2),
      checkIn: parseDate(json['checkIn']),
      checkOut: parseDate(json['checkOut']),
      nights: parseInt(json['nights'], 1),
      adults: parseInt(json['adults'], 1),
      children: parseInt(json['children'], 0),
      nightlyRate: parseNum(json['nightlyRate']),
      subtotal: parseNum(json['subtotal']),
      vatRate: parseNum(json['vatRate']),
      vatAmount: parseNum(json['vatAmount']),
      municipalRate: parseNum(json['municipalRate']),
      municipalTax: parseNum(json['municipalTax']),
      serviceRate: parseNum(json['serviceRate']),
      serviceCharge: parseNum(json['serviceCharge']),
      totalEtb: parseNum(json['totalEtb']),
      currency: (json['currency'] ?? 'ETB').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'roomId': roomId,
        'roomType': roomType,
        'roomNumber': roomNumber,
        'floor': floor,
        'capacity': capacity,
        'checkIn': checkIn.toIso8601String(),
        'checkOut': checkOut.toIso8601String(),
        'nights': nights,
        'adults': adults,
        'children': children,
        'nightlyRate': nightlyRate,
        'subtotal': subtotal,
        'vatRate': vatRate,
        'vatAmount': vatAmount,
        'municipalRate': municipalRate,
        'municipalTax': municipalTax,
        'serviceRate': serviceRate,
        'serviceCharge': serviceCharge,
        'totalEtb': totalEtb,
        'currency': currency,
      };
}
