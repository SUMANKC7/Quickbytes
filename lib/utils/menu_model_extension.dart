// utils/menu_model_extension.dart

// Extension to convert between new MenuItemModel and legacy MenuItem
import 'package:QuickBites/model/menu_item_model.dart';
import 'package:QuickBites/model/resturant_model.dart';

extension MenuItemModelExtension on MenuItemModel {
  // Convert MenuItemModel to MenuItem for backward compatibility
  MenuItem toLegacyMenuItem() {
    return MenuItem(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      category: category,
      isVeg: isVegetarian,
    );
  }
}

extension MenuItemExtension on MenuItem {
  // Convert MenuItem to MenuItemModel for admin operations
  MenuItemModel toMenuItemModel({
    required String restaurantId,
    required String restaurantName,
    bool isAvailable = true,
    List<String> allergens = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItemModel(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      category: category,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      isAvailable: isAvailable,
      // isVegetarian: isVegetarian,
      allergens: allergens,
      // preparationTime: preparationTime,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
