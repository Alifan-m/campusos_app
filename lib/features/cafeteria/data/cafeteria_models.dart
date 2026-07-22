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
  final int effectiveStock;
  final bool isInStock;

  MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.categoryId,
    this.image,
    required this.isAvailable,
    required this.effectiveStock,
    required this.isInStock,
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
      effectiveStock: json['effective_stock'] ?? 999,
      isInStock: json['is_in_stock'] ?? true,
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
  final List<OrderItemModel> items;

  Order({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    this.pickupCode,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      status: json['status'],
      totalAmount: double.parse(json['total_amount'].toString()),
      createdAt: json['created_at'],
      pickupCode: json['pickup_code'],
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => OrderItemModel.fromJson(e))
              .toList()
          : [],
    );
  }
}

class OrderItemModel {
  final int id;
  final int menuItemId;
  final String menuItemName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  OrderItemModel({
    required this.id,
    required this.menuItemId,
    required this.menuItemName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      menuItemId: json['menu_item'],
      menuItemName: json['menu_item_name'] ?? '',
      quantity: json['quantity'],
      unitPrice: double.parse(json['unit_price'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
    );
  }
}
