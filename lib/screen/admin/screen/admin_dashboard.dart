// admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickbites/screen/admin/screen/manage_order_screen.dart';
import 'package:quickbites/screen/admin/screen/manage_resturant_screen.dart';
import 'package:quickbites/screen/admin/widgets/dashboard_tab.dart';
import 'package:quickbites/screen/user/provider/order_provider.dart';
import 'package:quickbites/screen/user/provider/resturant_provider.dart';

// import 'manage_restaurants_screen.dart'; // Uncomment when implemented
// import 'manage_orders_screen.dart'; // Uncomment when implemented
// import 'analytics_screen.dart'; // Uncomment when implemented
// For now, I'll assume AnalyticsScreen is implemented as a placeholder. If not, provide its code or comment out the tab.

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
          DashboardTab(onTabChange: _changeTab),
          const ManageRestaurantsScreen(),
          const ManageOrdersScreen(),
          //     const AnalyticsScreen(), // Add this if implemented, or use placeholder
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
