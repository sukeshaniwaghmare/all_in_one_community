import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../../../core/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService.instance;
  
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _error;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  int get itemCount => _cartItems.fold(0, (count, item) => count + item.quantity);
  double get totalAmount => _cartItems.fold(0.0, (total, item) => total + item.totalPrice);

  Future<void> loadCartItems() async {
    _setLoading(true);
    try {
      _cartItems = await _cartService.getCartItems();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addToCart({
    required String productId,
    required String productName,
    required double price,
    required int quantity,
    String? imageUrl,
  }) async {
    try {
      final cartItem = await _cartService.addToCart(
        productId: productId,
        productName: productName,
        price: price,
        quantity: quantity,
        imageUrl: imageUrl,
      );
      _cartItems.insert(0, cartItem);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    try {
      final updatedItem = await _cartService.updateQuantity(
        cartItemId: cartItemId,
        quantity: quantity,
      );
      
      final index = _cartItems.indexWhere((item) => item.id == cartItemId);
      if (index != -1) {
        _cartItems[index] = updatedItem;
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _cartService.removeFromCart(cartItemId);
      _cartItems.removeWhere((item) => item.id == cartItemId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    try {
      await _cartService.clearCart();
      _cartItems.clear();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}