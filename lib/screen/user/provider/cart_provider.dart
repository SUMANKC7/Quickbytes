import 'package:flutter/material.dart';
import 'package:quickbites/screen/user/model/resturant_model.dart';

class CartItem {
  final MenuItem menuItem;
  int quantity;

  CartItem({required this.menuItem, required this.quantity});

  double get totalPrice => menuItem.price * quantity;
}

class CartProvider extends ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.totalPrice;
    });
    return total;
  }

  int get totalItemsCount {
    int total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  void addItem(MenuItem menuItem) {
    if (_items.containsKey(menuItem.id)) {
      _items[menuItem.id]!.quantity += 1;
    } else {
      _items[menuItem.id] = CartItem(menuItem: menuItem, quantity: 1);
    }
    notifyListeners();
  }

  void removeItem(String menuItemId) {
    if (_items.containsKey(menuItemId)) {
      if (_items[menuItemId]!.quantity > 1) {
        _items[menuItemId]!.quantity -= 1;
      } else {
        _items.remove(menuItemId);
      }
    }
    notifyListeners();
  }

  void deleteItem(String menuItemId) {
    _items.remove(menuItemId);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  int getItemQuantity(String menuItemId) {
    return _items[menuItemId]?.quantity ?? 0;
  }
}
