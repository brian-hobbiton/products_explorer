import 'package:flutter/foundation.dart';
import 'package:products_explorer/models/product_model.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => _items;

  void addToCart(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += 1;
    } else {
      _items[product.id!.toInt()] = CartItem(product: product);
    }
    notifyListeners();
  }

  void updateQuantity(Product product, int newQuantity) {
    if (_items.containsKey(product.id)) {
      if (newQuantity > 0) {
        _items[product.id?.toInt() ?? 0] = CartItem(
          product: product,
          quantity: newQuantity,
        );
      } else {
        _items.remove(product.id);
      }
      notifyListeners();
    }
  }

  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  int get totalItems =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.values.fold(
    0,
    (sum, item) => sum + item.quantity * (item.product.price ?? 0),
  );
}
