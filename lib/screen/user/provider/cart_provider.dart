import 'package:QuickBites/screen/user/model/resturant_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartItem {
  final MenuItem menuItem;
  int quantity;

  CartItem({required this.menuItem, required this.quantity});

  double get totalPrice => menuItem.price * quantity;

  // Convert CartItem to Map for JSON serialization
  Map<String, dynamic> toJson() {
    return {'menuItem': menuItem.toJson(), 'quantity': quantity};
  }

  // Create CartItem from Map
  static CartItem fromJson(Map<String, dynamic> json) {
    return CartItem(
      menuItem: MenuItem.fromJson(json['menuItem']),
      quantity: json['quantity'],
    );
  }
}

class CartProvider extends ChangeNotifier {
  Map<String, CartItem> _items = {};
  final SharedPreferences _prefs;

  CartProvider(this._prefs) {
    _loadCartItems();
  }

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

  // Load cart items from local storage
  Future<void> _loadCartItems() async {
    try {
      final String? cartJson = _prefs.getString('cart_items');
      if (cartJson != null) {
        final Map<String, dynamic> parsed = json.decode(cartJson);
        _items = parsed.map((key, value) {
          return MapEntry(key, CartItem.fromJson(value));
        });
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cart items: $e');
    }
  }

  // Save cart items to local storage
  Future<void> _saveCartItems() async {
    try {
      final Map<String, dynamic> itemsJson = _items.map((key, value) {
        return MapEntry(key, value.toJson());
      });

      final String cartJson = json.encode(itemsJson);
      await _prefs.setString('cart_items', cartJson);
    } catch (e) {
      print('Error saving cart items: $e');
    }
  }

  void addItem(MenuItem menuItem) {
    if (_items.containsKey(menuItem.id)) {
      _items[menuItem.id]!.quantity += 1;
    } else {
      _items[menuItem.id] = CartItem(menuItem: menuItem, quantity: 1);
    }
    notifyListeners();
    _saveCartItems(); // Save to local storage
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
    _saveCartItems(); // Save to local storage
  }

  void deleteItem(String menuItemId) {
    _items.remove(menuItemId);
    notifyListeners();
    _saveCartItems(); // Save to local storage
  }

  void clear() {
    _items = {};
    notifyListeners();
    _saveCartItems(); // Save to local storage
  }

  int getItemQuantity(String menuItemId) {
    return _items[menuItemId]?.quantity ?? 0;
  }

  // Check if cart is empty
  bool get isEmpty => _items.isEmpty;

  // Check if a specific item is in cart
  bool containsItem(String menuItemId) {
    return _items.containsKey(menuItemId);
  }

  // Update quantity of a specific item
  void updateQuantity(String menuItemId, int newQuantity) {
    if (_items.containsKey(menuItemId)) {
      if (newQuantity > 0) {
        _items[menuItemId]!.quantity = newQuantity;
      } else {
        _items.remove(menuItemId);
      }
      notifyListeners();
      _saveCartItems(); // Save to local storage
    }
  }

  // Clear only the local storage (useful for testing)
  Future<void> clearLocalStorage() async {
    await _prefs.remove('cart_items');
  }

  // Force reload from local storage
  Future<void> reloadFromStorage() async {
    await _loadCartItems();
  }
}
