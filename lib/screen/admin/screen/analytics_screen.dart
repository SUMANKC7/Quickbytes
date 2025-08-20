// // analytics_screen.dart (place in screen/admin/screen/)
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:quickbites/model/resturant_model.dart';
// import 'package:quickbites/screen/user/model/order_model.dart';
// import 'package:quickbites/screen/user/provider/order_provider.dart';
// import 'package:quickbites/screen/user/provider/resturant_provider.dart';
// import 'package:quickbites/screen/admin/widgets/stat_card.dart'; // Assuming stat_card.dart is in admin/widgets

// class AnalyticsScreen extends StatelessWidget {
//   const AnalyticsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer2<RestaurantProvider, OrderProvider>(
//       builder: (context, restaurantProvider, orderProvider, child) {
//         final totalRestaurants = restaurantProvider.restaurants.length;
//         final totalOrders = orderProvider.orders.length;
//         final totalRevenue = orderProvider.orders.fold<double>(0.0, (sum, order) => sum + (order.status == OrderStatus.delivered ? order.totalAmount : 0));
//         final averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;

//         // Compute monthly sales (example for current month)
//         final now = DateTime.now();
//         final startOfMonth = DateTime(now.year, now.month, 1);
//         final monthlySales = orderProvider.orders
//             .where((order) => order.createdAt.isAfter(startOfMonth) && order.status == OrderStatus.delivered)
//             .fold<double>(0.0, (sum, order) => sum + order.totalAmount);

//         // Top restaurants by sales (group orders by restaurantId if available)
//         // Note: Assuming OrderModel has restaurantId; if not, add it or skip this section
//         Map<String, double> restaurantSales = {};
//         for (var order in orderProvider.orders) {
//           if (order.status == OrderStatus.delivered && order.restaurantId != null) {
//             restaurantSales.update(
//               order.restaurantId!,
//               (value) => value + order.totalAmount,
//               ifAbsent: () => order.totalAmount,
//             );
//           }
//         }
//         final topRestaurants = restaurantSales.entries.toList()
//           ..sort((a, b) => b.value.compareTo(a.value));
//         final top3 = topRestaurants.take(3).toList();

//         return SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Analytics & Insights',
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 24),
//                 const Text(
//                   'Key Metrics',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: StatCard(
//                         title: 'Total Restaurants',
//                         value: totalRestaurants.toString(),
//                         icon: Icons.restaurant,
//                         color: Colors.blue,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: StatCard(
//                         title: 'Total Orders',
//                         value: totalOrders.toString(),
//                         icon: Icons.receipt_long,
//                         color: Colors.green,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: StatCard(
//                         title: 'Total Revenue',
//                         value: '₹${totalRevenue.toStringAsFixed(0)}',
//                         icon: Icons.attach_money,
//                         color: Colors.orange,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: StatCard(
//                         title: 'Avg Order Value',
//                         value: '₹${averageOrderValue.toStringAsFixed(0)}',
//                         icon: Icons.trending_up,
//                         color: Colors.purple,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 StatCard(
//                   title: 'Monthly Sales',
//                   value: '₹${monthlySales.toStringAsFixed(0)}',
//                   icon: Icons.calendar_today,
//                   color: Colors.teal,
//                 ),
//                 const SizedBox(height: 32),
//                 const Text(
//                   'Top Performing Restaurants',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 16),
//                 if (top3.isEmpty)
//                   const Center(
//                     child: Text(
//                       'No sales data available',
//                       style: TextStyle(color: Colors.grey, fontSize: 16),
//                     ),
//                   )
//                 else
//                   ...top3.map((entry) {
//                     final restaurant = restaurantProvider.restaurants
//                         .firstWhere((r) => r.id == entry.key, orElse: () => RestaurantModel(id: entry.key, name: 'Unknown', category: '', imageUrl: '', rating: 0.0, deliveryTime: 0, minimumOrder: 0.0));
//                     return Card(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       child: ListTile(
//                         leading: CircleAvatar(
//                           backgroundImage: NetworkImage(restaurant.imageUrl),
//                         ),
//                         title: Text(restaurant.name),
//                         subtitle: Text(restaurant.category),
//                         trailing: Text(
//                           '₹${entry.value.toStringAsFixed(0)}',
//                           style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
//                         ),
//                       ),
//                     );
//                   }),
//                 const SizedBox(height: 32),
//                 // TODO: Add charts here if you integrate a chart library like charts_flutter
//                 // For example:
//                 // const Text('Sales Trend', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                 // SizedBox(height: 16),
//                 // // Chart widget
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
