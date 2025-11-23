import 'food_model.dart';

class CartItemModel {
  final FoodModel food;
  int quantity;

  CartItemModel({required this.food, this.quantity = 1});

  // Helper untuk menghitung total harga item ini (Harga x Qty)
  double get totalPrice {
    // Hapus "Rp " dan "." lalu ubah ke double
    String cleanPrice = food.price.replaceAll("Rp ", "").replaceAll(".", "");
    double price = double.tryParse(cleanPrice) ?? 0;
    return price * quantity;
  }
}
