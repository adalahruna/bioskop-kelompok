class FoodModel {
  final String name;
  final String image;
  final String price;
  final String category; // Snack, Drink, Combo
  final String description;
  final double rating;

  FoodModel({
    required this.name,
    required this.image,
    required this.price,
    required this.category,
    required this.description,
    required this.rating,
  });
}
