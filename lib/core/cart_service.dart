import '../features/cart/models/cart_model.dart';
import 'supabase_service.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();
  
  static CartService get instance => _instance;

  final SupabaseService _supabaseService = SupabaseService.instance;

  Future<List<CartItem>> getCartItems() async {
    try {
      final response = await _supabaseService.client
          .from('cart_items')
          .select()
          .eq('user_id', _supabaseService.currentUserId ?? '');
      
      return response.map<CartItem>((item) => CartItem.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load cart items: $e');
    }
  }

  Future<CartItem> addToCart({
    required String productId,
    required String productName,
    required double price,
    required int quantity,
    String? imageUrl,
  }) async {
    try {
      final now = DateTime.now();
      final cartItemData = {
        'user_id': _supabaseService.currentUserId ?? '',
        'product_id': productId,
        'product_name': productName,
        'price': price,
        'quantity': quantity,
        'image_url': imageUrl,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final response = await _supabaseService.client
          .from('cart_items')
          .insert(cartItemData)
          .select()
          .single();

      return CartItem.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  Future<CartItem> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      final response = await _supabaseService.client
          .from('cart_items')
          .update({
            'quantity': quantity,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', cartItemId)
          .select()
          .single();

      return CartItem.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update cart item: $e');
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _supabaseService.client
          .from('cart_items')
          .delete()
          .eq('id', cartItemId);
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      await _supabaseService.client
          .from('cart_items')
          .delete()
          .eq('user_id', _supabaseService.currentUserId ?? '');
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }
}