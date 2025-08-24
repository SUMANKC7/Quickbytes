// widgets/dashboard_tab.dart
import 'package:QuickBites/providers/menu_providers.dart';
import 'package:QuickBites/screen/user/provider/auth_provider.dart';
import 'package:QuickBites/screen/user/provider/order_provider.dart';
import 'package:QuickBites/screen/user/provider/resturant_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardTab extends StatelessWidget {
  final Function(int) onTabChange;

  const DashboardTab({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Welcome ${authProvider.user?.name}",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
        automaticallyImplyLeading: false,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Consumer3<OrderProvider, RestaurantProvider, MenuProvider>(
        builder: (context, orderProvider, restaurantProvider, menuProvider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                orderProvider.fetchAllOrders(),
                restaurantProvider.fetchRestaurants(),
                menuProvider.fetchMenuItems(),
              ]);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade400,
                          Colors.deepOrange.shade600,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome Back, Admin!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Here\'s what\'s happening with your business today.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Stats
                  const Text(
                    'Quick Stats',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      _buildStatsCard(
                        'Total Orders',
                        orderProvider.orders.length.toString(),
                        Icons.receipt_long,
                        Colors.blue,
                        () => onTabChange(3),
                      ),
                      _buildStatsCard(
                        'Restaurants',
                        restaurantProvider.restaurants.length.toString(),
                        Icons.restaurant,
                        Colors.green,
                        () => onTabChange(1),
                      ),
                      _buildStatsCard(
                        'Menu Items',
                        menuProvider.menuItems.length.toString(),
                        Icons.restaurant_menu,
                        Colors.purple,
                        () => onTabChange(2),
                      ),
                      _buildStatsCard(
                        'Available Items',
                        menuProvider.availableItemsCount.toString(),
                        Icons.check_circle,
                        Colors.teal,
                        () => onTabChange(2),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Today's Performance
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.today, color: Colors.orange.shade600),
                              const SizedBox(width: 8),
                              const Text(
                                "Today's Performance",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: _buildTodayStatItem(
                                  'Orders',
                                  orderProvider
                                      .getTodaysOrderCount()
                                      .toString(),
                                  Icons.shopping_bag,
                                  Colors.orange,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 60,
                                color: Colors.grey.shade300,
                              ),
                              Expanded(
                                child: _buildTodayStatItem(
                                  'Revenue',
                                  '₹${orderProvider.getTodaysSales().toStringAsFixed(0)}',
                                  Icons.attach_money,
                                  Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Menu Overview
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.restaurant_menu,
                                    color: Colors.purple.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Menu Overview',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () => onTabChange(2),
                                child: const Text('View All'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.green.shade600,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            menuProvider.availableItemsCount
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green.shade600,
                                            ),
                                          ),
                                          const Text(
                                            'Available',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.cancel,
                                            color: Colors.red.shade600,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            menuProvider.unavailableItemsCount
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red.shade600,
                                            ),
                                          ),
                                          const Text(
                                            'Unavailable',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.0,
                    children: [
                      _buildActionCard(
                        'Add Restaurant',
                        Icons.add_business,
                        Colors.blue,
                        () => onTabChange(1),
                      ),
                      _buildActionCard(
                        'Add Menu Item',
                        Icons.add_circle,
                        Colors.green,
                        () => onTabChange(2),
                      ),
                      _buildActionCard(
                        'View Orders',
                        Icons.list_alt,
                        Colors.orange,
                        () => onTabChange(3),
                      ),
                      _buildActionCard(
                        'Analytics',
                        Icons.analytics,
                        Colors.purple,
                        () => onTabChange(4),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
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
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FittedBox(
            fit: BoxFit.scaleDown, // scales down content if space is small
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: color),
                const SizedBox(height: 8),

                /// Wrap the value in FittedBox for responsive scaling
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                /// Use Wrap to handle multi-line text gracefully
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
