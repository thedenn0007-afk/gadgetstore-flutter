// lib/models/product.dart
class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final int stock;
  final double rating;
  final int reviewCount;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.stock,
    required this.rating,
    required this.reviewCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    category: json['category'] ?? '',
    imageUrl: json['image_url'] ?? '',
    stock: json['stock'] ?? 0,
    rating: (json['rating'] ?? 0).toDouble(),
    reviewCount: json['review_count'] ?? 0,
  );
}

// lib/models/user.dart
class AppUser {
  final int id;
  final String name;
  final String email;
  double walletBalance;
  final String role;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.walletBalance,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'],
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    walletBalance: (json['walletBalance'] ?? json['wallet_balance'] ?? 0).toDouble(),
    role: json['role'] ?? 'user',
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'email': email,
    'walletBalance': walletBalance, 'role': role,
  };
}

// lib/models/cart_item.dart
class CartItem {
  final int cartItemId;
  final int productId;
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  final int stock;
  int quantity;
  final double subtotal;

  CartItem({
    required this.cartItemId,
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock,
    required this.quantity,
    required this.subtotal,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    cartItemId: json['cart_item_id'],
    productId: json['product_id'],
    name: json['name'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    imageUrl: json['image_url'] ?? '',
    category: json['category'] ?? '',
    stock: json['stock'] ?? 0,
    quantity: json['quantity'] ?? 1,
    subtotal: (json['subtotal'] ?? 0).toDouble(),
  );
}

// lib/models/order.dart
class Order {
  final int id;
  final int userId;
  final double totalPrice;
  final String status;
  final String? shippingAddress;
  final String createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.userId,
    required this.totalPrice,
    required this.status,
    this.shippingAddress,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'],
    userId: json['user_id'],
    totalPrice: (json['total_price'] ?? 0).toDouble(),
    status: json['status'] ?? 'PLACED',
    shippingAddress: json['shipping_address'],
    createdAt: json['created_at'] ?? '',
    items: (json['items'] as List? ?? []).map((i) => OrderItem.fromJson(i)).toList(),
  );
}

class OrderItem {
  final int id;
  final int productId;
  final String name;
  final String imageUrl;
  final String category;
  final int quantity;
  final double price;

  OrderItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'],
    productId: json['product_id'],
    name: json['name'] ?? '',
    imageUrl: json['image_url'] ?? '',
    category: json['category'] ?? '',
    quantity: json['quantity'] ?? 1,
    price: (json['price'] ?? 0).toDouble(),
  );
}
