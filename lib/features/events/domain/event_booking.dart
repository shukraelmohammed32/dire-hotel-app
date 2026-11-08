class EventBooking {
  const EventBooking({
    required this.id,
    required this.confirmationNo,
    required this.status,
    required this.name,
    required this.organization,
    required this.phone,
    this.email,
    required this.date,
    required this.eventType,
    required this.guests,
    this.details,
    required this.createdAt,
  });

  final String id;
  final String confirmationNo;
  final String status;
  final String name;
  final String organization;
  final String phone;
  final String? email;
  final DateTime date;
  final String eventType;
  final int guests;
  final String? details;
  final DateTime createdAt;

  factory EventBooking.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    final metadata = json['metadata'] as Map<String, dynamic>? ?? {};

    return EventBooking(
      id: (json['id'] ?? '').toString(),
      confirmationNo: (metadata['confirmationNo'] ?? 'EVT-${json['id']}').toString(),
      status: (metadata['status'] ?? 'PENDING').toString().toUpperCase(),
      name: (metadata['name'] ?? '').toString(),
      organization: (metadata['organization'] ?? '').toString(),
      phone: (metadata['phone'] ?? '').toString(),
      email: metadata['email'] as String?,
      date: parseDate(metadata['date']),
      eventType: (metadata['eventType'] ?? '').toString(),
      guests: metadata['guests'] is int
          ? metadata['guests'] as int
          : int.tryParse(metadata['guests']?.toString() ?? '') ?? 1,
      details: metadata['details'] as String?,
      createdAt: parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'confirmationNo': confirmationNo,
        'status': status,
        'name': name,
        'organization': organization,
        'phone': phone,
        'email': email,
        'date': date.toIso8601String().split('T')[0],
        'eventType': eventType,
        'guests': guests,
        'details': details,
        'createdAt': createdAt.toIso8601String(),
      };
}