// dashboard_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickbites/screen/admin/widgets/dashboard_header.dart';
import 'package:quickbites/screen/admin/widgets/quick_actions.dart';
import 'package:quickbites/screen/admin/widgets/quick_stats.dart';
import 'package:quickbites/screen/admin/widgets/recent_orders.dart';
import 'package:quickbites/screen/user/provider/order_provider.dart';
import 'package:quickbites/screen/user/provider/resturant_provider.dart';

class DashboardTab extends StatefulWidget {
  final Function(int)? onTabChange;

  const DashboardTab({super.key, this.onTabChange});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  @override
  void initState() {
    super.initState();
    // Fetch data when the dashboard tab is initialized
    final restaurantProvider = Provider.of<RestaurantProvider>(
      context,
      listen: false,
    );
    if (!restaurantProvider.isLoading) {
      restaurantProvider.fetchRestaurants();
    }
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    if (!orderProvider.isLoading) {
      orderProvider.fetchAllOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DashboardHeader(),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: QuickStats(),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: QuickActions(onTabChange: widget.onTabChange),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RecentOrders(onTabChange: widget.onTabChange),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
