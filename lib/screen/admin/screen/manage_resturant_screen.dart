// import 'package:QuickBites/screen/user/model/resturant_model.dart';
import 'package:QuickBites/screen/user/model/resturant_model.dart';
import 'package:QuickBites/screen/user/provider/resturant_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageRestaurantsScreen extends StatelessWidget {
  const ManageRestaurantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Restaurants'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, restaurantProvider, child) {
          if (restaurantProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          if (restaurantProvider.restaurants.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No restaurants found',
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
            onRefresh: () => restaurantProvider.fetchRestaurants(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: restaurantProvider.restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = restaurantProvider.restaurants[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange,
                      backgroundImage: restaurant.imageUrl.isNotEmpty
                          ? NetworkImage(restaurant.imageUrl)
                          : null,
                      child: restaurant.imageUrl.isEmpty
                          ? Text(
                              restaurant.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    title: Text(
                      restaurant.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category: ${restaurant.category}'),
                        Text(
                          'Rating: ${restaurant.rating.toStringAsFixed(1)} ⭐',
                        ),
                        Text('Delivery: ${restaurant.deliveryTime} mins'),
                        Text(
                          'Fee: \$${restaurant.deliveryfee.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditRestaurantDialog(context, restaurant);
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(context, restaurant);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRestaurantDialog(context),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddRestaurantDialog(BuildContext context) {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final descriptionController = TextEditingController();
    final imageUrlController = TextEditingController();
    final deliveryTimeController = TextEditingController();
    final ratingController = TextEditingController(text: '4.0');
    final deliveryfeeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Restaurant'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Restaurant Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: deliveryTimeController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Time (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ratingController,
                decoration: const InputDecoration(
                  labelText: 'Rating (0-5)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  categoryController.text.isNotEmpty) {
                final restaurant = RestaurantModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  category: categoryController.text,
                  description: descriptionController.text,
                  imageUrl: imageUrlController.text,
                  deliveryTime: int.tryParse(deliveryTimeController.text) ?? 30,
                  rating: double.tryParse(ratingController.text) ?? 4.0,
                  menuItems: [],
                  deliveryfee:
                      double.tryParse(deliveryfeeController.text) ??
                      100, // Empty menu items initially
                );

                final success = await Provider.of<RestaurantProvider>(
                  context,
                  listen: false,
                ).addRestaurant(restaurant);

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Restaurant added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to add restaurant'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditRestaurantDialog(
    BuildContext context,
    RestaurantModel restaurant,
  ) {
    final nameController = TextEditingController(text: restaurant.name);
    final categoryController = TextEditingController(text: restaurant.category);
    final descriptionController = TextEditingController(
      text: restaurant.description,
    );
    final imageUrlController = TextEditingController(text: restaurant.imageUrl);
    final deliveryTimeController = TextEditingController(
      text: restaurant.deliveryTime.toString(),
    );
    final ratingController = TextEditingController(
      text: restaurant.rating.toString(),
    );
    final deliveryfeeController = TextEditingController(
      text: restaurant.deliveryfee.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${restaurant.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Restaurant Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: deliveryTimeController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Time (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: deliveryfeeController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Fee ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ratingController,
                decoration: const InputDecoration(
                  labelText: 'Rating (0-5)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  categoryController.text.isNotEmpty) {
                final updatedRestaurant = RestaurantModel(
                  id: restaurant.id,
                  name: nameController.text,
                  category: categoryController.text,
                  description: descriptionController.text,
                  imageUrl: imageUrlController.text,
                  deliveryTime:
                      int.tryParse(deliveryTimeController.text) ??
                      restaurant.deliveryTime,
                  rating:
                      double.tryParse(ratingController.text) ??
                      restaurant.rating,
                  menuItems: restaurant.menuItems,
                  deliveryfee:
                      restaurant.deliveryfee, // Preserve existing menu items
                );

                final success = await Provider.of<RestaurantProvider>(
                  context,
                  listen: false,
                ).updateRestaurant(updatedRestaurant);

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Restaurant updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to update restaurant'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    RestaurantModel restaurant,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Restaurant'),
        content: Text('Are you sure you want to delete ${restaurant.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await Provider.of<RestaurantProvider>(
                context,
                listen: false,
              ).deleteRestaurant(restaurant.id);

              Navigator.pop(context);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Restaurant deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete restaurant'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
