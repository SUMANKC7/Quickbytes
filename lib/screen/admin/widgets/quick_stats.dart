// quick_stats.dart
import 'package:QuickBites/screen/user/provider/order_provider.dart';
import 'package:QuickBites/screen/user/provider/resturant_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'stat_card.dart';

class QuickStats extends StatelessWidget {
  const QuickStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<RestaurantProvider, OrderProvider>(
      builder: (context, restaurantProvider, orderProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Stats',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Total Restaurants',
                    value: restaurantProvider.restaurants.length.toString(),
                    icon: Icons.restaurant,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Total Orders',
                    value: orderProvider.orders.length.toString(),
                    icon: Icons.receipt_long,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: "Today's Sales",
                    value:
                        '₹${orderProvider.getTodaysSales().toStringAsFixed(0)}',
                    icon: Icons.attach_money,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: "Today's Orders",
                    value: orderProvider.getTodaysOrderCount().toString(),
                    icon: Icons.today,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
