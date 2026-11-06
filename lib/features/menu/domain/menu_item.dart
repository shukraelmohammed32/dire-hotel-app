enum MenuCategory {
  breakfast,
  ethiopian,
  international,
  grill,
  drinks,
  dessert,
}

class MenuItem {
  const MenuItem({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.price,
    required this.tags,
    this.featured = false,
  });

  final String id;
  final MenuCategory category;
  final String name;
  final String description;
  final int price;
  final List<String> tags;
  final bool featured;
}
