class EventBookingRequest {
  const EventBookingRequest({
    required this.name,
    required this.organization,
    required this.phone,
    this.email,
    required this.date,
    required this.eventType,
    required this.guests,
    this.details,
  });

  final String name;
  final String organization;
  final String phone;
  final String? email;
  final DateTime date;
  final String eventType;
  final int guests;
  final String? details;

  String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        'organization': organization.trim(),
        'phone': phone.trim(),
        if (email != null && email!.trim().isNotEmpty) 'email': email!.trim(),
        'date': _formatDate(date),
        'eventType': eventType,
        'guests': guests,
        if (details != null && details!.trim().isNotEmpty) 'details': details!.trim(),
      };
}