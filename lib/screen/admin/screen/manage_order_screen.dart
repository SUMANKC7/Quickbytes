import 'package:QuickBites/screen/user/model/order_model.dart';
import 'package:QuickBites/screen/user/provider/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageOrdersScreen extends StatelessWidget {
  const ManageOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No orders found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => orderProvider.fetchAllOrders(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderProvider.orders.length,
              itemBuilder: (context, index) {
                final order = orderProvider.orders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: order.status.color,
                      child: const Icon(Icons.receipt, color: Colors.white),
                    ),
                    title: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Order #${order.id.substring(0, 8)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text('Customer: ${order.userName}'),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text('Status: ${order.status.displayName}'),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Total: ₹${order.totalAmount.toStringAsFixed(0)}',
                          ),
                        ),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        order.status.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: order.status.color,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order Items:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),

                            /// Responsive items list
                            ...order.items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '${item.quantity}x ${item.name}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '₹${(item.price * item.quantity).toStringAsFixed(0)}',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '₹${order.totalAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            /// Responsive action buttons
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (order.status == OrderStatus.placed)
                                  ElevatedButton(
                                    onPressed: () => _updateOrderStatus(
                                      context,
                                      order.id,
                                      OrderStatus.confirmed,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Text(
                                      'Accept',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                if (order.status == OrderStatus.confirmed)
                                  ElevatedButton(
                                    onPressed: () => _updateOrderStatus(
                                      context,
                                      order.id,
                                      OrderStatus.preparing,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                    ),
                                    child: const Text(
                                      'Start Preparing',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                if (order.status == OrderStatus.preparing)
                                  ElevatedButton(
                                    onPressed: () => _updateOrderStatus(
                                      context,
                                      order.id,
                                      OrderStatus.outForDelivery,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                    ),
                                    child: const Text(
                                      'Out for Delivery',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                if (order.status == OrderStatus.outForDelivery)
                                  ElevatedButton(
                                    onPressed: () => _updateOrderStatus(
                                      context,
                                      order.id,
                                      OrderStatus.delivered,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple,
                                    ),
                                    child: const Text(
                                      'Mark Delivered',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                if (order.status != OrderStatus.delivered &&
                                    order.status != OrderStatus.cancelled)
                                  OutlinedButton(
                                    onPressed: () => _updateOrderStatus(
                                      context,
                                      order.id,
                                      OrderStatus.cancelled,
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.red),
                                    ),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _updateOrderStatus(
    BuildContext context,
    String orderId,
    OrderStatus newStatus,
  ) {
    Provider.of<OrderProvider>(
      context,
      listen: false,
    ).updateOrderStatus(orderId, newStatus);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order status updated to ${newStatus.displayName}'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
