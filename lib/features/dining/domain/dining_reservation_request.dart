class DiningReservationRequest {
  const DiningReservationRequest({
    required this.name,
    required this.phone,
    this.email,
    required this.date,
    required this.time,
    required this.guests,
    this.notes,
  });

  final String name;
  final String phone;
  final String? email;
  final DateTime date;
  final String time;
  final int guests;
  final String? notes;

  String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        'phone': phone.trim(),
        if (email != null && email!.trim().isNotEmpty) 'email': email!.trim(),
        'date': _formatDate(date),
        'time': time,
        'guests': guests,
        if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
      };
}