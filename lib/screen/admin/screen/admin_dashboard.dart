// admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickbites/providers/menu_providers.dart';
import 'package:quickbites/screen/admin/screen/manage_order_screen.dart';
import 'package:quickbites/screen/admin/screen/manage_resturant_screen.dart';
import 'package:quickbites/screen/admin/widgets/dashboard_header.dart';
import 'package:quickbites/screen/admin/widgets/dashboard_tab.dart';
import 'package:quickbites/screen/manage_menu_screen.dart';
import 'package:quickbites/screen/user/provider/order_provider.dart';
import 'package:quickbites/screen/user/provider/resturant_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RestaurantProvider>(
        context,
        listen: false,
      ).fetchRestaurants();
      Provider.of<OrderProvider>(context, listen: false).fetchAllOrders();
      Provider.of<MenuProvider>(
        context,
        listen: false,
      ).fetchMenuItems(); // Add this line
    });
  }

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardHeader(),
          DashboardTab(onTabChange: _changeTab),
          const ManageRestaurantsScreen(),
          const ManageMenuScreen(), // Add the new menu screen
          const ManageOrdersScreen(),
          const AnalyticsScreen(), // You can implement this or use a placeholder
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _changeTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_outlined),
            activeIcon: Icon(Icons.restaurant),
            label: 'Restaurants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}

// Placeholder Analytics Screen - implement as needed
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer3<OrderProvider, RestaurantProvider, MenuProvider>(
        builder: (context, orderProvider, restaurantProvider, menuProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overview',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Stats Cards
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatsCard(
                      'Total Restaurants',
                      restaurantProvider.restaurants.length.toString(),
                      Icons.restaurant,
                      Colors.blue,
                    ),
                    _buildStatsCard(
                      'Total Menu Items',
                      menuProvider.menuItems.length.toString(),
                      Icons.restaurant_menu,
                      Colors.green,
                    ),
                    _buildStatsCard(
                      'Total Orders',
                      orderProvider.orders.length.toString(),
                      Icons.receipt_long,
                      Colors.orange,
                    ),
                    _buildStatsCard(
                      'Available Items',
                      menuProvider.availableItemsCount.toString(),
                      Icons.check_circle,
                      Colors.teal,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Today's Stats
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today's Performance",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  orderProvider
                                      .getTodaysOrderCount()
                                      .toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                const Text('Orders Today'),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '₹${orderProvider.getTodaysSales().toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const Text('Sales Today'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
