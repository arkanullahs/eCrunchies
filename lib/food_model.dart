class Food {
  final String name;
  final double price;
  final String restaurantId;
  final String image;
  final String description;
  final String restaurant; // Add this property

  Food({
    required this.name,
    required this.price,
    required this.restaurantId,
    required this.image,
    required this.description,
    required this.restaurant,
  });
}
