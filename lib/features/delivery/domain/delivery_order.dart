class DeliveryOrderItem {
  const DeliveryOrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.category,
    this.notes,
  });

  final String id;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  final String? category;
  final String? notes;

  double get total => price * quantity;

  factory DeliveryOrderItem.fromJson(Map<String, dynamic> json) {
    return DeliveryOrderItem(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
        'imageUrl': imageUrl,
        'category': category,
        'notes': notes,
      };
}

class DeliveryOrder {
  const DeliveryOrder({
    required this.id,
    required this.confirmationNo,
    required this.status,
    required this.name,
    required this.phone,
    this.email,
    required this.address,
    required this.items,
    this.deliveryTime,
    this.notes,
    required this.total,
    required this.createdAt,
  });

  final String id;
  final String confirmationNo;
  final String status;
  final String name;
  final String phone;
  final String? email;
  final String address;
  final List<DeliveryOrderItem> items;
  final DateTime? deliveryTime;
  final String? notes;
  final double total;
  final DateTime createdAt;

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    final metadata = json['metadata'] as Map<String, dynamic>? ?? {};
    final itemsJson = metadata['items'] as List<dynamic>? ?? [];

    return DeliveryOrder(
      id: (json['id'] ?? '').toString(),
      confirmationNo: (metadata['confirmationNo'] ?? 'DEL-${json['id']}').toString(),
      status: (metadata['status'] ?? 'PENDING').toString().toUpperCase(),
      name: (metadata['name'] ?? '').toString(),
      phone: (metadata['phone'] ?? '').toString(),
      email: metadata['email'] as String?,
      address: (metadata['address'] ?? '').toString(),
      items: itemsJson.map((e) => DeliveryOrderItem.fromJson(e as Map<String, dynamic>)).toList(),
      deliveryTime: metadata['deliveryTime'] != null ? parseDate(metadata['deliveryTime']) : null,
      notes: metadata['notes'] as String?,
      total: (metadata['total'] is num)
          ? (metadata['total'] as num).toDouble()
          : double.tryParse(metadata['total']?.toString() ?? '0') ?? 0.0,
      createdAt: parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'confirmationNo': confirmationNo,
        'status': status,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'items': items.map((e) => e.toJson()).toList(),
        'deliveryTime': deliveryTime?.toIso8601String(),
        'notes': notes,
        'total': total,
        'createdAt': createdAt.toIso8601String(),
      };
}