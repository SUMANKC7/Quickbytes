import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickbites/screen/user/model/order_model.dart';
import 'package:quickbites/screen/user/model/user_model.dart';
import 'package:uuid/uuid.dart';
import 'cart_provider.dart';

class OrderProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  List<OrderModel> _orders = [];
  List<OrderModel> _userOrders = [];
  bool _isLoading = false;

  List<OrderModel> get orders => _orders;
  List<OrderModel> get userOrders => _userOrders;
  bool get isLoading => _isLoading;

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

      await _firestore.collection('orders').doc(orderId).set(order.toJson());

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
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _userOrders = snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching user orders: $e');
    }
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status.toString(),
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
}
