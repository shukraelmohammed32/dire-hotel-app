class DeliveryOrderRequest {
  const DeliveryOrderRequest({
    required this.name,
    required this.phone,
    this.email,
    required this.address,
    required this.items,
    this.deliveryTime,
    this.notes,
  });

  final String name;
  final String phone;
  final String? email;
  final String address;
  final List<DeliveryOrderItemRequest> items;
  final DateTime? deliveryTime;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        'phone': phone.trim(),
        if (email != null && email!.trim().isNotEmpty) 'email': email!.trim(),
        'address': address.trim(),
        'items': items.map((e) => e.toJson()).toList(),
        if (deliveryTime != null) 'deliveryTime': deliveryTime!.toIso8601String(),
        if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
      };
}

class DeliveryOrderItemRequest {
  const DeliveryOrderItemRequest({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.category,
    this.notes,
    this.imageUrl,
  });

  final String id;
  final String name;
  final double price;
  final int quantity;
  final String? category;
  final String? notes;
  final String? imageUrl;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
        'category': category,
        'notes': notes,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };
}