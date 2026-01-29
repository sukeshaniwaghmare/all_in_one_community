class CartItem {
  final String id;
  final String userId;
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      userId: json['user_id'],
      productId: json['product_id'],
      productName: json['product_name'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  double get totalPrice => price * quantity;
}