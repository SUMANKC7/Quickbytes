class RestaurantModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final double rating;
  final int deliveryTime;
  final List<MenuItem> menuItems;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.deliveryTime,
    required this.menuItems,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      deliveryTime: json['deliveryTime'] ?? 0,
      menuItems:
          (json['menuItems'] as List<dynamic>?)
              ?.map((item) => MenuItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'deliveryTime': deliveryTime,
      'menuItems': menuItems.map((item) => item.toJson()).toList(),
    };
  }
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isVeg;
  final bool isAvailable;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.isVeg,
    this.isAvailable = true,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      isVeg: json['isVeg'] ?? false,
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isVeg': isVeg,
      'isAvailable': isAvailable,
    };
  }
}
