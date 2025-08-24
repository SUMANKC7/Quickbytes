// screens/manage_menu_screen.dart
import 'package:QuickBites/model/menu_item_model.dart';
import 'package:QuickBites/providers/menu_providers.dart';
import 'package:QuickBites/screen/user/provider/resturant_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import your providers and models
// import 'package:quickbites/screen/user/provider/menu_provider.dart';
// import 'package:quickbites/screen/user/provider/resturant_provider.dart';
// import 'package:quickbites/screen/user/model/menu_item_model.dart';
// import 'package:quickbites/screen/user/model/resturant_model.dart';

class ManageMenuScreen extends StatefulWidget {
  const ManageMenuScreen({super.key});

  @override
  State<ManageMenuScreen> createState() => _ManageMenuScreenState();
}

class _ManageMenuScreenState extends State<ManageMenuScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false).fetchMenuItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Menu'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMenuItemDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search menu items...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        Provider.of<MenuProvider>(
                          context,
                          listen: false,
                        ).searchMenuItems('');
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (query) {
                    Provider.of<MenuProvider>(
                      context,
                      listen: false,
                    ).searchMenuItems(query);
                  },
                ),
                const SizedBox(height: 12),

                // Filter Row
                Consumer<MenuProvider>(
                  builder: (context, menuProvider, child) {
                    return Row(
                      children: [
                        Flexible(
                          child: _buildFilterDropdown(
                            'Category',
                            menuProvider.selectedCategory,
                            menuProvider.categories,
                            (value) => menuProvider.filterByCategory(value!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: _buildFilterDropdown(
                            'Restaurant',
                            menuProvider.selectedRestaurant,
                            menuProvider.restaurants,
                            (value) => menuProvider.filterByRestaurant(value!),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          // Menu Items List
          Expanded(
            child: Consumer<MenuProvider>(
              builder: (context, menuProvider, child) {
                if (menuProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  );
                }

                if (menuProvider.menuItems.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 100,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No menu items found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add your first menu item to get started',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: menuProvider.menuItems.length,
                  itemBuilder: (context, index) {
                    MenuItemModel item = menuProvider.menuItems[index];
                    return _buildMenuItemCard(context, item, menuProvider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String selectedValue,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DropdownButtonFormField<String>(
          value: selectedValue.isNotEmpty ? selectedValue : null,
          isExpanded: true, // 🔥 ensures text wraps instead of overflowing
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(
                option,
                overflow: TextOverflow.ellipsis, // 🔥 prevents overflow text
                maxLines: 1,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        );
      },
    );
  }

  Widget _buildMenuItemCard(
    BuildContext context,
    MenuItemModel item,
    MenuProvider menuProvider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            // Item Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey[200],
                    child: const Icon(Icons.restaurant_menu, size: 40),
                  );
                },
              ),
            ),

            // Expanded Item Details
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.55,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Availability
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: item.isAvailable ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.isAvailable ? 'Available' : 'Unavailable',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Text(
                    item.restaurantName,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Tags + Price
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                      if (item.isVegetarian)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Veg',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                      Text(
                        '₹${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(
                    item.isAvailable ? Icons.toggle_on : Icons.toggle_off,
                    color: item.isAvailable ? Colors.green : Colors.grey,
                    size: 32,
                  ),
                  onPressed: () {
                    menuProvider.toggleItemAvailability(item.id);
                  },
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showAddMenuItemDialog(context, item: item);
                    } else if (value == 'delete') {
                      _showDeleteConfirmDialog(context, item, menuProvider);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMenuItemDialog(BuildContext context, {MenuItemModel? item}) {
    showDialog(
      context: context,
      builder: (context) => MenuItemDialog(item: item),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    MenuItemModel item,
    MenuProvider menuProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Menu Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              bool success = await menuProvider.deleteMenuItem(item.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Menu item deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete menu item'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Dialog for adding/editing menu items
class MenuItemDialog extends StatefulWidget {
  final MenuItemModel? item;

  const MenuItemDialog({super.key, this.item});

  @override
  State<MenuItemDialog> createState() => _MenuItemDialogState();
}

class _MenuItemDialogState extends State<MenuItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _preparationTimeController = TextEditingController();

  String _selectedCategory = 'Main Course';
  String? _selectedRestaurantId;
  bool _isVegetarian = false;
  bool _isAvailable = true;
  List<String> _selectedAllergens = [];

  final List<String> _categories = [
    'Main Course',
    'Appetizer',
    'Dessert',
    'Beverage',
    'Snacks',
    'Breakfast',
    'Lunch',
    'Dinner',
  ];

  final List<String> _allergenOptions = [
    'Dairy',
    'Gluten',
    'Nuts',
    'Soy',
    'Eggs',
    'Seafood',
    'None',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _descriptionController.text = widget.item!.description;
      _priceController.text = widget.item!.price.toString();
      _imageUrlController.text = widget.item!.imageUrl;
      _preparationTimeController.text = widget.item!.preparationTime.toString();
      _selectedCategory = widget.item!.category;
      _selectedRestaurantId = widget.item!.restaurantId;
      _isVegetarian = widget.item!.isVegetarian;
      _isAvailable = widget.item!.isAvailable;
      _selectedAllergens = List.from(widget.item!.allergens);
    } else {
      _preparationTimeController.text = '15';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item != null ? 'Edit Menu Item' : 'Add Menu Item',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Restaurant Selection
                      Consumer<RestaurantProvider>(
                        builder: (context, restaurantProvider, child) {
                          return DropdownButtonFormField<String>(
                            value: _selectedRestaurantId,
                            decoration: const InputDecoration(
                              labelText: 'Restaurant *',
                              border: OutlineInputBorder(),
                            ),
                            items: restaurantProvider.restaurants.map((
                              restaurant,
                            ) {
                              return DropdownMenuItem(
                                value: restaurant.id,
                                child: Text(restaurant.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedRestaurantId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a restaurant';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Item Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Item Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter item name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Price and Category Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              decoration: const InputDecoration(
                                labelText: 'Price (₹) *',
                                border: OutlineInputBorder(),
                                prefixText: '₹ ',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter price';
                                }
                                if (double.tryParse(value) == null ||
                                    double.parse(value) <= 0) {
                                  return 'Please enter valid price';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              isExpanded:
                                  true, // ✅ Forces dropdown to take available width
                              decoration: const InputDecoration(
                                labelText: 'Category *',
                                border: OutlineInputBorder(),
                              ),
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(
                                    category,
                                    overflow: TextOverflow
                                        .ellipsis, // ✅ Prevents overflow
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Image URL
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter image URL';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Preparation Time
                      TextFormField(
                        controller: _preparationTimeController,
                        decoration: const InputDecoration(
                          labelText: 'Preparation Time (minutes)',
                          border: OutlineInputBorder(),
                          suffixText: 'min',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (int.tryParse(value) == null ||
                                int.parse(value) <= 0) {
                              return 'Please enter valid time';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Switches
                      Row(
                        children: [
                          Expanded(
                            child: SwitchListTile(
                              title: const Text('Vegetarian'),
                              value: _isVegetarian,
                              onChanged: (value) {
                                setState(() {
                                  _isVegetarian = value;
                                });
                              },
                              activeColor: Colors.green,
                            ),
                          ),
                          Expanded(
                            child: SwitchListTile(
                              title: const Text('Available'),
                              value: _isAvailable,
                              onChanged: (value) {
                                setState(() {
                                  _isAvailable = value;
                                });
                              },
                              activeColor: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Allergens
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Allergens',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _allergenOptions.map((allergen) {
                          return FilterChip(
                            label: Text(allergen),
                            selected: _selectedAllergens.contains(allergen),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  if (allergen == 'None') {
                                    _selectedAllergens.clear();
                                    _selectedAllergens.add('None');
                                  } else {
                                    _selectedAllergens.remove('None');
                                    _selectedAllergens.add(allergen);
                                  }
                                } else {
                                  _selectedAllergens.remove(allergen);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveMenuItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(widget.item != null ? 'Update' : 'Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveMenuItem() async {
    if (!_formKey.currentState!.validate()) return;

    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    final restaurantProvider = Provider.of<RestaurantProvider>(
      context,
      listen: false,
    );

    // Find restaurant name
    String restaurantName = '';
    try {
      restaurantName = restaurantProvider.restaurants
          .firstWhere((r) => r.id == _selectedRestaurantId)
          .name;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a valid restaurant'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    MenuItemModel menuItem = MenuItemModel(
      id: widget.item?.id ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text),
      imageUrl: _imageUrlController.text.trim(),
      category: _selectedCategory,
      restaurantId: _selectedRestaurantId!,
      restaurantName: restaurantName,
      isAvailable: _isAvailable,
      isVegetarian: _isVegetarian,
      allergens: _selectedAllergens,
      preparationTime: int.tryParse(_preparationTimeController.text) ?? 15,
      createdAt: widget.item?.createdAt,
    );

    bool success;
    if (widget.item != null) {
      success = await menuProvider.updateMenuItem(menuItem);
    } else {
      success = await menuProvider.addMenuItem(menuItem);
    }

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.item != null
                ? 'Menu item updated successfully'
                : 'Menu item added successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.item != null
                ? 'Failed to update menu item'
                : 'Failed to add menu item',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _preparationTimeController.dispose();
    super.dispose();
  }
}
