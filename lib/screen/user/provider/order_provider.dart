import 'package:QuickBites/screen/user/model/order_model.dart';
import 'package:QuickBites/screen/user/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'cart_provider.dart';
import 'dart:convert';

class OrderProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  final SharedPreferences _prefs;

  List<OrderModel> _orders = [];
  List<OrderModel> _userOrders = [];
  bool _isLoading = false;
  List<Map<String, dynamic>> _pendingOrders = [];

  List<OrderModel> get orders => _orders;
  List<OrderModel> get userOrders => _userOrders;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get pendingOrders => _pendingOrders;

  OrderProvider(this._prefs) {
    _loadPendingOrders();
  }

  // Load pending orders from local storage
  Future<void> _loadPendingOrders() async {
    try {
      final String? pendingOrdersJson = _prefs.getString('pending_orders');
      if (pendingOrdersJson != null) {
        final List<dynamic> parsed = json.decode(pendingOrdersJson);
        _pendingOrders = parsed.cast<Map<String, dynamic>>();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading pending orders: $e');
    }
  }

  // Save pending orders to local storage
  Future<void> _savePendingOrders() async {
    try {
      final String pendingOrdersJson = json.encode(_pendingOrders);
      await _prefs.setString('pending_orders', pendingOrdersJson);
    } catch (e) {
      print('Error saving pending orders: $e');
    }
  }

  Future<bool> placeOrder({
    required UserModel user,
    required CartProvider cart,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      String orderId = _uuid.v4();

      List<OrderItem> orderItems = cart.items.values.map((cartItem) {
        return OrderItem(
          id: cartItem.menuItem.id,
          name: cartItem.menuItem.name,
          price: cartItem.menuItem.price,
          quantity: cartItem.quantity,
          imageUrl: cartItem.menuItem.imageUrl,
        );
      }).toList();

      OrderModel order = OrderModel(
        id: orderId,
        userId: user.id,
        userName: user.name,
        userPhone: user.phone,
        userAddress: user.address,
        items: orderItems,
        totalAmount: cart.totalAmount,
        status: OrderStatus.placed,
        createdAt: DateTime.now(),
      );

      // Store order locally first (offline support)
      _pendingOrders.add({
        'order': order.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      await _savePendingOrders();

      // Try to sync with Firestore
      await _syncPendingOrders();

      cart.clear();
      await fetchUserOrders(user.id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error placing order: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sync pending orders with Firestore
  Future<void> _syncPendingOrders() async {
    try {
      for (int i = _pendingOrders.length - 1; i >= 0; i--) {
        final pendingOrder = _pendingOrders[i];
        final orderJson = pendingOrder['order'] as Map<String, dynamic>;

        try {
          await _firestore
              .collection('orders')
              .doc(orderJson['id'])
              .set(orderJson);
          // Remove successfully synced order
          _pendingOrders.removeAt(i);
        } catch (e) {
          print('Failed to sync order ${orderJson['id']}: $e');
          // Keep order in pending list for retry later
        }
      }

      await _savePendingOrders();
    } catch (e) {
      print('Error syncing pending orders: $e');
    }
  }

  Future<void> fetchAllOrders() async {
    try {
      _isLoading = true;
      notifyListeners();

      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      _orders = snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserOrders(String userId) async {
    try {
      // First try the indexed query
      try {
        QuerySnapshot snapshot = await _firestore
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();

        _userOrders = snapshot.docs
            .map(
              (doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>),
            )
            .toList();
      } catch (e) {
        // Fallback: Fetch all orders and filter locally
        print('Indexed query failed, using fallback: $e');
        QuerySnapshot snapshot = await _firestore
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .get();

        _userOrders = snapshot.docs
            .map(
              (doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>),
            )
            .where((order) => order.userId == userId)
            .toList();
      }

      // Add pending orders to the list (for offline viewing)
      for (var pendingOrder in _pendingOrders) {
        final orderJson = pendingOrder['order'];
        final order = OrderModel.fromJson(orderJson);
        if (order.userId == userId) {
          _userOrders.insert(0, order); // Add at beginning
        }
      }

      // Sort by date (newest first)
      _userOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      notifyListeners();
    } catch (e) {
      print('Error fetching user orders: $e');

      // Fallback: Show only pending orders if online fetch fails
      _userOrders = _pendingOrders
          .map((pending) => OrderModel.fromJson(pending['order']))
          .where((order) => order.userId == userId)
          .toList();

      _userOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    }
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status.toString().split('.').last, // Convert enum to string
      });

      // Update local data
      int index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = OrderModel(
          id: _orders[index].id,
          userId: _orders[index].userId,
          userName: _orders[index].userName,
          userPhone: _orders[index].userPhone,
          userAddress: _orders[index].userAddress,
          items: _orders[index].items,
          totalAmount: _orders[index].totalAmount,
          status: status,
          createdAt: _orders[index].createdAt,
          restaurantId: _orders[index].restaurantId,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  double getTodaysSales() {
    DateTime today = DateTime.now();
    DateTime startOfDay = DateTime(today.year, today.month, today.day);

    return _orders
        .where(
          (order) =>
              order.createdAt.isAfter(startOfDay) &&
              order.status == OrderStatus.delivered,
        )
        .fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  int getTodaysOrderCount() {
    DateTime today = DateTime.now();
    DateTime startOfDay = DateTime(today.year, today.month, today.day);

    return _orders.where((order) => order.createdAt.isAfter(startOfDay)).length;
  }

  // Retry failed orders
  Future<void> retryFailedOrders() async {
    await _syncPendingOrders();
  }
}
