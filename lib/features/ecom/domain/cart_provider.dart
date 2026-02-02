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
    _loading = true;
    notifyListeners();

    final res = await CartService().getCart(token);

    _items = res.items;
    _totalPrice = res.totalPrice;

    _loading = false;
    notifyListeners();
  }

  Future<void> addToCart({
    required String token,
    required String productId,
    required String size,
    required int quantity,
    required double price,
  }) async {
    await CartService().addToCart(token: token, productId: productId, size: size, quantity: quantity, price: price, color: 'default');

    await fetchCart(token);
  }

  Future<void> increaseQuantity({
    required String token,
    required String productId,
    required int quantity,
  }) async {
    await CartService().updateCart(
      token: token,
      productId: productId,
      quantity: quantity
    );

    await fetchCart(token);
  }

  Future<void> decreaseQuantity(int index, {
    required String token,
    required String productId,
    required int quantity,
  }) async {
    await CartService().updateCart(
      token: token,
      productId: productId,
      quantity: quantity,
    );

    await fetchCart(token);
  }

  Future<void> removeItem(String token, String productId) async {
    await CartService().removeFromCart(token, productId);
    await fetchCart(token);
  }

  void clear() {
    _items = [];
    _totalPrice = 0;
    notifyListeners();
  }
}
