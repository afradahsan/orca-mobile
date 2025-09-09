import 'package:flutter/material.dart';
import 'package:orca/features/ecom/data/product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem(this.product, this.quantity);
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addToCart(Product product, int qty) {
    final index = _items.indexWhere((e) => e.product.id == product.id);
    if (index != -1) {
      _items[index].quantity += qty;
    } else {
      _items.add(CartItem(product, qty));
    }
    notifyListeners();
  }

  void increaseQuantity(int index) {
    _items[index].quantity++;
    notifyListeners();
  }

  void decreaseQuantity(int index) {
    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  int get totalItems => _items.fold(0, (sum, e) => sum + e.quantity);

  double get totalPrice => _items.fold(
    0,
    (sum, e) => sum + (double.parse(e.product.price.replaceAll("₹","")) * e.quantity),
  );
}
