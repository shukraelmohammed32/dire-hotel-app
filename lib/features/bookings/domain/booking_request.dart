class BookingRequest {
  const BookingRequest({
    required this.roomId,
    required this.checkIn,
    required this.checkOut,
    required this.guestName,
    required this.guestPhone,
    this.guestEmail,
    this.adults = 1,
    this.children = 0,
    this.nationality = 'Ethiopian',
    this.isForeignGuest = false,
    this.passportNumber,
    this.visaNumber,
    this.residencePermit,
    this.specialRequests,
  });

  final String roomId;
  final DateTime checkIn;
  final DateTime checkOut;
  final String guestName;
  final String guestPhone;
  final String? guestEmail;
  final int adults;
  final int children;
  final String nationality;
  final bool isForeignGuest;
  final String? passportNumber;
  final String? visaNumber;
  final String? residencePermit;
  final String? specialRequests;

  String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Map<String, dynamic> toJson() => {
        'roomId': roomId,
        'checkIn': _formatDate(checkIn),
        'checkOut': _formatDate(checkOut),
        'guestName': guestName.trim(),
        'guestPhone': guestPhone.trim(),
        if (guestEmail != null && guestEmail!.trim().isNotEmpty)
          'guestEmail': guestEmail!.trim(),
        'adults': adults,
        'children': children,
        'nationality': nationality,
        'isForeignGuest': isForeignGuest,
        if (passportNumber != null && passportNumber!.trim().isNotEmpty)
          'passportNumber': passportNumber!.trim(),
        if (visaNumber != null && visaNumber!.trim().isNotEmpty)
          'visaNumber': visaNumber!.trim(),
        if (residencePermit != null && residencePermit!.trim().isNotEmpty)
          'residencePermit': residencePermit!.trim(),
        if (specialRequests != null && specialRequests!.trim().isNotEmpty)
          'specialRequests': specialRequests!.trim(),
      };
}
