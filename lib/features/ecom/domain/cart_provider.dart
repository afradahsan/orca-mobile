import 'package:flutter/material.dart';
import 'package:orca/features/ecom/data/cart_model.dart';
import 'package:orca/features/ecom/data/product_model.dart';
import 'package:orca/features/ecom/domain/cart_services.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  double _totalPrice = 0;
  bool _loading = false;

  List<CartItem> get items => _items;
  double get totalPrice => _totalPrice;
  bool get isLoading => _loading;

  Future<void> fetchCart(String token) async {
    try {
      _loading = true;
      notifyListeners();

      final res = await CartService().getCart(token);
      debugPrint('cart response: $res');
      _items = res.items;
      _totalPrice = res.totalPrice;

      _loading = false;
      notifyListeners();
    } on Exception catch (e) {
      debugPrint('Error fetching cart: $e');
    }
  }

  Future<void> addToCart({
    required String token,
    required String productId,
    required String size,
    required int quantity,
    required double price,
    required String color,
  }) async {
    final updatedCart = await CartService().addToCart(
      token: token,
      productId: productId,
      size: size,
      color: color,
      quantity: quantity,
      price: price,
    );

    await fetchCart(token);
  }

  Future<void> increaseQuantity({
    required String token,
    required String cartId,
    required int quantity,
  }) async {
    await CartService().updateCart(
      token: token,
      cartId: cartId,
      quantity: quantity + 1,
    );
    await fetchCart(token);
  }

  Future<void> decreaseQuantity({
    required String token,
    required String cartId,
    required int quantity,
  }) async {
    if (quantity <= 1) return;

    await CartService().updateCart(
      token: token,
      cartId: cartId,
      quantity: quantity - 1,
    );
    await fetchCart(token);
  }

  Future<void> removeItem(String token, String cartId) async {
    await CartService().removeFromCart(token: token, cartId: cartId);
    await fetchCart(token);
  }

  void clear() {
    _items = [];
    _totalPrice = 0;
    notifyListeners();
  }
}
