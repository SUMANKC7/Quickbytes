import 'package:QuickBites/screen/user/model/resturant_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<RestaurantModel> _restaurants = [];
  List<RestaurantModel> _filteredRestaurants = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<RestaurantModel> get restaurants => _filteredRestaurants;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<String> get categories {
    Set<String> categorySet = {'All'};
    for (var restaurant in _restaurants) {
      categorySet.add(restaurant.category);
    }
    return categorySet.toList();
  }

  Future<void> fetchRestaurants() async {
    try {
      _isLoading = true;
      notifyListeners();

      QuerySnapshot snapshot = await _firestore.collection('restaurants').get();
      _restaurants = snapshot.docs
          .map(
            (doc) =>
                RestaurantModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();

      _applyFilters();
    } catch (e) {
      print('Error fetching restaurants: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchRestaurants(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredRestaurants = _restaurants.where((restaurant) {
      bool matchesSearch =
          _searchQuery.isEmpty ||
          restaurant.name.toLowerCase().contains(_searchQuery) ||
          restaurant.category.toLowerCase().contains(_searchQuery);

      bool matchesCategory =
          _selectedCategory == 'All' ||
          restaurant.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    notifyListeners();
  }

  Future<bool> addRestaurant(RestaurantModel restaurant) async {
    try {
      await _firestore
          .collection('restaurants')
          .doc(restaurant.id)
          .set(restaurant.toJson());

      _restaurants.add(restaurant);
      _applyFilters();
      return true;
    } catch (e) {
      print('Error adding restaurant: $e');
      return false;
    }
  }

  Future<bool> updateRestaurant(RestaurantModel restaurant) async {
    try {
      await _firestore
          .collection('restaurants')
          .doc(restaurant.id)
          .update(restaurant.toJson());

      int index = _restaurants.indexWhere((r) => r.id == restaurant.id);
      if (index != -1) {
        _restaurants[index] = restaurant;
        _applyFilters();
      }
      return true;
    } catch (e) {
      print('Error updating restaurant: $e');
      return false;
    }
  }

  Future<bool> deleteRestaurant(String restaurantId) async {
    try {
      await _firestore.collection('restaurants').doc(restaurantId).delete();

      _restaurants.removeWhere((r) => r.id == restaurantId);
      _applyFilters();
      return true;
    } catch (e) {
      print('Error deleting restaurant: $e');
      return false;
    }
  }
}
