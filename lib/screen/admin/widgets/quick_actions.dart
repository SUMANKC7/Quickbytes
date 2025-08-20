// quick_actions.dart
import 'package:flutter/material.dart';

import 'action_card.dart';

class QuickActions extends StatelessWidget {
  final Function(int)? onTabChange;

  const QuickActions({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ActionCard(
                title: 'Add Restaurant',
                subtitle: 'Register new restaurant',
                icon: Icons.add_business,
                color: Colors.blue,
                onTap: () {
                  onTabChange?.call(1); // Navigate to Restaurants tab (index 1)
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ActionCard(
                title: 'Manage Orders',
                subtitle: 'View & update orders',
                icon: Icons.assignment,
                color: Colors.green,
                onTap: () {
                  onTabChange?.call(2); // Navigate to Orders tab (index 2)
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ActionCard(
                title: 'View Analytics',
                subtitle: 'Sales reports & insights',
                icon: Icons.analytics,
                color: Colors.orange,
                onTap: () {
                  onTabChange?.call(3); // Navigate to Analytics tab (index 3)
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ActionCard(
                title: 'Settings',
                subtitle: 'App configuration',
                icon: Icons.settings,
                color: Colors.grey,
                onTap: () {
                  // TODO: Implement settings navigation or functionality (e.g., Navigator.push to SettingsScreen)
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
