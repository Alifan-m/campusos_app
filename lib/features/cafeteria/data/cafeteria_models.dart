class MenuCategory {
  final int id;
  final String name;
  final String? description;

  MenuCategory({required this.id, required this.name, this.description});

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

class MenuItem {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int categoryId;
  final String? image;
  final bool isAvailable;

  MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.categoryId,
    this.image,
    required this.isAvailable,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      categoryId: json['category'],
      image: json['image'],
      isAvailable: json['is_available'] ?? true,
    );
  }
}

class CartItem {
  final MenuItem item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});

  double get subtotal => item.price * quantity;
}

class Order {
  final int id;
  final String status;
  final double totalAmount;
  final String createdAt;
  final String? pickupCode;

  Order({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    this.pickupCode,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      status: json['status'],
      totalAmount: double.parse(json['total_amount'].toString()),
      createdAt: json['created_at'],
      pickupCode: json['pickup_code'],
    );
  }
}
