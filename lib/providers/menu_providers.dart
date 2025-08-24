// providers/menu_provider.dart
import 'package:QuickBites/model/menu_item_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:uuid/uuid.dart';
// Import your menu item model here
// import 'package:quickbites/screen/user/model/menu_item_model.dart';

class MenuProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  List<MenuItemModel> _menuItems = [];
  List<MenuItemModel> _filteredMenuItems = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedRestaurant = 'All';

  List<MenuItemModel> get menuItems => _filteredMenuItems;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedRestaurant => _selectedRestaurant;

  // Get unique categories from menu items
  List<String> get categories {
    Set<String> categorySet = {'All'};
    for (var item in _menuItems) {
      categorySet.add(item.category);
    }
    return categorySet.toList();
  }

  // Get unique restaurants from menu items
  List<String> get restaurants {
    Set<String> restaurantSet = {'All'};
    for (var item in _menuItems) {
      restaurantSet.add(item.restaurantName);
    }
    return restaurantSet.toList();
  }

  // Fetch all menu items
  Future<void> fetchMenuItems() async {
    try {
      _isLoading = true;
      notifyListeners();

      QuerySnapshot snapshot = await _firestore
          .collection('menu_items')
          .orderBy('createdAt', descending: true)
          .get();

      _menuItems = snapshot.docs
          .map(
            (doc) => MenuItemModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();

      _applyFilters();
    } catch (e) {
      print('Error fetching menu items: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch menu items by restaurant
  Future<void> fetchMenuItemsByRestaurant(String restaurantId) async {
    try {
      _isLoading = true;
      notifyListeners();

      QuerySnapshot snapshot = await _firestore
          .collection('menu_items')
          .where('restaurantId', isEqualTo: restaurantId)
          .orderBy('category')
          .get();

      _menuItems = snapshot.docs
          .map(
            (doc) => MenuItemModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();

      _applyFilters();
    } catch (e) {
      print('Error fetching menu items by restaurant: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new menu item
  Future<bool> addMenuItem(MenuItemModel menuItem) async {
    try {
      _isLoading = true;
      notifyListeners();

      String itemId = _uuid.v4();
      MenuItemModel newItem = menuItem.copyWith(id: itemId);

      await _firestore
          .collection('menu_items')
          .doc(itemId)
          .set(newItem.toJson());

      _menuItems.insert(0, newItem);
      _applyFilters();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error adding menu item: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update menu item
  Future<bool> updateMenuItem(MenuItemModel menuItem) async {
    try {
      _isLoading = true;
      notifyListeners();

      MenuItemModel updatedItem = menuItem.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection('menu_items')
          .doc(menuItem.id)
          .update(updatedItem.toJson());

      int index = _menuItems.indexWhere((item) => item.id == menuItem.id);
      if (index != -1) {
        _menuItems[index] = updatedItem;
        _applyFilters();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error updating menu item: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete menu item
  Future<bool> deleteMenuItem(String itemId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('menu_items').doc(itemId).delete();

      _menuItems.removeWhere((item) => item.id == itemId);
      _applyFilters();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting menu item: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Toggle item availability
  Future<bool> toggleItemAvailability(String itemId) async {
    try {
      int index = _menuItems.indexWhere((item) => item.id == itemId);
      if (index == -1) return false;

      MenuItemModel item = _menuItems[index];
      MenuItemModel updatedItem = item.copyWith(
        isAvailable: !item.isAvailable,
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('menu_items').doc(itemId).update({
        'isAvailable': updatedItem.isAvailable,
        'updatedAt': Timestamp.fromDate(updatedItem.updatedAt),
      });

      _menuItems[index] = updatedItem;
      _applyFilters();

      return true;
    } catch (e) {
      print('Error toggling item availability: $e');
      return false;
    }
  }

  // Search menu items
  void searchMenuItems(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  // Filter by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  // Filter by restaurant
  void filterByRestaurant(String restaurant) {
    _selectedRestaurant = restaurant;
    _applyFilters();
  }

  // Apply all filters
  void _applyFilters() {
    _filteredMenuItems = _menuItems.where((item) {
      bool matchesSearch =
          _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery) ||
          item.description.toLowerCase().contains(_searchQuery) ||
          item.category.toLowerCase().contains(_searchQuery);

      bool matchesCategory =
          _selectedCategory == 'All' || item.category == _selectedCategory;

      bool matchesRestaurant =
          _selectedRestaurant == 'All' ||
          item.restaurantName == _selectedRestaurant;

      return matchesSearch && matchesCategory && matchesRestaurant;
    }).toList();

    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _selectedRestaurant = 'All';
    _applyFilters();
  }

  // Get menu items count by restaurant
  int getItemCountByRestaurant(String restaurantId) {
    return _menuItems.where((item) => item.restaurantId == restaurantId).length;
  }

  // Get available items count
  int get availableItemsCount {
    return _menuItems.where((item) => item.isAvailable).length;
  }

  // Get unavailable items count
  int get unavailableItemsCount {
    return _menuItems.where((item) => !item.isAvailable).length;
  }
}
